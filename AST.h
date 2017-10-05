#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <string>

#define FALSE 0
#define TRUE 1

void error(char *msg);
enum SYMBOL_TYPE {
    SYMBOL_NOINIT,
    SYMBOL_NUMBER,
    SYMBOL_STRING
} ;
enum code {
    LIST,
    NUM,
    STR,
    SYM,
    EQ_OP,
    PLUS_OP,
    MINUS_OP,
    MUL_OP,
    LT_OP,
    GT_OP,
    GET_ARRAY_OP,
    SET_ARRAY_OP,
    CALL_OP,
    PRINTLN_OP,
    IF_STATEMENT,
    BLOCK_STATEMENT,
    RETURN_STATEMENT,
    WHILE_STATEMENT,
    FOR_STATEMENT
};
  
class any {
    private:
        int num;
        std::string str;
        enum SYMBOL_TYPE type; 
    public:
        std::string toString() {
            switch(type) {
                case SYMBOL_NUMBER:
                    return std::to_string(num);
                    break;
                case SYMBOL_STRING:
                    return str;
                    break;
            }
        }
        any() : type(SYMBOL_NOINIT), num(77777), str("no init") {
        }
        any(int n) {
            num = n;
            type = SYMBOL_NUMBER; 
        }
        any(const std::string& n) {
            str = n;
            type = SYMBOL_STRING; 
        }
        int getNum() const { return num; }
        std::string getStr() const { return str; }
        SYMBOL_TYPE getType() const { return type; }
        void setType(SYMBOL_TYPE st) { this->type = st; }
        //void set(int v) {
            //num = v;
            //type = SYMBOL_NUMBER;
        //}
        //void set(const std::string& v) {
            //str = v;
            //type = SYMBOL_STRING;
        //}

        any& operator=(const any& arg) {
            
            if(this->type == SYMBOL_NOINIT) {
                type = arg.getType(); 
                num = arg.getNum();
                str = arg.getStr();
            }
            else {
                if(type != arg.getType()) {
                    error("it cannot convert!\n"); 
                } 
                type = arg.getType(); 
                num = arg.getNum();
                str = arg.getStr();
            }
            return *this;
        } 

        operator int() { 
            if(type == SYMBOL_STRING) {
                printf("type casting error : to int .. %d %s\n", num, str.c_str());
                return 0;
            }
            else {
                return num;
            }
        }
        operator std::string() { 
            if(type == SYMBOL_NUMBER) {
                printf("type casting error : to string .. %d %s\n", num, str.c_str());
                return "no init";
            }
            else {
                return str;
            }
        }
        //operator () { 
            //if(type == SYMBOL_NUMBER) {
                //return num;
            //}
            //else {
                //printf("type error\n");
            //}
        //}
};
typedef struct abstract_syntax_tree {
    enum code op;
    int val;
    struct symbol *sym;
    struct abstract_syntax_tree *left,*right;
    std::string str;
} AST;

typedef struct symbol {
    std::string name;

    any data;
    int *addr;
    AST *func_params;
    AST *func_body;
} Symbol;

#define MAX_SYMBOLS 100

extern Symbol SymbolTable[];
extern int n_symbols;

void ASTPrint(AST *p);

AST *makeSymbol(char *name);
Symbol *lookupSymbol(char *name);
Symbol *getSymbol(AST *p);
void showAllSymbols();

AST *makeNum(int val);
AST *makeStr(const std::string s);
AST *makeAST(enum code op,AST *right,AST *left);

AST *getNth(AST *p,int nth);
AST *getNext(AST *p);
AST *addLast(AST *l,AST *p);

#define getFirst(p) getNth(p,0)
#define makeList1(x1) makeAST(LIST,x1,NULL)
#define makeList2(x1,x2) makeAST(LIST,x1,makeAST(LIST,x2,NULL))
#define makeList3(x1,x2,x3) makeAST(LIST,x1,makeAST(LIST,x2,makeAST(LIST,x3,NULL)))

/* prototype for interface from parser to interpreter/compiler */
void defineFunction(Symbol *fsym,AST *params,AST *body);
void declareVariable(Symbol *vsym,AST *init_value, SYMBOL_TYPE st);
void declareArray(Symbol *asym,AST *size);

