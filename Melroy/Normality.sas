%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Tukey.sas';

* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
RUN;



* First check whether the overall data is normally distributed;
PROC UNIVARIATE DATA=EXPANDED NORMAL;
	VAR OUTCOME;
	HISTOGRAM OUTCOME /NORMAL;
RUN;
* All of the available tests indicate that the data is not normally distributed;



* Do the same check per batch. Are some normally distributed?;
PROC UNIVARIATE DATA=EXPANDED NORMAL;
	VAR OUTCOME;
	BY BATCH;
	HISTOGRAM OUTCOME /NORMAL;
RUN;
* It would seem that batch 2, 3, 4 and 7 are normally distributed.





* Is the overall data normally distributed if we remove outliers using tukey's method?
;

%TUKEY(DATA=EXPANDED, VAR=OUTCOME, OUT=TUKEY);

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT OUTLIER;
RUN;

* Check for normality;
PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME;
	HISTOGRAM OUTCOME /NORMAL;
RUN;


* All of the available tests indicate that the data is not normally distributed;

* What if we do so per batch?
;
PROC SORT DATA=TUKEY_NO;
	BY BATCH;
RUN;

PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME;
	BY BATCH;
	HISTOGRAM OUTCOME /NORMAL;
RUN;
* It would seem that batch 2, 3, 4 and 7 are normally distributed.


* What if we apply a box-cox transformation?
;

DATA EXPANDEDBC;
	SET EXPANDED;
	OUTCOMEMINUS2= (-1/2)*((OUTCOME-1)**-2);
	OUTCOMEMINUS1= (-1)*((OUTCOME-1)**-1);
	OUTCOMEMINUS12= (-2)*((OUTCOME-1)**-(0.5));
	OUTCOME0= log(OUTCOME);
	OUTCOME13= (3)*((OUTCOME-1)**(1/3));
	OUTCOME12= (2)*((OUTCOME-1)**(1/2));
	OUTCOME2= (0.5)*((OUTCOME-1)**(2));
RUN;

proc univariate data=EXPANDEDBC;
	histogram OUTCOMEMINUS2 /normal;
	histogram OUTCOMEMINUS1 /normal;
	histogram OUTCOMEMINUS12 /normal;
	histogram OUTCOME0 /normal;
	histogram OUTCOME13 /normal;
	histogram OUTCOME12 /normal;
	histogram OUTCOME2 /normal;
	histogram OUTCOME /normal;
run;
* Here, OUTCOMEMINUS1, OUTCOME0 and OUTCOME13 look closest to normal;

%TUKEY(DATA=EXPANDEDBC, VAR=OUTCOME13, OUT=TUKEY);

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT OUTLIER;
RUN;

* Check for normality;
PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME0;
	HISTOGRAM OUTCOME0 /NORMAL;
RUN;

* Not normal in any of the cases.
  Note that most of the outliers are missing values;



/* * What if we check per batch? */
/* ; */
/*  */
/* PROC SORT DATA=TUKEY; */
/* 	BY DESCENDING T_13; */
/* RUN; */
/*  */
/* PROC PRINT DATA=TUKEY; */
/* 	WHERE T_13; */
/* RUN; */
/*  */
/* * Remove the outliers; */
/* DATA TUKEY_NO; */
/* 	SET TUKEY; */
/* 	WHERE NOT T_13; */
/* RUN; */
/*  */
/* PROC SORT DATA=TUKEY_NO; */
/* 	BY BATCH; */
/* RUN; */
/*  */
/* PROC UNIVARIATE DATA=TUKEY_NO NORMAL; */
/* 	VAR OUTCOME13; */
/* 	BY BATCH; */
/* RUN; */
/* * All are normal according to Shapiro-Wilk for OUTCOME13. */
/*   The others tests are always near normal, in the range 0.025-0.05. */
/*    */
/*   Roughly the same holds for OUTCOME0. */
/*    */
/*   OUTCOMEMINUS1 does not consider B2 normal for any tests. The other batches all are for each test. */
/* ; */



