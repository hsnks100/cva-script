%{
    void yyerror(char *);
    int yylex(void);

#include <stdio.h>
#include "AST.h"

    /* #define printf(...) {} */

%}

	


/* tiny C parser */
%token NUMBER
%token SYMBOL
%token STRING
%token VAR
%token IF
%token ELSE
%token RETURN
%token WHILE
%token FOR
%token PRINTLN
%token STRUCT


%union {
    AST *val;
}

%right '='
%left LE GE EQ NE GT LT
%left '+' '-'
%left '*'

%type <val> parameter_list block local_vars symbol_list 
%type <val> statements statement expr primary_expr arg_list
%type <val> SYMBOL NUMBER STRING

%start program

%%

program: /* empty */
	| external_definitions
	;

external_definitions:
	  external_definition
	| external_definitions external_definition
	;

external_definition:
	  SYMBOL parameter_list block  /* fucntion definition */
	{ defineFunction(getSymbol($1),$2,$3); }
	| VAR SYMBOL ';'
	{ declareVariable(getSymbol($2),NULL); }
	| VAR SYMBOL '=' expr ';'
        { declareVariable(getSymbol($2),$4); }
	| VAR SYMBOL '[' expr ']' ';'
	{ declareArray(getSymbol($2),$4); }
	;

parameter_list:
	 '(' ')'
	 { $$ = NULL; }
	| '(' symbol_list ')' 
	 { $$ = $2; }
	;

block: '{' local_vars statements '}'
	{ $$ = makeAST(BLOCK_STATEMENT,$2,$3); }
	;

local_vars: 
	  /* NULL */ { $$ = NULL; }
	| VAR symbol_list ';'
	  { $$ = $2; }
	;

symbol_list: 
	  SYMBOL
	 { $$ = makeList1($1); }
	| symbol_list ',' SYMBOL
	 { $$ = addLast($1,$3); }
	;

statements:
	  statement
	 { $$ = makeList1($1); }
	| statements statement
	 { $$ = addLast($1,$2); }
	;

statement:
	 expr ';'
	 { $$ = $1; }
	| block
	 { $$ = $1; }
	| IF '(' expr ')' statement
	 { $$ = makeAST(IF_STATEMENT,$3,makeList2($5,NULL)); }
        | IF '(' expr ')' statement ELSE statement
	 { $$ = makeAST(IF_STATEMENT,$3,makeList2($5,$7)); }
	| RETURN expr ';'
	 { $$ = makeAST(RETURN_STATEMENT,$2,NULL); }
	| RETURN ';'
	 { $$ = makeAST(RETURN_STATEMENT,NULL,NULL); }
	| WHILE '(' expr ')' statement
	 { $$ = makeAST(WHILE_STATEMENT,$3,$5); }
	| FOR '(' expr ';' expr ';' expr ')' statement
	 { $$ = makeAST(FOR_STATEMENT,makeList3($3,$5,$7),$9); }
	;

expr: 	 primary_expr
	| SYMBOL '=' expr
	 { $$ = makeAST(EQ_OP,$1,$3); }
	| SYMBOL '[' expr ']' '=' expr
	 { $$ = makeAST(SET_ARRAY_OP,makeList2($1,$3),$6); }
	| expr '+' expr
	 { $$ = makeAST(PLUS_OP,$1,$3); }
	| expr '-' expr
	 { $$ = makeAST(MINUS_OP,$1,$3); }
	| expr '*' expr
	 { $$ = makeAST(MUL_OP,$1,$3); }
	| expr LT expr
	 { $$ = makeAST(LT_OP,$1,$3); }
	| expr GT expr
	 { $$ = makeAST(GT_OP,$1,$3); }
	;

primary_expr:
	  SYMBOL
	| NUMBER
	| STRING
	| SYMBOL '[' expr ']'
	  { $$ = makeAST(GET_ARRAY_OP,$1,$3); }
	| SYMBOL '(' arg_list ')'
	 { $$ = makeAST(CALL_OP,$1,$3); }
	| SYMBOL '(' ')'
	 { $$ = makeAST(CALL_OP,$1,NULL); }
        | '(' expr ')'
         { $$ = $2; }  
	| PRINTLN  '(' arg_list ')'
	 { $$ = makeAST(PRINTLN_OP,$3,NULL); }
	;

arg_list:
	 expr
	 { $$ = makeList1($1); }
	| arg_list ',' expr
	 { $$ = addLast($1,$3); }
	;

%%







#include <stdlib.h>
#include <stdio.h>
#include "interp.h"

main()
{
    int r;
    yyparse();

    /* execute main */
    printf("execute main ...\n");
    r = executeCallFunc(lookupSymbol("main"),NULL);
    printf("execute end ...\n");
    return r;
}

void error(char *msg)
{
    fprintf(stderr,"compiler error: %s",msg);
    exit(1);
}

