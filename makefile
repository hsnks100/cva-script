CC = g++
LIBS = -ll
LEX = flex
YACC = bison
CFLAGS = -DYYDEBUG=1
all: speech
speech: parser.tab.c lex.yy.c
	$(CC) -o speech parser.tab.c lex.yy.c $(LIBS)
lex.yy.c : lexer.l
	                $(LEX) lexer.l
parser.tab.c: parser.y
	                $(YACC) -d parser.y

clean: 
	rm -rf lex.yy.c parser.tab.c parser.tab.h 
