%{

/************************
---      includes     ---
************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

FILE * parser_output;
#define OUT(...) fprintf(parser_output, __VA_ARGS__)

size_t fbracket_depth = 0;
void OUT_NEWLINE();

%}

%union {
  char        c_value[32];
  long long   i_value;
  long double f_value;
}

%token _IF _ELSE _WHILE _FOR

%token<c_value> _ID
%token<c_value> _INT
%token<c_value> _FLOAT
%token<c_value> _TYPE

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
| stmt _SEMILICON { OUT(";"); OUT_NEWLINE(); } stmts
| { OUT("if"); } cond_stmt stmts
| { OUT("while"); } while_stmt stmts
;

figured_stmts:
  _fBR_OPEN { OUT("{"); OUT_NEWLINE(); fbracket_depth++; }
  stmts
  _fBR_CLOSE { OUT("}"); OUT_NEWLINE(); fbracket_depth--; }
;

stmt:
  _TYPE _ID _EQUAL { OUT("%s %s = ", $1, $2); } expr
| expr
;

cond_stmt:
  _IF rounded_expr figured_stmts
| _IF rounded_expr stmt _SEMILICON { OUT(";"); OUT_NEWLINE(); }
;

while_stmt:
  _WHILE rounded_expr figured_stmts
| _WHILE rounded_expr stmt _SEMILICON { OUT(";"); OUT_NEWLINE(); }
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
  _BR_OPEN { OUT(" ("); } expr _BR_CLOSE { OUT(") "); }
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
|  expr _COMMA { OUT(", "); } func_args
| expr
;

%%

int main() {
  yyin          = fopen("examples/code3", "r");
  parser_output = fopen("output", "w");

  yyparse();

  #ifdef DEBUG_LEX
  printf("\n");
  #endif

  fclose(yyin);
  fclose(parser_output);
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
