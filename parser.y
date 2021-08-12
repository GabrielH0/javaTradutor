%{
#include <stdio.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern int g_scope;
extern VAR *SymTab;
FILE * output;
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
	float yfloat;
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
%token <yfloat> NUMBER_FLOAT
%token MAIORIGUAL IGUAL DIFERENTE MENORIGUAL MAISIGUAL
%left '>' '<' '=' MAIORIGUAL MENORIGUAL
%left '-' '+'
%left '*' '/'
%left '^'
%type <yint>  exp


%%

program: {fprintf(output, "#include <iostream> \n#include <string> \nusing namespace std;\n"); } PUBLIC CLASS IDENTIFIER '{' {fprintf(output, "class %s {\n", $4);} classScope '}' { fprintf(output, "};"); }
| {fprintf(output, "#include <iostream> \n#include <string> \nusing namespace std;\n"); } CLASS IDENTIFIER '{' {fprintf(output, "class %s {\n", $3);} classScope '}' { fprintf(output, "};"); }
;

classScope: /* empty */ 
| PUBLIC { fprintf(output, "public: \n"); } declaration classScope 
| PRIVATE { fprintf(output, "private: \n"); } declaration classScope
;

declaration : variable_declaration ';' {fprintf(output, ";\n");}
| method
| mainMethod
;

param : /* empty */ 
| FLT IDENTIFIER paramExtend {fprintf(output, "float %s", $2);} 
| STR IDENTIFIER paramExtend {fprintf(output, "string %s", $2);}
;

paramExtend:/* empty */
| ',' param {fprintf(output, ", ");}
 ;

variable_declaration: /* empty */
| STR IDENTIFIER { fprintf(output, "string %s", $2); } variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} else {
		AddVAR($2, CHAR);
	}
}
| STR IDENTIFIER ASSGNOP TEXT { fprintf(output, "string %s = %s", $2, $4); } variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);
}
| FLT IDENTIFIER { fprintf(output, "float %s", $2); } variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);

}
| FLT IDENTIFIER ASSGNOP NUMBER_FLOAT { fprintf(output, "float %s = %4.2f", $2, $4); } variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);
}
;

method: /* empty */
| STR IDENTIFIER'(' { fprintf(output, "string %s (", $2); } param ')' {fprintf(output, ")");} '{' {fprintf(output, "{\n");} methodScope '}' {
    VAR *p= FindVAR($2);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    AddVAR($2, CHAR);
    fprintf(output, "}\n");
}
| FLT IDENTIFIER '(' { fprintf(output, "float %s (", $2); } param ')' {fprintf(output, ")");} '{' {fprintf(output, "{\n");} methodScope '}' {
    VAR *p= FindVAR($2);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    AddVAR($2, FLO);    
    fprintf(output, "}\n");
}

variableExtendStr: /* empty */ 
| ',' IDENTIFIER variableExtendStr{
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);
    { fprintf(output, ",%s", $2); }
}
| ',' IDENTIFIER ASSGNOP TEXT variableExtendStr {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, CHAR);	
    { fprintf(output, ",%s = %s", $2, $4); }
}
;

variableExtendFloat: /* empty */
| ',' IDENTIFIER variableExtendFloat{
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	}
	AddVAR($2, FLO);
	{ fprintf(output, ",%s", $2); }
}
| ',' IDENTIFIER ASSGNOP NUMBER_FLOAT variableExtendFloat {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} 
	AddVAR($2, FLO);
    { fprintf(output, ",%s = %4.2f", $2, $4); }
}
;

mainMethod: STATIC VOID MAIN '('STR ARRAY IDENTIFIER')' { fprintf(output, "int main () {\n"); }
 '{'methodScope '}' { fprintf(output, "}\n"); }

;

methodScope: /* empty */
| methodScope operations ';' {fprintf(output, ";\n");}
;

operations:
variable_declaration
| IDENTIFIER ASSGNOP { fprintf(output, "%s =", $1); } exp {
    VAR *p = FindVAR($1);
	ASSERT( (p!=NULL),"Identificador Não declarado");
    if (p!=NULL && p->type != $4 ) {
        printf("Tipos incompativeis de dados");
    }
}
| IDENTIFIER ASSGNOP SYSTEM '.' IN '.' READ '(' ')' { fprintf(output, "cin >> %s", $1); }
| FOR '(' { fprintf(output, "for ("); } forVariable ';' { fprintf(output, ";");} exp {
    ASSERT( ($7==BOOL), "Tipo incompativel de dados");
} ';' { fprintf(output, ";"); } incFor ')' { fprintf(output, ")"); } '{' { fprintf(output, "{\n "); } methodScope '}' { fprintf(output, "}\n");}
| SYSTEM '.' OUT '.' PRINTLN { fprintf(output, "cout <<"); } '('exp')'
;


