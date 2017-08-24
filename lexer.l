%{
#include <stdlib.h>
void yyerror(char *);
#include "parser.tab.h"

/* extern double yylval; */

%}
%%
[0-9]+ {
    yylval.fp = atoi(yytext);
    /* yylval =  */

    return NUMBER;
}

[+] {return PLUS;}
[\n] {return NEWLINE;}
= return ASSIGN;
[a-z]+ {
yylval.str = strdup(yytext);

return ID;
}

[ \t]   ;     /* 무시한다 */
.       yyerror("invalid character");
%%

int yywrap(void)
{
  return 1;
}
