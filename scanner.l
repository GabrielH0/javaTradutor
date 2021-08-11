%{
#include "parser.tab.h"
char *stringpool(char *);
%}
%option yylineno

DIGIT    [0-9]
TEXT    ["]+[_A-Za-z0-9]*["]+
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

class { printf("class "); return(CLASS);}
public {printf("modificador "); return(PUBLIC);}
private {printf("modificador "); return(PRIVATE);}
main { printf("main "); return(MAIN);}
static {printf("static "); return(STATIC);}
void {printf("tipo "); return(VOID);}
String {printf("tipo "); return(STR);}
float {printf("tipo "); return(FLT);}
new {printf("new "); return(NEW);}
for {printf("for "); return(FOR);}
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real "); return(NUMBER_FLOAT);   }
{TEXT} {printf("texto "); return(TEXT);}
">="    { printf(">= "); return(MAIORIGUAL);  }
"<="    { printf("<= "); return(MENORIGUAL);  }
"=="    { printf("== "); return(IGUAL); }     
"!="    {printf("!= "); return(DIFERENTE);}
"+="    {printf("+= "); return(MAISIGUAL);}
"=" {printf("atribuicao "); return(ASSGNOP);}
"[]" {printf("array "); return(ARRAY);}
{ID} { printf("identificador "); return(IDENTIFIER);}
"\n"     { printf("\n");}
[ \t]+
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%
