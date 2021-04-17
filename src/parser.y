%{

/************************
---      includes     ---
************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstdarg>

#include "../src/config.h"

/************************
---       bison       ---
************************/
extern int yylex();
extern int yyparse();
extern FILE * yyin;

void yyerror(const char * s);

/************************
---       debug       ---
************************/
#ifdef DEBUG_YACC
  #define LOG(...) printf(__VA_ARGS__)
#else
  #define LOG
#endif

/************************
---      output       ---
************************/
typedef long unsigned size_t;

void OUT(const char* fmt...);
void OUT_NEWLINE();
void OUT_BUFFER();

FILE * parser_output;
size_t fbracket_depth   = 0;
char * buffer           = NULL;
bool buffer_mode_active = false;

%}

%union {
  char c_value[32];
}

%token _IF _ELSE _WHILE _FOR

%token<c_value> _ID _INT _FLOAT _TYPE

%token _PLUS _MINUS _MULTIPLY _DIVIDE _BR_OPEN _BR_CLOSE

%token _LESS _MORE _EQUALS _nEQUALS _LoE _MoE _EQUAL _AND _OR _NOT

%token _COMMA _SEMILICON _fBR_OPEN _fBR_CLOSE

%left _EQUALS _nEQUALS
%left _LoE _MoE _LESS _MORE
%left _PLUS _MINUS
%left _MULTIPLY _DIVIDE

%start program

%%

program:
  stmts
;

stmts:
| stmt _SEMILICON { OUT_NEWLINE(); } stmts
| { OUT("if"); }    cond_stmt  stmts
| { OUT("while"); } while_stmt stmts
|                   for_stmt   stmts
;

figured_stmts:
  _fBR_OPEN  { fbracket_depth++; }
  stmts
  _fBR_CLOSE { fbracket_depth--; }
;

stmt:
| _TYPE addition_type _ID _EQUAL { OUT("%s = ", $3); } expr
| _ID _EQUAL                     { OUT("%s = ", $1); } expr
| _TYPE addition_type _ID
| expr
;

addition_type:
| _TYPE addition_type
;

cond_stmt:
  _IF rounded_expr figured_stmts { OUT("else"); OUT_NEWLINE(); }
  else_stmt                      { OUT("end"); OUT_NEWLINE();  }

| _IF rounded_expr figured_stmts { OUT("end"); OUT_NEWLINE(); }

| _IF rounded_expr stmt _SEMILICON { OUT_NEWLINE(); OUT("else"); OUT_NEWLINE(); }
  else_stmt                        { OUT_NEWLINE(); OUT("end");  OUT_NEWLINE(); }

| _IF rounded_expr stmt _SEMILICON { OUT_NEWLINE(); OUT("end");  OUT_NEWLINE(); }
;

else_stmt:
  _ELSE figured_stmts
| _ELSE stmt _SEMILICON
;

while_stmt:
  _WHILE rounded_expr figured_stmts   { OUT("end"); OUT_NEWLINE(); }

| _WHILE rounded_expr stmt _SEMILICON { OUT_NEWLINE(); OUT("end"); OUT_NEWLINE(); }
;

for_stmt:
  for_while_stmt
  stmt _SEMILICON { OUT_NEWLINE(); buffer_mode_active = true;  }
  stmt _BR_CLOSE  { OUT_NEWLINE(); buffer_mode_active = false; }
  stmt_code       { OUT_BUFFER(); OUT("end"); OUT_NEWLINE(); }
;

stmt_code:
  figured_stmts
| stmt _SEMILICON
;

for_while_stmt:
  _FOR _BR_OPEN stmt _SEMILICON { OUT_NEWLINE(); OUT("while "); }
;

expr:
  number
| _ID { OUT("%s", $1); }
| func_call
| expr operator expr
| rounded_expr
| _NOT { OUT("!"); } expr
;

rounded_expr:
  _BR_OPEN { OUT(" "); } expr _BR_CLOSE { OUT(" "); OUT_NEWLINE(); }
;

number: 
  _INT   { OUT("%s", $1); }
| _FLOAT { OUT("%s", $1); }
;

operator: 
  _OR       { OUT(" || "); }
| _AND      { OUT(" && "); }
| _EQUALS   { OUT(" == "); }
| _nEQUALS  { OUT(" != "); }
| _LESS     { OUT(" < ");  }
| _MORE     { OUT(" > ");  }
| _LoE      { OUT(" <= "); }
| _MoE      { OUT(" >= "); }
| _PLUS     { OUT(" + ");  }
| _MINUS    { OUT(" - ");  }
| _MULTIPLY { OUT(" * ");  }
| _DIVIDE   { OUT(" / ");  }
;

func_call:
  _ID _BR_OPEN { OUT("%s(", $1); } func_args _BR_CLOSE { OUT(")"); }
;

func_args:
| expr _COMMA { OUT(", "); } func_args
| expr
;

%%

int main() {
  yyin          = fopen("examples/code", "r");
  parser_output = fopen("output.rb", "w");

  buffer = (char *) malloc(BUFFER_SIZE);

  yyparse();

  #ifdef DEBUG_LEX
  printf("\n");
  #endif

  fclose(yyin);
  fclose(parser_output);
  free(buffer);
}

void yyerror(const char* s) {
  fprintf(stderr, "Bison error: %s\n", s);
  exit(1);
}

void OUT_NEWLINE() {
  OUT("\n");
  // for (size_t i = 0; i < fbracket_depth; i++) {
  //   OUT("\t");
  // }
}

void OUT(const char * fmt...) {
  // variadic function in printf style for printing in file
  va_list args;
  va_start(args, fmt);

  if (buffer_mode_active) {
    char cbuffer[256];
    vsprintf(cbuffer, fmt, args);
    strcat(buffer, cbuffer);
  } else {
    vfprintf(parser_output, fmt, args);
  }
}

void OUT_BUFFER() {
  // output buffer to target file and clear it
  fprintf(parser_output, "%s", buffer);
  buffer[0] = '\0';
}