*Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

*Import .sas7bdat file from library;
DATA  Assi;
	SET SASDATA.Assignment2;
RUN;

PROC UNIVARIATE DATA=Assi normal;
	VAR outcome;
	by batch;
	HISTOGRAM outcome/NORMAL;
RUN;

DATA AssiBOXCOX;
	SET Assi;
	outcomeMINUS2= (-1/2)*((outcome-1)**-2);
	outcomeMINUS1= (-1)*((outcome-1)**-1);
	outcomeMINUS12= (-2)*((outcome-1)**-(0.5));
	outcome0= log(outcome);
	outcome13= (3)*((outcome-1)**(1/3));
	outcome12= (2)*((outcome-1)**(1/2));
	outcome2= (0.5)*((outcome-1)**(2));
RUN;
proc univariate data=AssiBOXCOX normal;
	var outcomeMINUS2 outcomeMINUS1 outcomeMINUS12 outcome0 outcome13 outcome12 outcome2;
	histogram outcomeMINUS2 /normal;
	histogram outcomeMINUS1 /normal;
	histogram outcomeMINUS12 /normal;
	histogram outcome0 /normal;
	histogram outcome13 /normal;
	histogram outcome12 /normal;
	histogram outcome2 /normal;
run;