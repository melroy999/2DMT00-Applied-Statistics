* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
	IF BRID EQ 'B0-1' OR BRID EQ 'B0-2' THEN BRID = 'B0';
RUN;

DATA EXPANDEDBC;
	SET EXPANDED;
	OUTCOMEMINUS1= (-1)*((OUTCOME-1)**-1);
	OUTCOME0= log(OUTCOME);
	OUTCOME13= (3)*((OUTCOME-1)**(1/3));
RUN;

* Find the quantiles;
PROC SORT DATA=EXPANDEDBC;
	BY OUTCOME13;
RUN;

* OUTCOME0: p25 = 0.2468600779, p75 = 1.5347143662;
* OUTCOME13: p25 = 2.6879196923, p75 = 4.9158824806;
* OUTCOMEMINUS1: p25 = -1.19047619, p75 = -0.10460251;

* Use tukey's test to eliminate outliers;
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

PROC SORT DATA=TUKEY_NO;
	BY BATCH;
RUN;

PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME13;
	BY BATCH;
RUN;

* Using OUTCOME13, check whether the outcomes of B1 to B7 differ significantly 
  from B0 using a one-way ANOVA model with Dunnett's adjustement.
;

* Fit the data to an ANOVA model;
PROC MIXED DATA=TUKEY_NO METHOD=TYPE3 CL;
	CLASS BATCH;
	MODEL OUTCOME13 = BATCH /SOLUTION CL;
	LSMEANS BATCH / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;
* Batch B4 comes very close to a null hypothesis rejection;



* Using OUTCOME13, check whether the outcomes of B1-1 to B7-2 differ significantly 
  from B0 using a one-way ANOVA model with Dunnett's adjustement.
;

* Fit the data to an ANOVA model;
PROC MIXED DATA=TUKEY_NO METHOD=TYPE3 CL;
	CLASS BRID;
	MODEL OUTCOME13 = BRID /SOLUTION CL;
	LSMEANS BRID / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;
* Batch B4-1 and B4-2 are certainly not rejected;