%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE * yyin;

void yyerror(const char * s);

%}

%union {
  char        name[32];
  long long   i_value;
  long double f_value;
}

%token _IF _ELSE _WHILE _FOR

%token<char>       _ID
%token<long long>  _INT
%token<long doble> _FLOAT

%token _PLUS _MINUS _MULTIPLY _DIVIDE _BR_OPEN _BR_CLOSE

%token _LESS _MORE _EQUALS _LoE _MoE _EQUAL _AND _OR _NOT

%token _SEMILICON _fBR_OPEN _fBR_CLOSE

%start program

%%

program:
  stmts
;

stmts:
| stmt _SEMILICON stmts
;

stmt:
  _ID _EQUAL expr
| _IF _BR_OPEN expr _BR_CLOSE _fBR_OPEN stmts _fBR_CLOSE
;

expr:
  number
| expr operator expr
;

number: 
  _INT
| _FLOAT
;

operator: 
  _PLUS
| _MINUS
| _MULTIPLY
| _DIVIDE
| _LESS
| _MORE
| _EQUALS
| _LoE
| _MoE
| _EQUAL
| _AND
| _OR
| _NOT
;

%%

int main() {
	yyin = fopen("examples/code1", "r");

	yyparse();

  printf("\n");
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}