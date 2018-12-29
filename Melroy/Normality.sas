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

* Find the quantiles;
PROC SORT DATA=EXPANDED;
	BY OUTCOME;
RUN;

PROC UNIVARIATE DATA=EXPANDED NOPRINT;
   VAR OUTCOME;
   OUTPUT OUT=PctlStrength p25=p25 p75=p75;
RUN;
* p25 = 1.28, p75 = 4.64;

* Use tukey's test;
DATA TUKEY;
	SET EXPANDED;
	p25 = 1.28;
	p75 = 4.64;
	IQR = p75 - p25;
	LOWERT = p25 - 1.5*IQR;
	UPPERT = p75 + 1.5*IQR;
	T = (OUTCOME > UPPERT OR OUTCOME < LOWERT);
RUN;

PROC SORT DATA=TUKEY;
	BY DESCENDING T;
RUN;

PROC PRINT DATA=TUKEY;
	WHERE T;
RUN;

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT T;
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
* Here, OUTCOMEMINUS1, OUTCOME0 and OUTCOME13 look closest to normal.

* Find the quantiles;
PROC SORT DATA=EXPANDEDBC;
	BY OUTCOME13;
RUN;

PROC UNIVARIATE DATA=EXPANDEDBC NOPRINT;
   VAR OUTCOME13;
   OUTPUT OUT=PctlStrength p25=p25 p75=p75;
RUN;
* OUTCOME0: p25 = 0.2468600779, p75 = 1.5347143662;
* OUTCOME13: p25 = 2.6879196923, p75 = 4.9158824806;
* OUTCOMEMINUS1: p25 = -1.19047619, p75 = -0.10460251;

* Use tukey's test;
DATA TUKEY;
	SET EXPANDEDBC;
	p25_0 = 2.6879196923;
	p75_0 = 4.9158824806;
	p25_13 = 2.6879196923;
	p75_13 = 4.9158824806;
	p25_M1 = 2.6879196923;
	p75_M1 = 4.9158824806;
	IQR_13 = p75_13 - p25_13;
	LOWERT_13 = p25_13 - 1.5*IQR_13;
	UPPERT_13 = p75_13 + 1.5*IQR_13;
	IQR_0 = p75_0 - p25_0;
	LOWERT_0 = p25_0 - 1.5*IQR_0;
	UPPERT_0 = p75_0 + 1.5*IQR_0;
	IQR_M1 = p75_M1 - p25_M1;
	LOWERT_M1 = p25_M1 - 1.5*IQR_M1;
	UPPERT_M1 = p75_M1 + 1.5*IQR_M1;
	T_13 = (OUTCOME13 > UPPERT_13 OR OUTCOME13 < LOWERT_13);
	T_0 = (OUTCOME0 > UPPERT_0 OR OUTCOME13 < LOWERT_0);
	T_M1 = (OUTCOMEMINUS1 > UPPERT_M1 OR OUTCOMEMINUS1 < LOWERT_M1);
RUN;

PROC SORT DATA=TUKEY;
	BY DESCENDING T_13;
RUN;

PROC PRINT DATA=TUKEY;
	WHERE T_13;
RUN;

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT T_13;
RUN;

* Check for normality;
PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME13;
	HISTOGRAM OUTCOME13 /NORMAL;
RUN;

* Not normal in any of the cases.



* What if we check per batch?
;

PROC SORT DATA=TUKEY;
	BY DESCENDING T_13;
RUN;

PROC PRINT DATA=TUKEY;
	WHERE T_13;
RUN;

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT T_13;
RUN;

PROC SORT DATA=TUKEY_NO;
	BY BATCH;
RUN;

PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME13;
	BY BATCH;
RUN;
* All are normal according to Shapiro-Wilk for OUTCOME13.
  The others tests are always near normal, in the range 0.025-0.05.
  
  Roughly the same holds for OUTCOME0.
  
  OUTCOMEMINUS1 does not consider B2 normal for any tests. The other batches all are for each test.
;



