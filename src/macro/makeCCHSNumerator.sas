%macro makeCCHSNumerator(indicator);
	%if &indicator=excessDrinking %then
		%do;
			/* Guideline 1a
			 * >15 drinks/week for men
		 * >10 drinks/week for women*/
			if alwdwky <= 10 then
				guideline1a=0;
			else if (10 < alwdwky < 996 and dhh_sex=2) then
				guideline1a=1;
			else if (15 < alwdwky < 996 and dhh_sex=1) then
				guideline1a=1;
			else if alwdwky in(996,999) then
				guideline1a=0;
			else guideline1a=0;

			/* Guideline 1b
			 * >3 drinks/day for men
		 * >2 drinks/day for women*/
			if alwddly <=2 then
				guideline1b=0;
			else if (2 < alwddly < 996 and dhh_sex=2)then guidline1b=1;
			else if (3 < alwddly < 996 and dhh_sex=1) then
				guideline1b=1;
			else if alwddly in(996,999) then
				guideline1b=0;
			else guideline1b=0;

			/* Guideline 1c
		 * Non-drinking day in the past week */
			array dailyAlcohol[*] alw_2a1-alw_2a7;
			drop i;

			do i=1 to dim(dailyAlcohol);
				if dailyAlcohol[i] in(997-999) then
					exclude=1;
				else exclude=0;
			end;

			if exclude then
				guideline1c=0;
			else
				do;
					if (alw_2a1=0)+(alw_2a2=0)+(alw_2a3=0)+(alw_2a4=0)+(alw_2a5=0)+(alw_2a6=0)+(alw_2a7=0) >= 6 then
						guideline1c=1;
					else guideline1c=0;
				end;

			/* Guideline 2
			 * >4 drinks/one occasion for men
		 * >3 drinks/one occasion for women*/
			if alc_3=1 then
				guideline2=0;
			else if alc_3 in(2-6) then
				guideline2=1;
			else if alc_3 in(96-99) then
				guideline2=0;
			else guideline2=0;

			/*-- Numerator --*/
			if guideline1a or guideline1b or guideline1c or guideline2 then
				excessDrinking=1;
			else excessDrinking=0;

			/*-- Population exclusions --*/
			/*-- Under 19 --*/
			over18=(dhh_age >= 19);

			/*-- Not pregnant --*/
			notPregnant=(mam_037 ^= 1);

			/*-- Not breastfeeding --*/
			notBreastfeeding=(mex_05 ^= 1);

			/*-- Complete alcohol use information --*/
			completeALC=(alc_1 in(1,2));

			/*-- Apply population exclusions --*/
			excessDrinking=excessDrinking*over18*notPregnant*notBreastfeeding*completeALC;
		%end;
	%else %if &indicator=currentDrinker %then
		%do;
			if alc_1=1 then
				currentDrinker=1;
			else currentDrinker=0;
		%end;
	%else %if &indicator=drinkingFrequency %then
		%do;
			d_less1Month=(alc_2=1);
			d_1Month=(alc_2=2);
			d_23Month=(alc_2=3);
			d_1Week=(alc_2=4);
			d_23Week=(alc_2=5);
			d_45Week=(alc_2=6);
			d_daily=(alc_2=7);
		%end;
	%else %if &indicator=heavyDrinking %then
		%do;
			if alc_3=1 then
				heavyDrinking=0;
			else if 2 <= alc_3 <= 6 then
				heavyDrinking=1;
			else heavyDrinking=0;
		%end;
	%else %if &indicator=consultMH %then
		%do;
			if cmh_01k=1 then
				consultMH=1;
			else if cmh_01k=2 then
				consultMH=0;
			else consultMH=.;
		%end;
	%else %if &indicator=lifeStress %then
		%do;
			if gen_07 in(4,5) then
				lifeStress=1;
			else if gen_07 in(1,2,3) then
				lifeStress=0;
			else lifeStress=.;
		%end;
	%else %if &indicator=workStress %then
		%do;
			if gen_09 in(4,5) then
				workStress=1;
			else if gen_09 in(1,2,3) then
				workStress=0;
			else workStress=.;
		%end;
	%else %if &indicator=selfRatedMentalHealth %then
		%do;
			if gen_02b in(1,2) then
				selfRatedMentalHealth=1;
			else if gen_02b in(3,4,5) then
				selfRatedMentalHealth=0;
			else selfRatedMentalHealth=.;
		%end;
	%else %if &indicator=senseBelonging %then
		%do;
			if gen_10 in(1,2) then
				senseBelonging=1;
			else if gen_10 in(3,4) then
				senseBelonging=0;
			else senseBelonging=.;
		%end;
	%else %if &indicator=generalHealth %then
		%do;
			if gen_01 in(1,2) then
				generalHealth=1;
			else if gen_01 in(3,4,5) then
				generalHealth=0;
			else generalHealth=.;
		%end;
	%else %if &indicator=OralandFacialPain %then
		%do;
			if oh2fofp=1 then
				OralandFacialPain=1;
			else if oh2fofp in(2,6) then
				OralandFacialPain=0;
			else OralandFacialPain=.;
		%end;
	%else %if &indicator=LeisurePA %then
		%do;
			if pacdpai in(1,2) then
				LeisurePA=1;
			else if pacdpai=3 then
				LeisurePA=0;
			else LeisurePA=.;
		%end;

	/* ...more statements to follow... */
%mend;