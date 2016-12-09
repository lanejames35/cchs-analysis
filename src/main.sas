/**
	Program: Setup.sas
	Version: 1.1
	Author: James Lane
	Created: 05DEC16
	Updated: 08DEC16
	Synopsis: This program provides a template for creating a dataset from the CCHS master suitable for use with bootstrapping a ratio.

	==================
	CCHS Setup Program
	==================
	In order to prevalence rates from the CCHS, a dataset must be created from the CCHS master with the correct dummy
	coding applied. This program an the attached macros provide a template for creating such a dataset after which bootstrapping
	can be executed. 
	
	The program is made up of three steps. Step one is the selection of a CCHS indicator for analysis; step two is the selection of data years
	to include in the analysis; and step three involves computing the dummy coding for bootstrapping.

	STEP ONE - Select indicator
	---------------------------
	An indicator from the CCHS is required and must be specified as an arguement to the %indicatorSetUp macro (see instructions below). To facilitate the selection,
	this program pulls indicators from a set of metadata tables included with this package. Set the value of name=help for a list of accepted
	values for indicators available. Over time this list will be expanded to included additional indicators.

	STEP TWO - Select data years
	----------------------------
	A series of %let statements controls which data years that are included in the analysis dataset. For each data year, a toggle between the values of
	"yes" and "no" determines inclusion in the analysis dataset. By default, data from 2013/2014 is always selected. In addition, the user must specifiy
	the library / member name pair for each original CCHS dataset year under the variables cchs2007, cchs2009, etc.

		N.B. a LIBNAME statement may be needed to tell SAS where to find the CCHS master datasets.

	STEP THREE - Compute dummy coding
	---------------------------------
	Dummy coding is calcuated for the analysis variable selected in step one, accoding to a set of instructions contain the in the macros %makeCCHSNumerator
	and %makeCCHSDenominator. No input is required from the user for setting the numerator; however, the denominator can be tweaked by passing a keyword to the 
	macro (see step three below).
	
*/

/**
	Include statemtnes need to reflect the directory where the programs are saved on your computer 
*/
%include "C:\path\to\file\indicatorSetUp.sas";
%include "C:\path\to\file\makeCCHSNumerator.sas";
%include "C:\path\to\file\makeCCHSDenominator.sas";
%include "C:\path\to\file\formats.sas";

/**
	==============================
	STEP ONE - Indicator selection
	==============================
	Change the value of the variable "name" to specifiy the CCHS indicator you would like to analyze.

	** Submit the macro with name=help to get a list of indiators that you can use.
	
*/
%indicatorSetUp(name=generalHealth)

/** 
	================================
	Step Two - Data year selections
	================================
	1. Use the "get" statements to toggle inclusion of the additional CCHS data years.
	---------------------
	For example:
			# to exclude 2007/2008 data, set get2007=no
			# to include 2011/2012 data, set get2011=yes
	---------------------

	2. Specify the library / member name of the master CCHS datasets.
	---------------------
	For example:
			# Tony has his CCHS datasets stored in C:\temp\CCHS
			# Tony MUST add a LIBNAME statement to point SAS to the files. In this case --> LIBNAME mydata "C:\temp\CCHS"
			# Tony can now change the values of cchs2007, cchs2009, cchs2011, cchs2013 to reflect the correct library and member name
			# In this case --> %let cchs2007=mydata.datasetName
	---------------------
	 
PERFORM THE CHANGES DESCRIBED ABOVE HERE */

/* Data set libraries -- Uncomment and change as needed */
/*libname CCHS "C:\path\to\CCHS\data";*/
%let get2007=no;
%let get2009=no;
%let get2011=no;
%let cchs2007=myLibrary.CCHS2007datafile;
%let cchs2009=myLibrary.CCHS2009datafile;
%let cchs2011=myLibrary.CCHS2011datafile;
%let cchs2013=myLibrary.CCHS2013datafile;


/* Created a small dataset from the raw CCHS data with only the variables of interest */
proc sql;
	create table _stepone as
		/* 2007 - 2008 data */
		%sysfunc(ifc(upcase(&get2007)=YES,%nrstr(select * from &cchs2007(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
								 ,%nrstr(%put Data for 2007/2008 not used;)
								 ,%nrstr(select * from &cchs2007(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
				))
		/* 2009 - 2010 data */
		%sysfunc(ifc(upcase(&get2007)=YES,%nrstr(select * from &cchs2009(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
								 ,%nrstr(%put Data for 2009/2010 not used;)
								 ,%nrstr(select * from &cchs2009(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
				))
		/* 2011 - 2012 data */
		%sysfunc(ifc(upcase(&get2007)=YES,%nrstr(select * from &cchs2011(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
								 ,%nrstr(%put Data for 2011/2012 not used;)
								 ,%nrstr(select * from &cchs2011(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis) union all)
				))
		/* 2013 - 2014 data */
		select * from &cchs2013(keep=ont_id wts_s geodhr4 mam_037 mex_05 &analysis)
	;
quit;

/**
	=====================================
	STEP THREE - Dummy coding indicators
	=====================================

	For %makeCCHSNumerator, no changes are need.
	For %makeCCHSDenominator, user can specify drinkingAge (19+), excludeDontKnow (remove don't know/refused/not answered) or total (all respondents)
*/
data analysisI;
	set work._stepone;
	keep ont_id wts_s phu geodhr4 total &in_name;

	%makeCCHSNumerator(&in_name)
	%makeCCHSDenominator(excludeDontKnow)

	/* recode year and health unit vars */
	year=left(trim(substr(ont_id,1,4)));
	/* See formats.sas to customize the public health unit used in the analysis */
	phu=put(geodhr4,phuName.);
run;


