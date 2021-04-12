%option noyywrap

%{

#include "../src/config.h"
#include <stdio.h>
#include "parser.tab.h"

#ifdef DEBUG_LEX
  #define LOG(...) printf(__VA_ARGS__)
#else
  #define LOG
#endif

void lexerror(const char * s);

%}

digit          [0-9]
alpha          [a-zA-Z_]
digit_or_alpha [a-zA-Z0-9_]

%x C_COMMENT

%%

\/\/[^\n]*\n? { LOG("COMMENT %s", yytext); }

"/*"            { BEGIN(C_COMMENT); LOG("COMMENT %s", yytext); }
<C_COMMENT>"*/" { BEGIN(INITIAL);   LOG("%s", yytext); }
<C_COMMENT>\n   { }
<C_COMMENT>.    {                   LOG("%s", yytext); }

[ \t\n] ; // ignore all whitespaces and breaklines

"if"    { LOG("IF ");    return _IF;    }
"else"  { LOG("ELSE ");  return _ELSE;  }
"while" { LOG("WHILE "); return _WHILE; }
"for"   { LOG("FOR ");   return _FOR;   }

"char"     { LOG("CHAR ");     sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"short"    { LOG("SHORT ");    sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"signed"   { LOG("SIGNED ");   sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"unsigned" { LOG("UNSIGNED "); sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"int"      { LOG("INT ");      sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"long"     { LOG("LONG ");     sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"float"    { LOG("FLOAT ");    sscanf(yytext, "%s", yylval.c_value); return _TYPE; }
"double"   { LOG("DOUBLE ");   sscanf(yytext, "%s", yylval.c_value); return _TYPE; }

{alpha}{digit_or_alpha}* {
  LOG("ID %s ", yytext);
  sscanf(yytext, "%s", yylval.c_value);
  return _ID;
}

{digit}+\.{digit}+ {
  LOG("FLOAT %s ", yytext);
  #ifndef NUM_AS_STR
    char * p_end;
    yylval.f_value = strtold(yytext, &p_end);
  #else
    sscanf(yytext, "%s", yylval.c_value);
  #endif
  return _FLOAT;
}
{digit}+ {
  LOG("INTEGER %s ", yytext);
  #ifndef NUM_AS_STR
    char * p_end;
    yylval.i_value = strtoll(yytext, &p_end, 10);
  #else
    sscanf(yytext, "%s", yylval.c_value);
  #endif
  return _INT;
}


"+" { LOG("PLUS ");          return _PLUS;     }
"-" { LOG("MINUS ");         return _MINUS;    }
"*" { LOG("MULTIPLY ");      return _MULTIPLY; }
"/" { LOG("DIVIDE ");        return _DIVIDE;   }
"(" { LOG("BRACKET OPEN ");  return _BR_OPEN;  }
")" { LOG("BRACKET CLOSE "); return _BR_CLOSE; }


"<"  { LOG("LESS ");           return _LESS;    }
">"  { LOG("MORE ");           return _MORE;    }
"==" { LOG("IS EQUALS ");      return _EQUALS;  }
"!=" { LOG("ISN'T EQUALS ");   return _nEQUALS; }
"<=" { LOG("LESS OR EQUALS "); return _LoE;     }
">=" { LOG("MORE OR EQUALS "); return _MoE;     }
"="  { LOG("EQUALS ");         return _EQUAL;   }
"&&" { LOG("AND ");            return _AND;     }
"||" { LOG("OR ");             return _OR;      }
"!"  { LOG("NOT ");            return _NOT;     }


"," { LOG("COMMA ");           return _COMMA;     }
";" { LOG("SEMILICON ");       return _SEMILICON; } 
"{" { LOG("F_BRACKET OPEN ");  return _fBR_OPEN;  }
"}" { LOG("F_BRACKET CLOSE "); return _fBR_CLOSE; }


. { lexerror("Unexpected character"); }

%%

void lexerror(const char * s) {
  fprintf(stderr, "Flex error: %s\n", s);
  exit(1);
}