exp :  NUMBER_FLOAT { fprintf(output, "%4.2f", $1);}
| TEXT {
    $$ = CHAR;
    fprintf(output, "%s", $1);
}
| IDENTIFIER {
    VAR *p = FindVAR($1);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type:UNDECL; 
    fprintf(output, "%s", $1);
}
| IDENTIFIER'(' { fprintf(output, "%s(", $1); } expList ')' { fprintf(output, ")"); } {
    VAR *p = FindVAR($1);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type : UNDECL;

}
| NEW IDENTIFIER '(' ')' {
    VAR *p = FindVAR($2);
    ASSERT( (p != NULL), "Identificador nao declarado");
    $$ = (p!=NULL) ? p->type:UNDECL; 
    fprintf(output, "new %s ()", $2);
}
| exp MAIORIGUAL { fprintf(output, ">=");} exp { $$ = BOOL; }
| exp MENORIGUAL { fprintf(output, "<=");} exp { $$ = BOOL; }
| exp '<' {fprintf(output, "<");} exp { $$ = BOOL; }
| exp IGUAL { fprintf(output, "==");} exp { $$ = BOOL; }
| exp '>' { fprintf(output, ">");} exp { $$ = BOOL; }
| exp '&' '&' { fprintf(output, "&&");} exp { $$ = BOOL; }
| exp '|' '|' {fprintf(output, "||");} exp { $$ = BOOL; }
| '!' { fprintf(output, "!"); } exp { $$ = BOOL; }
| exp DIFERENTE { fprintf(output, "!="); } exp { $$ = BOOL; }
| exp '+' {fprintf(output, "+");} exp {
    if ($1 == CHAR || $4 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '-' { fprintf(output, "-"); } exp {
    if ($1 == CHAR || $4 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '*' { fprintf(output, "*"); } exp {
    if ($1 == CHAR || $4 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}
| exp '/' { fprintf(output, "/"); } exp {
    if ($1 == CHAR || $4 == CHAR) {
        printf("Tipo incompativel de dados");
    } else { 
        $$ = FLO;
    }
}

expList: /* empty */
| exp expExtended
;

expExtended: /* empty */
| ',' exp { fprintf(output, ", "); }
;

incFor: IDENTIFIER '+' '+' {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
    fprintf(output, "%s++", $1 );
}
| '+' '+' IDENTIFIER {
    VAR *p=FindVAR($3);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
    fprintf(output, "++%s", $3 );
}
| IDENTIFIER MAISIGUAL { fprintf(output, "%s+=", $1 ); } exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && p->type==FLO), "Tipos incompativeis de dados");
}
| IDENTIFIER ASSGNOP { fprintf(output, "%s=", $1); } exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    ASSERT( (p!=NULL && (p->type==$4)), "Tipos incompativeis de dados");
}
;

forVariable: IDENTIFIER {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
    fprintf(output, "%s", $1);
}
| IDENTIFIER  ASSGNOP { fprintf(output, "%s = ", $1); } exp {
    VAR *p=FindVAR($1);
    ASSERT( (p!=NULL),"Identificador Não declarado");
	if (p!=NULL) {
        ASSERT( (p->type == $4), "Tipos incompativeis de dados");
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
    fprintf(output, "float %s", $2);
}
| FLT IDENTIFIER ASSGNOP { fprintf(output, "float %s = ", $2); } exp {
    VAR *p=FindVAR($2);
	if (p != NULL && p->scope == g_scope) {
		printf("Já existe uma variável declarada com esse nome");
	} else if (p!=NULL) {
        ASSERT( (p->type == $5), "Tipos incompativeis de dados");
    }
	AddVAR($2, FLO);
}
;

%%

main( int argc, char *argv[] )
{
    output= fopen("output.c++", "w");
    init_stringpool(10000);
    if ( yyparse () == 0) printf("codigo sem erros sintáticos");

}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


