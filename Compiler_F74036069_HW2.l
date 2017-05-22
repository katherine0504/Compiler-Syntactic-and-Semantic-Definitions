%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "y.tab.h"	/* header file generated by bison */

%}

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
int {digit}+
double {digit}+\.{digit}+
_int [iI][nN][tT]
_double [dD][oO][uU][bB][lL][eE]
_if [iI][fF]
_else [eE][lL][sS][eE]
_while [wW][hH][iI][lL][eE]
_print [pP][rR][iI][nN][tT]
_string "\"".+"\""
space		[ ]


%%

{_print}						{ return PRINT;}
{_while}						{ return WHILE;}
{_int}							{ return TYPEINT;}
{_double}						{ return TYPEDOUBLE;}
{_string}						{
											yylval.str = strdup(yytext);
											return STRING;
										}
[-+]?{int}					{
											yylval.intNum = atoi(yytext);
											return INTNUM;}
[-+]?{double} 			{	
											yylval.floatNum = atof(yytext);
											return FLOATNUM;}
{id}								{
											yylval.str = strdup(yytext);
											return ID;
										}
										
[-+()=/*\n;]				{ return *yytext; }										
[ \t]								{ ;} /* Ignore */

%%

int yywrap()
{
    return 1;
}

