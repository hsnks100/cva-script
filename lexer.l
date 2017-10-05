%{
#include <stdlib.h>
    void yyerror(char *);
#include "AST.h"
#include "parser.tab.h"

%}





alpha [a-zA-Z]
digit [0-9]

%%
return return RETURN;
for 	return FOR;
while	return WHILE;
if	return IF;
else	return ELSE;
struct 	return STRUCT;
var return VAR;
println return PRINTLN; 
number return TYPE_NUMBER;
string return TYPE_STRING;
^"#include ".+ ;
"<="    return LE;
">="    return GE;
"=="    return EQ;
"!="    return NE;
">"	return GT;
"<"	return LT;
\/\/.* ;

[ \t]		;
[ \n]   { yylineno = yylineno + 1;}

{digit}+(\.{digit}+)? {
    /* printf("input num = %s\n", yytext); */
    yylval.val = makeNum(atof(yytext));
    return NUMBER;
}

{alpha}({alpha}|{digit})* {
    yylval.val = makeSymbol(yytext);
    return SYMBOL;
}

"\"".*"\"" {
/* yyless('"'); */

    std::string cpy = yytext;
    yylval.val = makeStr(cpy.substr(1, cpy.size() - 2)); 
    /*strndup(yytext + 1, strlen(yytext) - 2));*/
    return STRING;
}
. {
    /* yymore(); */
    yyless(1);
    return yytext[0];
}

showAllSymbols; {
    return SHOWALLSYMBOLS; 
}

%%

int yywrap(void)
{
    return 1;
}

void yyerror(char*)
{
    printf("syntax error! line : %d\n", yylineno);

    exit(1);
}
