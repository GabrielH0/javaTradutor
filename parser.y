%{
#include <stdio.h>
#include <ctype.h>
extern int yylineno;
%}
%define parse.error verbose
%start program
%token CLASS IDENTIFIER MAIN FOR
%token PUBLIC PRIVATE
%token STATIC
%token VOID
%token STR ARRAY FLT
%token ASSGNOP NEW SYSTEM OUT PRINTLN IN READ
%token TEXT
%token NUMBER_FLOAT
%token MAIORIGUAL IGUAL DIFERENTE MENORIGUAL MAISIGUAL


%%

program: PUBLIC CLASS IDENTIFIER '{' classScope '}' ||
CLASS IDENTIFIER '{' classScope '}'
;

classScope: /* empty */ 
| PUBLIC variable_declaration ';' classScope
| PRIVATE variable_declaration ';' classScope
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

variable_declaration: /* empty */
| STR IDENTIFIER variableExtend
| FLT IDENTIFIER variableExtend
;

method: /* empty */
| STR IDENTIFIER'(' param ')' '{' methodScope '}'
| FLT IDENTIFIER '(' param ')' '{' methodScope '}' 

variableExtend: /* empty */
| ',' IDENTIFIER;

mainMethod: STATIC VOID MAIN '('STR ARRAY IDENTIFIER')' '{'methodScope '}'
;

methodScope: /* empty */
| methodScope operations ';'
;

operations:
variable_declaration
| IDENTIFIER ASSGNOP exp
| IDENTIFIER ASSGNOP SYSTEM '.' IN '.' READ '(' ')'
| SYSTEM '.' IN '.' READ '(' ')'
| FOR '(' FLT IDENTIFIER ';' exp ';' incFor ')' '{' methodScope '}' 
| SYSTEM '.' OUT '.' PRINTLN '('exp')'
;


exp :  NUMBER_FLOAT
| TEXT
| IDENTIFIER 
| IDENTIFIER '.' IDENTIFIER'(' expList ')'
| NEW IDENTIFIER '(' ')'
| exp MAIORIGUAL exp
| exp MENORIGUAL exp
| exp '<' exp
| exp '=' exp
| exp '>' exp
| exp '+' exp
| exp '-' exp
| exp '*' exp
| exp '/' exp
| exp '&' '&' exp
| exp '|' '|' exp
| '!' exp
| exp IGUAL exp
| exp DIFERENTE exp
;

expList: /* empty */
| exp expExtended
;

expExtended: /* empty */
| ',' exp
;

incFor: IDENTIFIER '+' '+'
| '+' '+' IDENTIFIER
| IDENTIFIER MAISIGUAL exp
| IDENTIFIER ASSGNOP exp
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


