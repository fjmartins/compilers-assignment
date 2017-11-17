/* Inclusao de bibliotecas */

%{
#include <stdio.h>
#include <string.h>
#include <math.h> /* Para funcoes matematicas cos() sin() tan() etc */
#include "mfcalc.h"
%}

%union {
	double val;
	symrec *tptr;
}

/* Criacao de tokens para numeros e expressoes */
%token	<val>	NUM
%token	<tptr>	VAR FNCT
%type	<val>	exp

/* Prioridade de operacoes */

%right	'='
%left	'-' '+'
%left	'*' '/'
%left	NEG
%right	'^'

/* Gramatica a seguir */

%%

input : /* Vazio */
	| input line
;

line : '\n'
	| exp '\n'		{ printf ("%.10lf\n", $1);	}
	| error '\n'	{ yyerrok;					}
;

exp: NUM				{ $$ = $1;						}
	| VAR 				{ $$ = $1->value.var;			}
	| FNCT '(' exp ')'  { $$ = 3; $1->value.var = $3;	}
	| exp '+' exp 		{ $$ = $1 + $3;					}
	| exp '-' exp 		{ $$ = $1 - $3;					}
	| exp '*' exp 		{ $$ = $1 * $3;					}
	| exp '/' exp 		{ $$ = $1 / $3;					}
	| '-' exp %prec NEG { $$ = -$2;						}
	| exp '^' exp 		{ $$ = pow($1, $3);				}
	| '(' exp ')'		{ $$ = $2;						}
;

/* Fim da gramatica */

%%

struct init {
	char * fname;
	double (*fnct)(double);
};

struct init arith_fncts[] = {
"sin", & sin,
"cos", & cos,
"atan", & atan,
"ln", & log,
"exp", & exp,
"sqrt", & sqrt,
0, 0
};

symrec * sym_table = (symrec *)0;

symrec * putsym (char * sym_name, int sym_type) {
	symrec * prt;
	ptr = (symrec *) malloc (sizeof (symrec));
	ptr->name = (char *) malloc (strlen (sym_name) + 1);
	stycpy (ptr->name, sym_name);
	ptr->type = sym_type;
	ptr->value.var = 0;
	ptr->next = (struct symrec *) sym_table;
	sym_table = ptr;
	return ptr;
}

symrec * getsym(char * sym_name) {
	symrec * ptr;
	for (ptr=sym_table; ptr != (symrec *) 0; ptr = (symrec *) ptr->next)
		if(strcmp (ptr->name, sym_name) == 0)
			return ptr;
	return (symrec *) 0;
}

/* Funcoes aritmeticas*/

void init_table (void) {
	int i;
	symrec * ptr;
	for (i = 0; arith_fncts[i].fname != 0; i++) {
		ptr = putsym(arith_fncts[i].fname, FNCT);
		ptr->value.fnctptr = arith_fncts[i].fnct;
	}
}

int main (int argc, char** argv) {
	init_table();
	yyparse();
}

int yyerror(char *s) {
	printf("%s\n", s)
}