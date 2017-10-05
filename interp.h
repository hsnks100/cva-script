/*
 * tiny-C interpreter header file
 */
#define MAX_ENV 10000

typedef struct env {
    Symbol *var;
    any val;
} Environment;

extern Environment Env[MAX_ENV];

/* interp_expr.c */


any executeExpr(AST *p);
int getArray(int *ap, int index);
int setArray(int *ap,int index,int value);

/* interp.c */
any setValue(Symbol* var, any val);
any getValue(Symbol *var);
std::string  setValue(Symbol *var, const std::string& val);
//std::string  getValue(Symbol *var);
void bindEnv(int k,Symbol *var,int val);

int  executeCallFunc(Symbol *f,AST *args);
void executeReturn(AST *expr);
void executeStatement(AST *p);
void executeBlock(AST *local_vars,AST *statements);
void executeIf(AST *cond, AST *then_part, AST *else_part);
void executeWhile(AST *cond,AST *body);
void executeFor(AST *init,AST *cond,AST *iter,AST *body);

