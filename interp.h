/*
 * tiny-C interpreter header file
 */
#define MAX_ENV 100

typedef struct env {
    Symbol *var;
    int val;
} Environment;

extern Environment Env[MAX_ENV];

/* interp_expr.c */
int executeExpr(AST *p);
int getArray(int *ap, int index);
int setArray(int *ap,int index,int value);

/* interp.c */
int  setValue(Symbol *var,int val);
int  getValue(Symbol *var);
void bindEnv(int k,Symbol *var,int val);

int  executeCallFunc(Symbol *f,AST *args);
void executeReturn(AST *expr);
void executeStatement(AST *p);
void executeBlock(AST *local_vars,AST *statements);
void executeIf(AST *cond, AST *then_part, AST *else_part);
void executeWhile(AST *cond,AST *body);
void executeFor(AST *init,AST *cond,AST *iter,AST *body);

