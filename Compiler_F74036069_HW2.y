%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


extern int yylex();

void yyerror(char *s);
void create_symbol();								/*establish the symbol table structure*/
int insert_symbol_int (char* id, char* type, int data);	/*Insert an undeclared ID in symbol table*/
int insert_symbol_double (char* id, char* type, double data);
void symbol_assign_int (char* id, int data, int loc);				/*Assign value to a declared ID in symbol table*/
void symbol_assign_double (char* id, double data, int loc);
int lookup_symbol(char* id);						/*Confirm the ID exists in the symbol table*/
void dump_symbol();									/*List the ids and values of all data*/
double calculate_value(char* op, double a, double b);

int linenum, idx = 0;											
bool IDfound = false;
bool table_created = false;
bool hasError = false;
bool isInt = false;
bool isDouble = false;

char type_tmp[15];
char errmsg[500];
char inttmp[10];

struct info {
    char type[15];
    char id[50];
    int val;
    double doubleval;
} table[500];

%}

%union {
    int intNum;
    double floatNum;
    double ptr;
    char *str;
};

/* Token definition */
%token <intNum> INTNUM
%token <floatNum> FLOATNUM
%token <str> STRING ID
%token <ptr> PRINT WHILE
%token TYPEINT TYPEDOUBLE 

%type <ptr> Line Stmt Expr Pnt

%left '+' '-'
%left '*' '/'
%left UMINUS

%%

Prog
    : Prog Line
    | Prog Stmt ';' Line
    |
    ;

Line
    : '\n'                          {linenum++; }
    |
    ;

Stmt
	: PRINT '(' Pnt ')'
    | TYPEINT ID                    {insert_symbol_int($2, "int", 0); }
    | TYPEDOUBLE ID                 {insert_symbol_double($2, "double", 0); }
    | TYPEINT ID '=' Expr           {insert_symbol_int($2, "int", $4); }
    | TYPEDOUBLE ID '=' Expr        {insert_symbol_double($2, "double", $4); }
    | ID '=' Expr                   {
                                        int loc = lookup_symbol($1);
                                        if (loc == -1) {
                                            sprintf(inttmp, "%d", linenum);
                                            strcpy(errmsg, "<Error> line " );
                                            strcat(errmsg, inttmp);
                                            strcat(errmsg, ": variable ");
                                            strcat(errmsg, $1);
                                            strcat(errmsg, " not found");
                                            yyerror(errmsg);
                                        } else {
                                            if (!strcmp(table[loc].type, "int")) {
                                                symbol_assign_int($1, $3, loc);
                                            } else {
                                                symbol_assign_double($1, $3, loc);
                                            }
                                        } 
                                    }
    ;

Expr
    : INTNUM                        {$$ = $1; }
    | FLOATNUM                      {$$ = $1; }
    | ID                            {
                                        int loc = lookup_symbol($1);
                                        if (loc == -1) {
                                            sprintf(inttmp, "%d", linenum);
                                            strcpy(errmsg, "<Error> line " );
                                            strcat(errmsg, inttmp);
                                            strcat(errmsg, ": variable ");
                                            strcat(errmsg, $1);
                                            strcat(errmsg, " not found");
                                            yyerror(errmsg);
                                            hasError = true;
                                            $$ = 0;
                                        } else {
                                            if (!strcmp(table[loc].type, "int")) {
                                                $$ = table[loc].val;
                                            } else {
                                                $$ = table[loc].doubleval;
                                            }
                                            
                                        }
                                    }
    | Expr '+' Expr                 {$$ = calculate_value('+', $1, $3); }
    | Expr '-' Expr                 {$$ = calculate_value('-', $1, $3); }
    | Expr '*' Expr                 {$$ = calculate_value('*', $1, $3); }
    | Expr '/' Expr                 {$$ = calculate_value('/', $1, $3); }
    | '(' Expr ')'                  {$$ = $2; }
    | '-' Expr %prec UMINUS         {$$ = -$2; }
    ;

Pnt
    : STRING                        {
                                        if(!hasError) {
                                            printf("Print : %s\n", $1);
                                        } else {
                                            hasError = false;
                                        }
                                    }
    | Expr                          {   if (!hasError) {
                                            printf("Print : %f\n", $1);
                                        } else {
                                            hasError = false;
                                        }
                                    }
    ;

