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
| PUBLIC variable ';' classScope
| PRIVATE variable ';' classScope
| PUBLIC method classScope
| PRIVATE method classScope
| PUBLIC mainMethod classScope
;

param : /* empty */ 
| FLT IDENTIFIER paramExtend  
| STR IDENTIFIER paramExtend
;

paramExtend:/* empty */
| ',' param
 ;

variable: /* empty */
| STR IDENTIFIER variableExtend
| FLT IDENTIFIER variableExtend
;

method: /* empty */
| STR IDENTIFIER'(' param ')' '{' methodScope '}'
| FLT IDENTIFIER '(' param ')' '{' methodScope '}' 

variableExtend: /* empty */
| ',' IDENTIFIER;

mainMethod: STATIC VOID MAIN '('STR ARRAY IDENTIFIER')' '{' '}'
;

methodScope: /* empty */
| methodScope operations ';'
;

operations:
variable
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


