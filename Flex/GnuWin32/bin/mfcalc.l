%{
# include "mfcalc.h"
# include "bison.h"
%}

%%

[0-9]*\.?[0-9]+ {
	sscanf (yytext, "%lf", &yylval.val);
	return NUM;
}

[a-zA-Z][a-zA-Z_0-9]* {
	symrec *5;
	s = getsym(yytext);
	if (s == 0) {
		s = putsym(yytext, VAR);
	}
	yyval.tptr = s;
	return s->type;
}

[ \t]* {
	;
}

.|\n {
	return *yytext;
}

%%