%%

int main(int argc, char** argv)
{  
    linenum = 1;
    yyparse();

    printf("\n-------------------\n");
	printf("Total lines: %d \n",linenum);
	printf("-------------------\n\n");
    dump_symbol();
    return 0;
}

void yyerror(char *s) {
    printf("%s\n", s);
}


/*symbol create function*/
void create_symbol() {
    table_created = true;
    printf("Create symbol table\n");
    return;
}

/*symbol insert function*/
int insert_symbol_int (char* id, char* type, int data) {
	int i;
    if (!hasError) {
        for (i = 0 ; i < idx; ++i) {
            if(!strcmp(table[i].id, id)) {
                sprintf(inttmp, "%d", linenum);
                strcpy(errmsg, "<Error> line " );
                strcat(errmsg, inttmp);
                strcat(errmsg, ": re-declaration for variable ");
                strcat(errmsg, id);
                yyerror(errmsg);
                return 1;
            }
        }
        
        if(!table_created) {
            create_symbol();
        }
        
        printf("Insert symbol: %s\n", id);
        strcpy(table[idx].id, id);
        strcpy(table[idx].type, type);
        table[idx++].val = data;

        return 0;
    } else {
        hasError = false;
        return 1;
    }
}

int insert_symbol_double (char* id, char* type, double data) {
	int i;

    if (!hasError) {    
    for (i = 0 ; i < idx; ++i) {
        if(!strcmp(table[i].id, id)) {
            sprintf(inttmp, "%d", linenum);
            strcpy(errmsg, "<Error> line " );
            strcat(errmsg, inttmp);
            strcat(errmsg, ": re-declaration for variable ");
            strcat(errmsg, id);
            yyerror(errmsg);
            return 1;
        }
    }
    
    if(!table_created) {
        create_symbol();
    }
    
    printf("Insert symbol: %s\n", id);
    strcpy(table[idx].id, id);
    strcpy(table[idx].type, type);
    table[idx++].doubleval = data;

    return 0;
    } else {
        hasError = false;
        return -1;
    }
}

/*symbol value lookup and check exist function*/
int lookup_symbol(char* id){
	int i;

    for (i = 0; i < idx; ++i) {
        if(!strcmp(table[i].id, id)) {
            return i;
        }
    }

    return -1;
}

/*symbol value assign function*/
void symbol_assign_int (char* id, int data, int loc) {    
    if(!hasError) {
        printf("ASSIGN\n");
        table[loc].val = data;
        return;
    } else {
        hasError = false;
        return;
    }
}

void symbol_assign_double (char* id, double data, int loc) {
    if(!hasError) {
        printf("ASSIGN\n");
        table[loc].doubleval = data;
        return;
    } else {
        hasError = false;
        return;
    }
}

/*symbol dump function*/
void dump_symbol(){
	int i;

    printf("The symbol table:\n\n");
    printf("ID\tType\tData\n");

    for (i = 0; i < idx; ++i) {
        if (!strcmp(table[i].type, "int")) {
            printf("%s\t%s\t%d\n", table[i].id, table[i].type, table[i].val);
        } else {
            printf("%s\t%s\t%f\n", table[i].id, table[i].type, table[i].doubleval);
        }
    }
}

double calculate_value(char* op, double a, double b) {
    if( op == '+') {
        printf("Add\n");
        return a+b;
    } else if (op == '-') {
        printf("Sub\n");
        return a-b;
    } else if (op == '/') {
        if(b == 0) {
            sprintf(inttmp, "%d", linenum);
            strcpy(errmsg, "<Error> line " );
            strcat(errmsg, inttmp);
            strcat(errmsg, ": The divisor can't be zero. ");
            yyerror(errmsg);
            hasError = true;
            return 0;
        } else {
            printf("Div\n");
            return a/b;
        }
    } else if (op == '*') {
        printf("Mul\n");
        return a*b;
    } else {
        sprintf(inttmp, "%d", linenum);
        strcpy(errmsg, "<Error> line " );
        strcat(errmsg, inttmp);
        strcat(errmsg, ": Syntax error.");
        yyerror(errmsg);
        hasError = true;
        return 0;
    }
}