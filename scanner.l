%{
#include "parser.tab.h"
char *stringpool(char *);
%}
%option yylineno

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
"[]" {printf("array "); return(ARRAY);}
{ID} { printf("identificador "); return(IDENTIFIER);}
"\n"     { printf("\n");}
[ \t]+
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%
