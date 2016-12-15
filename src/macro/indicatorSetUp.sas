%macro indicatorSetUp(name=);
%global in_id;
%global in_name;
%global analysis;

	%if %length(&name) < 1 %then %do;
		%put =======================================================;
		%put An indicator name is required for the analysis;
		%put Please check the value of NAME and try again;
		%put For help, submit with name=help for variable options;
		%put The macro will stop execution;
		%put =======================================================;
		%return;
	%end;
	%else %do;
		%if &name=help %then %do;
			proc sql;
				select indicator_desc label="To create a data set for..."
					  ,indicator_name label="Set the following as name="
				from metadata.indicators
			;
			quit;
		%end;
		%else %do;
		/* Grab the indicator requested for analysis */
		proc sql;
			select indicator_id
				,indicator_name
			into :in_id
				,:in_name
			from metadata.indicators
				where indicator_name="&name"
			;
		quit;

		/* Grab the CCHS data variable needed to make dummy variables */
		proc sql;
			select distinct b.variable_name
				into: analysis separated by " "
			from metadata.indicators as a
				,metadata.variable as b
				,metadata.indicator_variable as c
			where a.indicator_id=&in_id
				and a.indicator_id=c.indicator_id
				and c.variable_id=b.variable_id
			;
		quit;
		%end;
	%end;
%mend;