#include <stdlib.h>
#include "AST.h"
#include "interp.h"

static void printFunc(AST *args);

any executeExpr(AST *p)
{
    if(p == NULL) return 0;
    /*printf("p->op = %d\n", p->op);*/
    switch(p->op){
        case NUM:
            return p->val;
        case STR:
            return p->str;
        case SYM:
            return getValue(getSymbol(p));
        case EQ_OP:
            return setValue(getSymbol(p->left), executeExpr(p->right));
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
        case EQ_TEST_OP:
            return executeExpr(p->left) == executeExpr(p->right);
        case CALL_OP:
            return executeCallFunc(getSymbol(p->left), p->right);
        case PRINT_OP:
            printFunc(p->left);
            return (int)0;
        default:
            printf("________error type %d\n", p->op);
            error("unknown operater/statement");
    }
}

std::string ReplaceAll(std::string &str, const std::string& from, const std::string& to){
    size_t start_pos = 0; //string처음부터 검사
    while((start_pos = str.find(from, start_pos)) != std::string::npos)  //from을 찾을 수 없을 때까지
    {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); // 중복검사를 피하고 from.length() > to.length()인 경우를 위해서
    }
    return str;
}
static void printFunc(AST *args)
{
    AST *p;
    any result = executeExpr(getNth(args, 0));
    std::string t = result.toString();

    t = ReplaceAll(t, "\\n", "\n").c_str();
    printf(ReplaceAll(t, "\\t", "\t").c_str());
}

/*
 * global variable
 */
void declareVariable(Symbol *vsym, AST *init_value, SYMBOL_TYPE st)
{
    vsym->data.setType(st);
    if(init_value != NULL){
        /*printf("%s :: %d\n", __FUNCTION__, __LINE__);*/
        vsym->data = executeExpr(init_value);
    }
}

