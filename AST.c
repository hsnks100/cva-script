#include <stdlib.h>
#include "AST.h"


Symbol SymbolTable[MAX_SYMBOLS];
int n_symbols = 0;

AST *makeNum(int val)
{
    AST *p;
    p = (AST *)malloc(sizeof(AST));
    p->op = NUM;
    p->val = val;
    return p;
}

AST *makeStr(const std::string s)
{
    AST *p;
    p = (AST *)malloc(sizeof(AST));
    p->op = STR;
    p->str = s;
    return p;
}


AST *makeAST(enum code op,AST *left,AST *right)
{
    AST *p;
    p = (AST *)malloc(sizeof(AST));
    p->op = op;
    p->right = right;
    p->left = left;
    return p;
}

AST *getNth(AST *p,int nth)
{
    if(p->op != LIST){
        fprintf(stderr,"bad access to list\n");
        exit(1);
    }
    if(nth > 0) return(getNth(p->right,nth-1));
    else return p->left;
}

AST *addLast(AST *l,AST *p)
{
    AST *q;

    if(l == NULL) return makeAST(LIST,p,NULL);
    q = l;
    while(q->right != NULL) q = q->right;
    q->right = makeAST(LIST,p,NULL);
    return l;
}

AST *getNext(AST *p)
{
    if(p->op != LIST){
        fprintf(stderr,"bad access to list\n");
        exit(1);
    }
    else return p->right;
}

Symbol *lookupSymbol(char *name)
{
    printf("lookp!! %s\n", name);
    int i;
    Symbol *sp;

    sp = NULL;
    for(i = 0; i < n_symbols; i++){
        if(SymbolTable[i].name == name) {
            sp = &SymbolTable[i];
            break;
        }
    }
    if(sp == NULL){
        sp = &SymbolTable[n_symbols++];
        sp->name = name;
    }
    return sp;
}

void showAllSymbols() {
    printf("----------show all --------------\n");
    int i;
    for(i = 0; i < n_symbols; i++){
        Symbol* s = &SymbolTable[i];
        printf("%s = %d\n", s->name.c_str(), 888);
    }
}

AST *makeSymbol(char *name)
{
    AST *p;

    p = (AST *)malloc(sizeof(AST));
    p->op = SYM;
    p->sym = lookupSymbol(name);
    return p;
}

Symbol *getSymbol(AST *p)
{
    if(p->op != SYM){
        fprintf(stderr,"bad access to symbol\n");
        exit(1);
    }
    else return p->sym;
}

