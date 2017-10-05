#include "AST.h"
#include "interp.h"
#include <setjmp.h>

int envp = 0;
Environment Env[MAX_ENV];

jmp_buf *funcReturnEnv;
any funcReturnVal;

jmp_buf* loopControlLabel;

static int executeFuncArgs(AST* params,AST* args);

void defineFunction(Symbol *fsym,AST* params,AST* body)
{
    fsym->func_params = params;
    fsym->func_body = body;
}

/*
 * For environment
 */

any setValue(Symbol* var, any val) {
    var->data = val;
    return val;
}



any getValue(Symbol *var)
{
    int i;
    for(i = envp-1; i >= 0; i--){
        if(Env[i].var == var) return Env[i].val;
    }
    return var->data;
}

int executeCallFunc(Symbol *f,AST* args)
{
    int nargs;
    int val;
    jmp_buf ret_env;
    jmp_buf *ret_env_save;

    /*printf("function %s\n", f->name.c_str());*/
    nargs = executeFuncArgs(f->func_params,args);

    ret_env_save = funcReturnEnv;
    funcReturnEnv = &ret_env; 

    // f() { return 3; return 2; } 's expected result value is 3, but if you don't use setjmp, result value is 2;
    if(setjmp(ret_env) != 0){
        val = funcReturnVal;
    } else {
        executeStatement(f->func_body);
    }
    envp -= nargs;
    funcReturnEnv = ret_env_save;
    return val;
}

static int executeFuncArgs(AST* params,AST* args)
{
    Symbol *var;
    any val;
    int nargs;

    if(params == NULL) return 0;
    val = executeExpr(getFirst(args));
    var = getSymbol(getFirst(params));
    nargs = executeFuncArgs(getNext(params),getNext(args));
    Env[envp].var = var;
    Env[envp].val = val;
    envp++;
    return nargs+1;
}

void executeReturn(AST* expr)
{
    funcReturnVal = executeExpr(expr);
    longjmp(*funcReturnEnv,1);
    error("longjmp failed!\n");
}


void executeStatement(AST* p)
{
    if(p == NULL) return;
    switch(p->op){
        case BLOCK_STATEMENT:
            executeBlock(p->left,p->right);
            break;
        case RETURN_STATEMENT:
            executeReturn(p->left);
            break;
        case IF_STATEMENT:
            executeIf(p->left,getNth(p->right,0),getNth(p->right,1));
            break;
        case WHILE_STATEMENT:
            executeWhile(p->left,p->right);
            break;
        case FOR_STATEMENT:
            executeFor(getNth(p->left,0),getNth(p->left,1),getNth(p->left,2),
                    p->right);
            break;
        case BREAK_STATEMENT:
            longjmp(*loopControlLabel, 1); 
            error("break error\n");
            break;
        case CONTINUE_STATEMENT:
            longjmp(*loopControlLabel, 2); 
            error("continue error\n");
            break;
        default:
            executeExpr(p);
    }
}

void executeBlock(AST* local_vars,AST* statements)
{
    AST* vars;
    int envp_save;

    envp_save = envp;
    for(vars = local_vars; vars != NULL; vars = getNext(vars))
        Env[envp++].var = getSymbol(getFirst(vars));
    for( ; statements != NULL; statements = getNext(statements))
        executeStatement(getFirst(statements));
    envp = envp_save;
    return;
}

void executeIf(AST* cond, AST* then_part, AST* else_part)
{
    if(executeExpr(cond))
        executeStatement(then_part);
    else 
        executeStatement(else_part);
}

void executeWhile(AST* cond,AST* body)
{
    while(executeExpr(cond))
        executeStatement(body);
}

void executeFor(AST* init,AST* cond,AST* iter,AST* body)
{
    executeExpr(init);

    jmp_buf loopControl, *loopControlSave; 

    loopControlSave = loopControlLabel; 
    loopControlLabel = &loopControl;


    for(; executeExpr(cond); executeExpr(iter)) {
        int code = setjmp(loopControl);
        if(code != 0) {
            if(code == 1) {
                break;
            }
            if(code == 2) {
                continue;
            }
        }
        else {
            executeStatement(body);
        }
    }

    loopControlLabel = loopControlSave;
}




