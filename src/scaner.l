%option noyywrap

%{

#include "../src/config.h"
#include <stdio.h>
#include "parser.tab.h"

#define YY_DECL int yylex()
#ifdef DEBUG
  #define LOG(...) printf(__VA_ARGS__)
#else
  #define LOG
#endif

%}

digit          [0-9]
alpha          [a-zA-Z_]
digit_or_alpha [a-zA-Z0-9_]

%%

[ \t\n] ; // ignore all whitespace

"if"    { LOG("IF ");    return _IF;    }
"else"  { LOG("ELSE ");  return _ELSE;  }
"while" { LOG("WHILE "); return _WHILE; }
"for"   { LOG("FOR ");   return _FOR;   }


{alpha}{digit_or_alpha}* { LOG("ID %s ", yytext); return _ID; }

{digit}+\.{digit}+ { LOG("FLOAT %s ", yytext);   return _FLOAT; }
{digit}+           { LOG("INTEGER %s ", yytext); return _INT;   }


"+" { LOG("PLUS ");          return _PLUS;     }
"-" { LOG("MINUS ");         return _MINUS;    }
"*" { LOG("MULTIPLY ");      return _MULTIPLY; }
"/" { LOG("DIVIDE ");        return _DIVIDE;   }
"(" { LOG("BRACKET OPEN ");  return _BR_OPEN;  }
")" { LOG("BRACKET CLOSE "); return _BR_CLOSE; }


"<"  { LOG("LESS ");           return _LESS;   }
">"  { LOG("MORE ");           return _MORE;   }
"==" { LOG("IS EQUALS ");      return _EQUALS; }
"<=" { LOG("LESS OR EQUALS "); return _LoE;    }
">=" { LOG("MORE OR EQUALS "); return _MoE;    }
"="  { LOG("EQUALS ");         return _EQUAL;  }
"&&" { LOG("AND ");            return _AND;    }
"||" { LOG("OR ");             return _OR;     }
"!"  { LOG("NOT ");            return _NOT;    }


";" { LOG("SEMILICON ");       return _SEMILICON; } // syntax
"{" { LOG("F_BRACKET OPEN ");  return _fBR_OPEN;  }
"}" { LOG("F_BRACKET CLOSE "); return _fBR_CLOSE; }


. { LOG("%s\n", yytext); } // other

%%