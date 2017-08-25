%{
    void yyerror(char *);
    int yylex(void);
    int sym[26];
#include <iostream>
#include <map>
#include <string>
    std::map<std::string, double> symbols;

#include <stdio.h>
#include <stdarg.h>
    bool isVoid = false;

#include "node.h"
/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
 int ex(nodeType *p, int d);
int depth=0;

%}

%union {
     long int4;              /* Constant integer value */
     float fp;               /* Constant floating point value */
     char *str;              /* Ptr to constant string (strings are malloc'd) */
     nodeType *nPtr;        /* node pointer */ 
}

%token <str> ID 
%token NUMBER
%token SEMI
%token FOR WHILE 
%token IF ELSE 
%token STRUCT 
%token INCLUDE
%token DOT
%token PRINTALL
%token PRINT
%token OR_OP
 /* %type <fp> NUMBER */
%right '='
%left '<' '>' LE GE EQ NE LT GT
%left '+' '-'
%left '*' '/'
%type <nPtr> statement statement_list selection_statement
%type	<nPtr> expression_statement expression NUMBER
%type	<nPtr> compound_statement
%type	<nPtr> list_statement

%%

statement_list : statement_list statement
| statement {
printf("new ex\n");
    
 ex($1, 1);
    freeNode($1);
    }
;

statement
: compound_statement
| expression_statement
| selection_statement
| PRINT expression ';'                 { $$ = opr(PRINT, 1, $2); }
  /* | iteration_statement */
;
compound_statement
: '{' '}' {
$$ = con(1004);
}
| '{'  list_statement '}' {
$$ = $2;
 }
;

list_statement
: list_statement statement
| statement
;


expression_statement
: ';'{
    $$ = opr(';', 2, NULL, NULL);
 }
| expression ';' {
    /* $$ = $1;  */
    /* if(!isVoid) { */
    /* 	std::cout << "expr => " << $1 << std::endl; } */
 }
;

expression : expression '+' expression
| expression '-' expression
| expression '*' expression
| expression '/' expression
| ID '=' expression {
    printf("assingn\n");
    std::cout << $3;
    /* symbols[$1] = $3; */
    $$ = $3;
    isVoid = false; 
 }
| ID {
    /* $$ = symbols[$1]; */
/* printf("number\n"); */

    isVoid = false;
  }
| NUMBER {
    /* $$ = $1; */
    $$ = con((int)88);
    printf("number %x\n", $$);
    isVoid = false;
  }
| PRINTALL {
    for(auto i : symbols){
	std::cout << i.first << " : " << i.second << std::endl;
    }
    isVoid = true;
  }
;

selection_statement
: IF '(' expression ')' statement ELSE statement {
    $$ = opr(IF, 3, $3, $5, $7);
    }
| IF '(' expression ')' statement {
    $$ = opr(IF, 2, $3, $5);
    }
; 

%%
#include <iostream>
nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    printf("con %x\n", p);
    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    printf("id %x\n", p);

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = (nodeType*)malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");
    printf("opr %x\n", p);

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}
int ex(nodeType *p, int d) {
    for(int i=0; i<d; i++) printf(">");
    printf("\n");
    
    printf("ex ___ %x\n", p);
    printf("ex ___ enter\n");
    if (!p) {
	return 0;
	}
    switch(p->type) {
    case typeCon:
	printf("ex ___ typeCon %d\n", p->con.value);
	return p->con.value;
    case typeId:
	printf("ex ___ typeId\n");
	return sym[p->id.i];
    case typeOpr:
	printf("ex ___ typeOpr\n");
        switch(p->opr.oper) {
        case IF:
	    printf("ex ___ if\n");
	    if (ex(p->opr.op[0], d+1))
		ex(p->opr.op[1], d+1);
	    else if (p->opr.nops > 2)
		ex(p->opr.op[2], d+1);
	    return 0;
	case PRINT:
	    printf("ex ___ %d\n", ex(p->opr.op[0], d+1)); return 0;
	case ';':
	    ex(p->opr.op[0], d+1);
	    return ex(p->opr.op[1], d+1);
        }
    }
    return 0;
}
void yyerror(char *s)
{
    std::cout << "hhh" << std::endl;

    printf("%s\n", s);
}

int main(void)
{
    printf(">>");
    yyparse();
    return 0;
}
	
