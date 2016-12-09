/* Set up the public health unit for the analysis */
/* This example uses Durham Region */
/* Refer to the CCHS documentation for a complete list of PHU numbers under GEODHR4 */
proc format;
	value phuName 3530="My PHU"
			  	  other="Ontario"
			  	  ;
run;