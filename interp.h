#ifndef _INTER_H_
#define _INTER_H_
#include "node.h"


#include <map>
#include <string>
#include <string.h>
#include <iostream>
#include <stdio.h>
#include <stdarg.h>
#define klog printf
#define klog {}
nodeType *opr(int oper, int nops, ...);
nodeType *id(char* i);
nodeType *con(int value);
nodeType *con_str(std::string value);



void freeNode(nodeType *p);
resultType ex(nodeType *p, int d);
#endif
