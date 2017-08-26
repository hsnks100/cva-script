%{
#include <stdlib.h>
void yyerror(char *);
#include "node.h"
#include "parser.tab.h"

    /* extern double yylval; */

%}



alpha [a-zA-Z]
digit [0-9]

%%
for 	return FOR;
while	return WHILE;
if	return IF;
else	return ELSE;
struct 	return STRUCT;
print return PRINT;
printall return PRINTALL;
^"#include ".+ ;
"<="    return LE;
">="    return GE;
"=="    return EQ;
"!="    return NE;
">"	return GT;
"<"	return LT;
"."     return DOT;
"||"					{ return OR_OP; } 
\/\/.* ;

[ \t]		;
[ \n]   { yylineno = yylineno + 1;}

{digit}+(\.{digit}+)? {
    /* printf("input num = %s\n", yytext); */
    yylval.fp = atof(yytext);
    return NUMBER;
       }
{alpha}({alpha}|{digit})* {
    yylval.str = strdup(yytext);
    return ID;
       }

"\"".*"\"" {
/* yyless('"'); */
    yylval.str = strndup(yytext + 1, strlen(yytext) - 2); 
    return STRING;
}
. {
    /* yymore(); */
    yyless(1);
    return yytext[0];
}

%%

int yywrap(void)
{
    return 1;
}
