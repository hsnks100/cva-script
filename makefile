CC = g++
LIBS = -lfl
LEX = flex
YACC = bison
CFLAGS = -DYYDEBUG=1 -std=c++14

files = parser.tab.c lex.yy.c AST.c AST.h interp.c interp_expr.c

includes = $(wildcard ./*.h)

all: speech
speech: $(files) $(includes)
	$(CC) -o cva-script $(files) $(LIBS) $(CFLAGS)



lex.yy.c : lexer.l
	$(LEX) lexer.l
parser.tab.c: parser.y
	$(YACC) -d parser.y


clean: 
	rm -rf *.tab.c *.tab.h lex.yy.c 
