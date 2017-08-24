%{

    void yyerror(char *);
    int yylex(void);
    int sym[26];
#include <iostream>
#include <map>
#include <string>
    std::map<std::string, double> symbols;

#include <stdio.h>
    %}

%token PLUS NEWLINE ASSIGN
%union
{
        long int4;              /* Constant integer value */
        float fp;               /* Constant floating point value */
        char *str;              /* Ptr to constant string (strings are malloc'd) */
}

%token <fp> NUMBER
%token <str> ID
%type	<fp>		expr
%type	<fp>		statement
/* %type <fp> NUMBER */

%%
program:	 program statement NEWLINE {
    printf("expr = %f\n", $2);
    printf(">>");
 }
|NEWLINE { 
    }
|		
;

statement:	ID ASSIGN expr{
    printf("assign!!\n");
    symbols[$1] = $3;
    $$ = $3;
 }
|	expr
|
;
expr:
expr PLUS expr {
    std::cout << $1 + $3 << std::endl;
    $$ = $1 + $3;
    }
| ID{
    
    std::cout << "var(" << $1 << ")" << " : " << symbols[$1] << std::endl;
    $$ = symbols[$1];
    }
| NUMBER {
    $$ = $1;
    }
;

%%
#include <iostream>

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
	
