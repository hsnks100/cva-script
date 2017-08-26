%{
    void yyerror(char *);
    int yylex(void);
    int sym[26];
#include <iostream>
#include <map>
#include <string>
#include <string.h>
#include "node.h"
    std::map<std::string, resultType> symbols;

#include <stdio.h>
#include <stdarg.h>
#define klog printf
    #define klog {}
    bool isVoid = false;

    /* prototypes */
    nodeType *opr(int oper, int nops, ...);
    nodeType *id(char* i);
    nodeType *con(int value);
    nodeType *con_str(std::string value){
        nodeType *p;

        /* allocate node */
        if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
            yyerror("out of memory");

        klog("con_str  addr %x, value %s\n", p, value.c_str());
        /* copy information */
        p->type = typeConStr;
        p->con.const_str = strdup(value.c_str());

        return p;
    }
    void freeNode(nodeType *p);
    resultType ex(nodeType *p, int d);
    int depth=0;

    /* #define printf(...) {} */

    %}

%union {
    long int4;              /* Constant integer value */
    float fp;               /* Constant floating point value */
    char *str;              /* Ptr to constant string (strings are malloc'd) */
    nodeType *nPtr;        /* node pointer */ 
}

%token <str> ID 
%token <str> STRING 

%token	<fp>		 NUMBER
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
%type	<nPtr> expression_statement expression 
%type	<nPtr> compound_statement

%%
function:
function statement         {

    klog("new ex %x\n", $2);
    ex($2, 1);
    klog("end ex\n");
    freeNode($2); }
| /* NULL */
;
statement_list
: statement_list statement {
    $$ = opr(';', 2, $1, $2);
}
| statement {
    $$ = $1;
  }
;

statement
: compound_statement
| expression_statement
| selection_statement
| PRINT expression ';'                 {
    klog("opr(PRINT)\n");
    $$ = opr(PRINT, 1, $2); }
/* | iteration_statement */
;
compound_statement
: '{' '}' {
    $$ = con(1004);
}
| '{'  statement_list '}'
;

expression_statement
: ';'{

    klog("opr(;)\n");
    $$ = opr(';', 2, NULL, NULL);
}
| expression ';' {

    klog("expression ;\n");

    $$ = $1;
  }
;

expression : expression '+' expression
| expression '-' expression
| expression '*' expression
| expression '/' expression
| expression EQ expression          {
    $$ = opr(EQ, 2, $1, $3);
}
| ID '=' expression {
    klog("assingn\n");
    /* std::cout << $3; */
    /* symbols[$1] = $3; */
    /* $$ = $3; */
    auto _id = id($1);
    klog("opr(=) %x, %x\n", _id, $3);
    $$ = opr('=', 2, _id, $3);
    isVoid = false; 
  }
| ID {
    /* $$ = symbols[$1]; */
    $$ = id($1);
    klog("ID %s\n", $1);

    isVoid = false;
  }
| NUMBER {
    /* $$ = $1; */
    klog("con(%d)\n", (int)$1);
    $$ = con((int)$1);
    /* klog("number %x\n", $$); */
    isVoid = false;
  }
| STRING {
    klog("STRING... %s\n", $1);
    $$ = con_str($1); 
  }

| PRINTALL {
    /* for(auto i : symbols){ */
    /*     std::cout << i.first << " : " << i.second << std::endl; */
    /* } */
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

    klog("con  addr %x, value %d\n", p, value);
    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(char* i) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    klog("id %x\n", p);

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
    klog("opr addr %x\n", p);

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
    klog("free addr %x\n", p);
    if(p->type == typeConStr) {
        free(p->con.const_str);
    }
    free (p);
}
resultType ex(nodeType *p, int d) {
    for(int i=0; i<d; i++) klog(">");
    klog("\n");
    
    klog("ex ___ %x\n", p);
    klog("ex ___ enter\n");
    if (!p) {
        return resultType{0, ""};
    }
    switch(p->type) {
    case typeCon:
        /* klog("ex ___ typeCon %d\n", p->con.value); */
        return resultType{p->con.value, ""};
    case typeConStr:
        /* klog("ex ___ typeConStr %s\n", p->con.const_str.c_str()); */
        return resultType{0, p->con.const_str};
    case typeId:
        /* klog("ex ___ typeId\n"); */
        /* return p; */
        return symbols[p->id.i]; /**/
    case typeOpr:
        /* klog("ex ___ typeOpr\n"); */
        switch(p->opr.oper) {
        case IF:
            {
                /* klog("ex ___ if\n"); */
                auto condEx = ex(p->opr.op[0], d+1);
                auto falseCond = condEx.number == 0 && condEx.str == "";
                if (!falseCond)
                    ex(p->opr.op[1], d+1);
                else if (p->opr.nops > 2)
                    ex(p->opr.op[2], d+1);
                return resultType{0, ""};
            }
        case PRINT:
            {
                auto retType = ex(p->opr.op[0], d+1);
                if (retType.number != 0)
                    printf(">>>>>> %lf\n", retType.number);
                if (retType.str != "")
                    printf(">>>>>> %s\n", retType.str.c_str());
            }
            return resultType{0, ""};
        case ';':
            ex(p->opr.op[0], d+1);
            return ex(p->opr.op[1], d+1);
        case '=':
            return symbols[p->opr.op[0]->id.i] = ex(p->opr.op[1], d+1);
        case EQ:
            {
                auto left = ex(p->opr.op[0], d+1);
                auto right = ex(p->opr.op[1], d+1);
                if(left.number == right.number && left.str == right.str) {
                    return resultType{1, ""};
                }
                else{
                    return resultType{0, ""};
                }
            }
        }

    }
    return resultType{0, ""};
}
void yyerror(char *s)
{
    std::cout << "hhh" << std::endl;

    printf("%s\n", s);
}

int main(void)
{
    printf("------------------------------------------\n");
    yyparse();
    return 0;
}
	
