%macro makeCCHSDenominator(indicator);
	%if &indicator=drinkingAge %then %do;
		if dhh_age >= 19 then total=1;
		else total=0;
	%end;
	%else %if &indicator=excludeDontKnow %then %do;
		if &in_name ^=. then total=1;
		else total=0;
	%end;
	%else %if &indicator=full %then %do;
		total=1;
	%end;
	/*...more statements to follow...*/
%mend;