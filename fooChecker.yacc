 
 /* process the language grammar rules,
  *    currently just displays a summary of valid rules it parses
  *
  * currently the valid token types are
  *    VAR          the VAR keyword
  *    IDENTIFIER   any alphabetic identifier
  *    ;            the semicolon terminator
  *
  * currently the heirarchy of grammar rules (with script as the top level) are:
  *    script --> vardecl
  *    vardecl --> VAR IDENTIFIER ;
  */


 /****** declarations and C support ******/

%{
#define DEBUGTAG 0
#include<stdio.h>
#include<string.h>
#include <math.h>
#include <stdbool.h>
int yylex(void);
int yywrap();
int yyerror(char* s);
%}



 /* identify the top level language component */
%start script


 /* every component of the program has the same data type:
  *    info is a struct with five fields
  *       ival - a long, used for integer and intexpr
  *       fval - a double, used for float and floatexpr
  *       str  - a char*, used for string and strexpr
  *       name - a char*, used for the name of identifiers
  *       dtype - an int, used to indicate the current datatype,
  *               0 for unknown, 1 for integer, 2 for float. 3 for string,
  *               4 for boolean    
  */


%union { 
   struct nodeinfo 
   { 
      long ival, dtype; 
      double fval;
      char str[4096], name[256]; 
      bool bval;
   } info; 
}


 /* identify what kind of values can be associated with the language components */

 /* for the token types that have an associated value, identify its type */
%token<struct nodeinfo> INTEGER REAL IDENTIFIER STRING BOOLEAN PRINT VAR MOD

/* %type<struct nodeinfo>  */



/* Operator Precedence */ 
%right '='
%left  '+'  '-'
%left  '*'  '/' MOD
%left  '^'  
/*%left UMINUS  */  /* UNARY Minus */ 
/* Parantheses??? */ 


%%
/*
YOURE STILL UNDOING 
STOP UNDOING
THIS IS A SAVE POINT RIGHT HERE
*/
 /****** grammar rules ******/

script: statement
         { 
            #if DEBUGTAG
               printf(" ~RULE~: script--> statement \n"); 
            #endif
         }
      ;

statement:
        statement expression
            { 
               #if DEBUGTAG
                  printf(" ~RULE:statement--> statement expression \n");
               #endif
            }
      | expression
         { 
            #if DEBUGTAG
               printf(" ~RULE:statement--> expression \n"); 
            #endif
         }
      ;

expression:
        intexpr ';'
         { 
            #if DEBUGTAG
               printf(" ~RULE:expression--> intexpr ';' \n");    //DEBUG
            #endif
            $<info.dtype>$ = $<info.dtype>1;
            $<info.ival>$ = $<info.ival>1;
         }
      ;

intexpr: INTEGER
         {
            #if DEBUGTAG
               printf(" ~RULE:intexpr--> INTEGER \n");    //DEBUG
            #endif
            $<info.dtype>$ = 1;
            $<info.ival>$ = $<info.ival>1;
            #if DEBUGTAG
               printf("%d is an integer \n",$<info.ival>1);
            #endif
         }
      | '-' intexpr    %prec '*' /*unary negation, same prec a multip */
         {
            #if DEBUGTAG
               printf(" ~RULE:intexpr--> '-' intexpr  prec '*' \n");    //DEBUG
            #endif
            $<info.dtype>$ = 2;
            $<info.ival>$ = - $<info.ival>2;
            #if DEBUGTAG
               printf("negative %d, using unary negation \n",$<info.ival>2);
            #endif
         }
      | intexpr '+' intexpr
         {
            #if DEBUGTAG
               printf(" ~RULE:intexpr--> intexpr + intexpr \n");    //DEBUG
            #endif
            $<info.dtype>$ = 1;
            $<info.ival>$ = $<info.ival>1 + $<info.ival>3;
            #if DEBUGTAG
               printf("%d + %d is %d \n",$<info.ival>1, $<info.ival>3, $<info.ival>$);
            #endif
         }
      | intexpr '*' intexpr
         {
            #if DEBUGTAG
               printf(" ~RULE: intexpr--> intexpr * intexpr \n");    //DEBUG
            #endif
            $<info.dtype>$ = 1;
            $<info.ival>$ = $<info.ival>1 * $<info.ival>3;
            #if DEBUGTAG
               printf("%d * %d is %d \n",$<info.ival>1, $<info.ival>3, $<info.ival>$);
            #endif
         }
      ;

%%

 /****** supporting C to carry out parsing ******/


int main()
{
   printf("Beginning syntax checking:\n\n");
   int result = yyparse();
   printf("\nSyntax checking complete\n\n");
   return result;
}


