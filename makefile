CC = g++
LIBS = -lfl
LEX = flex
YACC = bison
CFLAGS = -DYYDEBUG=1 -std=c++14
all: speech
speech: parser.tab.c lex.yy.c
	$(CC) -o speech parser.tab.c lex.yy.c $(LIBS) $(CFLAGS)
lex.yy.c : lexer.ll
	                $(LEX) lexer.ll
parser.tab.c: parser.y
	                $(YACC) -d parser.y

clean: 
	rm -rf lex.yy.c parser.tab.c parser.tab.h 
