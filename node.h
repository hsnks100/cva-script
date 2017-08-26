
#include <string>
typedef enum { typeCon, typeId, typeOpr, typeConStr } nodeEnum;

struct resultType {
  double number;
  std::string str;
  resultType operator+(const resultType& rt) {
    return resultType{number + rt.number, str + rt.str};
  }

  bool toBool() {
    return number != 0 || str != "";
  }
  
};

/* constants */
typedef struct {
  int value;                  /* value of constant */
  char* const_str;
} conNodeType;

/* identifiers */
typedef struct {
  char* i;                      /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
  int oper;                   /* operator */
  int nops;                   /* number of operands */
  struct nodeTypeTag *op[1];  /* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
  nodeEnum type;              /* type of node */

  union {
    conNodeType con;        /* constants */
    idNodeType id;          /* identifiers */
    oprNodeType opr;        /* operators */
  };
} nodeType;
