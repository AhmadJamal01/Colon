%{
    #include <stdlib.h>
    #include <stdio.h>
    void yyerror (char* ); int yywrap();
    int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    extern int yylineno;
%}

%token INT_DECLARATION FLOAT_DECLARATION CHAR_DECLARATION CONST_DECLARATION STRING_DECLARATION BOOL_DECLARATION ENUM_DECLARATION
%token AND OR NOT EQ NE LT GT LE GE
%token IF ELSE WHILE FOR DO SWITCH CASE DEFAULT BREAK CONTINUE
%token RETURN VOID PRINT
%token IDENTIFIER INTEGER_CONSTANT FLOAT_CONSTANT CHAR_CONSTANT STRING_CONSTANT
%token TRUE_KEYWORD FALSE_KEYWORD
%token SINGLE_LINE_COMMENT 
%nonassoc IFX
%nonassoc ELSE
%nonassoc UMINUS

%right '='
%left  OR
%left  AND
%left  EQ NE
%left  LT GT LE GE
%left  '+' '-'
%left  '*' '/' '%'
%right NOT

%%
statement_list:                         statement ';'
|                                       statement_list statement ';'
|                                       control_statement
|                                       statement_list control_statement
|                                       braced_statements
|                                       statement_list braced_statements
|                                       statement error {yyerrok;}
;

braced_statements:                      '{' statement_list '}'  //{printf("braced statements\n");}
;

statement:                              expression
|                                       variable_declaration
|                                       assignment  
|                                       RETURN                                           // {printf("empty return\n");}
|                                       RETURN expression                               // {printf("return\n");}
|                                       BREAK                                           // {printf("break\n");}
|                                       CONTINUE                                        // {printf("continue\n");}
|                                       
;

variable_declaration:                   variable_type IDENTIFIER 
|                                       variable_type IDENTIFIER '=' expression
|                                       enum_definition
|                                       CONST_DECLARATION variable_type IDENTIFIER '=' expression
|                                       ENUM_DECLARATION IDENTIFIER IDENTIFIER 
|                                       ENUM_DECLARATION IDENTIFIER assignment
|                                       variable_declaration_error
{
    yyerror("missing identifier");
    yyerrok;
}
|                                       const_declaration_error
{
    yyerror("cannot declare constant without value");
    yyerrok;
}
;

variable_type:                          INT_DECLARATION                    
|                                       FLOAT_DECLARATION
|                                       CHAR_DECLARATION
/*|                                       CONST_DECLARATION */
|                                       BOOL_DECLARATION
|                                       STRING_DECLARATION
;

enum_definition:                        ENUM_DECLARATION IDENTIFIER'{' enum_list '}'
;

enum_list:                              IDENTIFIER enum_opt_value ',' enum_list 
|                                       IDENTIFIER enum_opt_value
;

enum_opt_value:                         '=' INTEGER_CONSTANT
|                                       /* empty */
;

expression:                             IDENTIFIER                            // {printf("identifier expression\n");}
|                                       INTEGER_CONSTANT
|                                       FLOAT_CONSTANT
|                                       CHAR_CONSTANT                        // {printf("char constant expression\n");}
|                                       STRING_CONSTANT                      // {printf("string constant expression\n");}
|                                       TRUE_KEYWORD                         
|                                       FALSE_KEYWORD
|                                       '(' expression ')'
|                                       expression '+' expression
|                                       expression '-' expression
|                                       expression '*' expression
|                                       expression '/' expression
|                                       expression '%' expression
|                                       expression EQ expression
|                                       expression NE expression
|                                       expression LT expression
|                                       expression GT expression
|                                       expression LE expression
|                                       expression GE expression
|                                       expression AND expression
|                                       expression OR expression
|                                       NOT expression
|                                       '-' expression %prec UMINUS
|                                       function_call
|                                       expression_error
{
    yyerror("missing operand");
    yyerrok;
}
;

function_declaration:                   variable_type IDENTIFIER '(' parameter_list ')' braced_statements
|                                       VOID IDENTIFIER '(' parameter_list ')' braced_statements
;

function_call:                          IDENTIFIER '(' arguemnt_list ')'                // {printf("function call\n");}
|                                       reserved_functions '(' arguemnt_list ')'        // {printf("print call\n");}
;

/*reserved functions rule */
reserved_functions:                     PRINT
/* | cout and whatnot*/
; 

arguemnt_list:                          arguemnt_list ',' expression        
|                                       expression
|                                    /* empty */
;

parameter_list:                         parameter_list ',' parameter
|                                       parameter
|                                       /* empty */
;

parameter:                              variable_declaration
;

control_statement:                      if_statement
|                                       while_loop
|                                       do_while_loop
|                                       switch_statement
|                                       for_loop
|                                       comments
|                                       function_declaration


/*missing_semicolon:                      expression error
;
*/

assignment:                             IDENTIFIER '=' expression                       // {printf("assignment\n");}
;

for_loop:                               FOR '(' variable_declaration ';' statement ';' assignment ')' braced_statements // {printf("for loop\n");}
;

if_statement:                           IF '(' expression ')' braced_statements %prec IFX               // {printf("if statement\n");}
|                                       IF '(' expression ')' braced_statements ELSE braced_statements              // {printf("if statement with else\n");}
|                                       IF '(' expression ')' braced_statements ELSE if_statement       // {printf("if statement with else if\n");}
;

while_loop:                             WHILE '(' expression ')' braced_statements                      // {printf("while loop\n");}
;

do_while_loop:                          DO braced_statements WHILE '(' expression ')' ';'              // {printf("do while loop\n");}
;

switch_statement:                       SWITCH '(' expression ')' '{' case_list '}'          //{printf("switch statement\n");}
;

case_list:                              case_list case
|                                       case
;

case:                                   CASE expression ':' statement_list 
|                                       DEFAULT ':' statement_list
;

comments:                               SINGLE_LINE_COMMENT                            // {printf("single line comment\n");}


expression_error:                       expression '+'
;

variable_declaration_error:             variable_type
|                                       variable_type IDENTIFIER '='
;

const_declaration_error:                CONST_DECLARATION variable_type IDENTIFIER 
;

%%

void yyerror(char *s) {
    fprintf(stderr, "\n%s at line %d\n", s, yylineno);
}

int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yyparse();
    if (yywrap())
    {
        printf("\nParsing successful ya regala!\n");
    }
    fclose(yyin); 
    return 0;
}
