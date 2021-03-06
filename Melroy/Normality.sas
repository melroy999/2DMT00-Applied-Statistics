%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Tukey.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Boxcox.sas';

* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
RUN;

/* ods graphics on; */
/* ods select Histogram GoodnessOfFit ParameterEstimates; */
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

%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=0, delta=-0.5);
%TUKEY(DATA=RESULT, VAR=OUTCOME, OUT=TUKEY);

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

* Not normal in any of the cases;



* What if we check per batch?
;

PROC SORT DATA=TUKEY;
	BY DESCENDING OUTLIER;
RUN;

PROC PRINT DATA=TUKEY;
	WHERE OUTLIER;
RUN;

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT OUTLIER;
RUN;

PROC SORT DATA=TUKEY_NO;
	BY BATCH;
RUN;

ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=TUKEY_NO NORMAL;
	VAR OUTCOME;
	BY BATCH;
RUN;
ODS SELECT ALL;
* All are normal according to Shapiro-Wilk for OUTCOME13.
  The others tests are always near normal, in the range 0.025-0.05.
  
  Roughly the same holds for OUTCOME0.
  
  OUTCOMEMINUS1 does not consider B2 normal for any tests. The other batches all are for each test.
;



