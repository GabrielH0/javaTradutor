%{
#include <stdio.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern int g_scope;
extern VAR *SymTab;
#define UNDECL  0
#define CHAR    1
#define FLO     2
#define BOOL    3
#define AddVAR(n,t) SymTab=MakeVAR(n,t,SymTab)
#define removeFunctionScope() SymTab=removeFunctionScope(SymTab)
#define ASSERT(x,y) if(!(x)) printf("%s na  linha %d ",(y),yylineno)
%}
%define parse.error verbose
%union {
	char * ystr;
    int   yint;
}
%start program
%token CLASS MAIN FOR
%token <ystr> IDENTIFIER
%token PUBLIC PRIVATE
%token STATIC
%token VOID
%token STR ARRAY FLT
%token ASSGNOP NEW SYSTEM OUT PRINTLN IN READ
%token <ystr> TEXT
%token <yint> NUMBER_FLOAT
%token MAIORIGUAL IGUAL DIFERENTE MENORIGUAL MAISIGUAL
%left '>' '<' '=' MAIORIGUAL MENORIGUAL
%left '-' '+'
%left '*' '/'
%left '^'
%type <yint>  exp


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
| STR IDENTIFIER variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} else {
		AddVAR($2, CHAR);
	}
}
| STR IDENTIFIER ASSGNOP TEXT variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);
	
}
| FLT IDENTIFIER variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);
	
}
| FLT IDENTIFIER ASSGNOP NUMBER_FLOAT variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);
}
;

method: /* empty */
| STR IDENTIFIER'(' param ')' '{' methodScope '}'
| FLT IDENTIFIER '(' param ')' '{' methodScope '}' 

variableExtendStr: /* empty */
| ',' IDENTIFIER variableExtendStr{
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);
}
| ',' IDENTIFIER ASSGNOP TEXT variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);	
}
;

variableExtendFloat: /* empty */
| ',' IDENTIFIER variableExtendFloat{
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);
	
}
| ',' IDENTIFIER ASSGNOP NUMBER_FLOAT variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} 
	AddVAR($2, FLO);
}
;

mainMethod: STATIC VOID MAIN '('STR ARRAY IDENTIFIER')' '{'methodScope '}'
;

methodScope: /* empty */
| methodScope operations ';'
;

operations:
variable_declaration
| IDENTIFIER ASSGNOP exp {
    VAR *p = FindVAR($1);
	ASSERT( (p!=NULL),"Identificador Não declarado");
    if (p!=NULL && p->type != $3 ) {
        printf("Tipos incompativeis de dados");
    }
}
| IDENTIFIER ASSGNOP SYSTEM '.' IN '.' READ '(' ')'
| SYSTEM '.' IN '.' READ '(' ')'
| FOR '(' forVariable ';' exp {
    ASSERT( ($5==BOOL), "Tipo incompativel de dados");
} ';' incFor ')' '{' methodScope '}' 
| SYSTEM '.' OUT '.' PRINTLN '('exp')'
;


exp :  NUMBER_FLOAT
| TEXT {
    $$ = CHAR;
}
| IDENTIFIER {
    VAR *p = FindVAR($1);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type:UNDECL; 
}
| IDENTIFIER '.' IDENTIFIER'(' expList ')' {
    VAR *p = FindVAR($3);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type : UNDECL;
}
| NEW IDENTIFIER '(' ')' {
    VAR *p = FindVAR($2);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type:UNDECL; 
}
| exp MAIORIGUAL exp { $$ = BOOL; }
| exp MENORIGUAL exp { $$ = BOOL; }
| exp '<' exp { $$ = BOOL; }
| exp IGUAL exp { $$ = BOOL; }
| exp '>' exp { $$ = BOOL; }
| exp '&' '&' exp { $$ = BOOL; }
| exp '|' '|' exp { $$ = BOOL; }
| '!' exp { $$ = BOOL; }
| exp DIFERENTE exp { $$ = BOOL; }
| exp '+' exp {
    if ($1 == CHAR || $3 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '-' exp {
    if ($1 == CHAR || $3 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '*' exp {
    if ($1 == CHAR || $3 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '/' exp {
    if ($1 == CHAR || $3 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}

expList: /* empty */
| exp expExtended
;

expExtended: /* empty */
| ',' exp
;

incFor: IDENTIFIER '+' '+' {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
}
| '+' '+' IDENTIFIER {
    VAR *p=FindVAR($3);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
}
| IDENTIFIER MAISIGUAL exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
}
| IDENTIFIER ASSGNOP exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && (p->type==$3)), "Tipos incompativeis de dados");
}
;

forVariable: IDENTIFIER {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
}
| IDENTIFIER  ASSGNOP exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
	if (p!=NULL) {
        ASSERT( (p->type == $3), "Tipos incompativeis de dados");
    }
	AddVAR($1, FLO);
	
}
| FLT IDENTIFIER {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} else {
		AddVAR($2, FLO);
	}
}
| FLT IDENTIFIER ASSGNOP exp {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} else if (p!=NULL) {
        ASSERT( (p->type == $4), "Tipos incompativeis de dados");
    }
	AddVAR($2, FLO);
	
}
;

%%

main( int argc, char *argv[] )
{
    init_stringpool(10000);
    if ( yyparse () == 0) printf("codigo sem erros sintáticos");

}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


