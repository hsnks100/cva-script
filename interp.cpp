#include "interp.h"
#include "node.h"
#include "parser.tab.h"
int depth=0;

std::map<std::string, resultType> symbols;
void yyerror(char *s)
{
    std::cout << "hhh" << std::endl;

    printf("%s\n", s);
}
nodeType *con_str(std::string value){
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    // klog("con_str  addr %x, value %s\n", p, value.c_str());
    /* copy information */
    p->type = typeConStr;
    p->con.const_str = strdup(value.c_str());

    return p;
}
nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    // klog("con  addr %x, value %d\n", p, value);
    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(char* i) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType*)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    // klog("id %x\n", p);

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = (nodeType*)malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");
    // klog("opr addr %x\n", p);

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    // klog("free addr %x\n", p);
    if(p->type == typeConStr) {
        free(p->con.const_str);
    }
    free (p);
}

void showLogTree(int n, const std::string& m) {
    // if(m != "") {
    //     for(int i=0; i<n; i++) klog(" ");

    //     klog(m.c_str()); 
    // }
    // klog("\n");
}
resultType ex(nodeType *p, int d) {
    // for(int i=0; i<d; i++) klog(">");
    // klog("\n");
    
    if (!p) {
        return resultType{resultType::NUM, 0, ""};
    }
    switch(p->type) {
    case typeCon:
        showLogTree(d, std::to_string(p->con.value));
        /* klog("ex ___ typeCon %d\n", p->con.value); */
        return resultType{resultType::NUM, p->con.value, ""};
    case typeConStr:
        /* klog("ex ___ typeConStr %s\n", p->con.const_str.c_str()); */
        showLogTree(d, p->con.const_str);
        return resultType{resultType::STR, 0, p->con.const_str};
    case typeId:
        /* klog("ex ___ typeId\n"); */
        /* return p; */
        return symbols[p->id.i]; /**/
    case typeOpr:
        /* klog("ex ___ typeOpr\n"); */
        switch(p->opr.oper) {
        case IF:
        {
            showLogTree(d, "IF");
            /* klog("ex ___ if\n"); */
            auto condEx = ex(p->opr.op[0], d+1);
            auto falseCond = condEx.number == 0 && condEx.str == "";
            if (!falseCond)
                ex(p->opr.op[1], d+1);
            else if (p->opr.nops > 2)
                ex(p->opr.op[2], d+1);
            return resultType{resultType::NUM, 0, ""};
        }
        case PRINT:
        {
            showLogTree(d, "PRINT");
            auto retType = ex(p->opr.op[0], d+1);
            if(retType.type == resultType::NUM) {
                printf("%lf\n", retType.number);
            }
            else{
                printf("%s\n", retType.str.c_str());
            }
        }
        return resultType{resultType::NUM, 0, ""};
        case ';':
            ex(p->opr.op[0], d+1);
            return ex(p->opr.op[1], d+1);
        case '=':
            showLogTree(d, "=");
            return symbols[p->opr.op[0]->id.i] = ex(p->opr.op[1], d+1);
        case '+':
        {
            showLogTree(d, "+");
            return ex(p->opr.op[0], d + 1) + ex(p->opr.op[1], d + 1);
        }
        case LE:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.str != "" || right.str != "") {
                yyerror("type error");
            }
            return resultType{resultType::NUM, left.number <= right.number, ""};
        }
        case GE:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.str != "" || right.str != "") {
                yyerror("type error");
            }
            return resultType{resultType::NUM, left.number >= right.number, ""};
        }
        case EQ:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.number == right.number && left.str == right.str) {
                return resultType{resultType::NUM, 1, ""};
            }
            else{
                return resultType{resultType::NUM, 0, ""};
            }
        }
        case NE:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.number == right.number && left.str == right.str) {
                return resultType{resultType::NUM, 0, ""};
            }
            else{
                return resultType{resultType::NUM, 1, ""};
            }
        }
        case GT:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.str != "" || right.str != "") {
                yyerror("type error");
            }
            return resultType{resultType::NUM, left.number > right.number, ""};
        }
        case LT:
        {
            auto left = ex(p->opr.op[0], d+1);
            auto right = ex(p->opr.op[1], d+1);
            if(left.str != "" || right.str != "") {
                yyerror("type error");
            }
            return resultType{resultType::NUM, left.number < right.number, ""};
        }
        case WHILE:
        {
            showLogTree(d, "WHILE");
            while(ex(p->opr.op[0], d+1).toBool()) {
                ex(p->opr.op[1], d+1); 
            }
            return resultType{resultType::NUM, 0, ""};
        }
        }

    }
    return resultType{resultType::NUM, 0, ""};
}
