#include <stdlib.h>
#include "AST.h"
#include "interp.h"

static void printFunc(AST *args);

int executeExpr(AST *p)
{
    if(p == NULL) return 0;
    switch(p->op){
        case NUM:
            return p->val;
        case SYM:
            return getValue(getSymbol(p));
        case EQ_OP:
            return setValue(getSymbol(p->left),executeExpr(p->right));
        case PLUS_OP:
            return executeExpr(p->left) + executeExpr(p->right);
        case MINUS_OP:
            return executeExpr(p->left) - executeExpr(p->right);
        case MUL_OP:
            return executeExpr(p->left) * executeExpr(p->right);
        case LT_OP:
            return executeExpr(p->left) < executeExpr(p->right);
        case GT_OP:
            return executeExpr(p->left) > executeExpr(p->right);
        case GET_ARRAY_OP:
            return getArray(getSymbol(p->left)->addr,executeExpr(p->right));
        case SET_ARRAY_OP:
            return setArray(getSymbol(getNth(p->left,0))->addr,
                    executeExpr(getNth(p->left,1)),
                    executeExpr(p->right));
        case CALL_OP:
            return executeCallFunc(getSymbol(p->left),p->right);
        case PRINTLN_OP:
            printFunc(p->left);
            return 0;
        default:
            error("unknown operater/statement");
    }
}

static void printFunc(AST *args)
{
    AST *p;
    p = getNth(args,0);
    if(p->op != STR) error("not format string for println");
    printf(p->str,executeExpr(getNth(args,1)));
    printf("\n");
}

/*
 * global variable
 */
void declareVariable(Symbol *vsym,AST *init_value)
{
    if(init_value != NULL){
        vsym->val = executeExpr(init_value);
    }
}

/* 
 * Array
 */
void declareArray(Symbol *a, AST *size)
{
    a->addr = (int*)malloc(sizeof(int)*executeExpr(size));
}

int getArray(int *ap, int index)
{
    return ap[index];
}

int setArray(int *ap,int index,int value)
{
    ap[index] = value;
    return value;
}


