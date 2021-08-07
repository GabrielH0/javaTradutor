%{
#include <stdio.h>
#include <ctype.h>
extern int yylineno;
%}
%define parse.error verbose
%start program
%token CLASS IDENTIFIER MAIN
%token PUBLIC PRIVATE
%token STATIC
%token VOID
%token STR ARRAY FLT



%%

program: PUBLIC CLASS IDENTIFIER '{' classScope '}' ||
CLASS IDENTIFIER '{' classScope '}'
;

classScope: /* empty */ 
| PUBLIC STR IDENTIFIER ';' classScope
| PUBLIC FLT IDENTIFIER ';' classScope
| PRIVATE STR IDENTIFIER ';' classScope
| PRIVATE FLT IDENTIFIER ';' classScope
| PRIVATE STR IDENTIFIER '(' param ')' '{' '}' classScope
| PUBLIC STR IDENTIFIER '(' param ')' '{' '}' classScope
| PRIVATE FLT IDENTIFIER '(' param ')' '{' '}' classScope
| PUBLIC FLT IDENTIFIER '(' param ')' '{' '}' classScope
| PUBLIC mainMethod classScope
;

param : /* empty */ 
| FLT IDENTIFIER paramExtend  
| STR IDENTIFIER paramExtend
;

paramExtend:/* empty */
| ',' param


mainMethod: STATIC VOID MAIN '('STR ARRAY IDENTIFIER')' '{' '}'
;


%%

main( int argc, char *argv[] )
{
  
if ( yyparse () == 0) printf("codigo sem erros sintáticos");

}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


