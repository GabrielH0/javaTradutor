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
System  {printf("system"); return(SYSTEM);}
out {printf("out"); return(OUT);}
in  {printf("in"); return(IN);}
read    {printf("read"); return(READ);}
println {printf("println"); return(PRINTLN);}
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real "); yylval.yfloat = atof(yytext); return(NUMBER_FLOAT);   }
{TEXT} {printf("texto "); yylval.ystr = stringpool(yytext); return(TEXT);}
">="    { printf(">= "); return(MAIORIGUAL);  }
"<="    { printf("<= "); return(MENORIGUAL);  }
"=="    { printf("== "); return(IGUAL); }     
"!="    {printf("!= "); return(DIFERENTE);}
"+="    {printf("+= "); return(MAISIGUAL);}
"=" {printf("atribuicao "); return(ASSGNOP);}
"[]" {printf("array "); return(ARRAY);}
{ID} { printf("identificador "); yylval.ystr = stringpool(yytext); return(IDENTIFIER);}
"\n"     { printf("\n");}
"//"[A-Za-z0-9_+,.();= ]* {printf("Comentário"); }
[ \t]+
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%
