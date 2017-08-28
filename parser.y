%{
    void yyerror(char *);
    int yylex(void);
    int sym[26];
#include "node.h"
#include "interp.h"

    bool isVoid = false;


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
%token FUNCTION_CALL FUNCTION
 /* %type <fp> NUMBER */
%right '='
%left '<' '>' LE GE EQ NE LT GT
%left '+' '-'
%left '*' '/'
%type <nPtr> statement statement_list selection_statement iteration_statement
%type <nPtr> decl_statement
%type	<nPtr> expression_statement expression 
%type	<nPtr> compound_statement

%%
program:
program decl_statement{

    printf("function statement_list\n");
    /* printf("new ex %x\n", $2); */
    ex($2, 1);
    /* printf("end ex\n"); */
    freeNode($2); }
| program
        |       
             

;


decl_statement
: decl_list
| statement_list
;
decl_list
: decl_list decl {
    printf(": decl_list decl {\n");
}
| decl {
    printf(": decl\n");
} 
;

decl
: FUNCTION ID '(' ')' '{' statement_list '}' {
    printf(": FUNCTION ID '(' ')' '{' statement_list '}' {\n");
    /* $$ = opr(FUNCTION, 2, $2, $6); */
}


statement_list
: statement_list statement {
    printf("statement_list statement()\n");
    $$ = opr(';', 2, $1, $2);
}
| statement {
    printf("statement(last)\n");
    $$ = $1;
  }
;

statement
: compound_statement
| expression_statement
| selection_statement
| iteration_statement
| FUNCTION_CALL ID '(' ')' ';' {
    printf("| FUNCTION_CALL ID '(' ')' ';' {\n");
    }
| PRINT expression ';'                 {
    klog("opr(PRINT)\n");
    $$ = opr(PRINT, 1, $2); }
/* | iteration_statement */
|        
;
compound_statement
: '{' '}' {
    $$ = con(1004);
}
| '{'  statement_list '}' {
    $$ = $2;
    }
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

expression : expression '+' expression {
    $$ = opr('+', 2, $1, $3);
    }
| expression '-' expression
| expression '*' expression
| expression '/' expression
| expression LE expression          {
    $$ = opr(LE, 2, $1, $3);
}
| expression GE expression          {
    $$ = opr(GE, 2, $1, $3);
}
| expression EQ expression          {
    $$ = opr(EQ, 2, $1, $3);
}
| expression NE expression          {
    $$ = opr(NE, 2, $1, $3);
}
| expression GT expression          {
    $$ = opr(GT, 2, $1, $3);
}
| expression LT expression          {
    $$ = opr(LT, 2, $1, $3);
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

iteration_statement
: WHILE '(' expression ')' statement        {
    $$ = opr(WHILE, 2, $3, $5);
}
;


%%

int main(void)
{
    printf("------------------------------------------\n");
    yyparse();
    return 0;
}
	
