* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
	IF BRID EQ 'B0-1' OR BRID EQ 'B0-2' THEN BRID = 'B0';
RUN;

%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT);
%TUKEY(DATA=RESULT, VAR=OUTCOME, OUT=TUKEY);

* Remove the outliers;
DATA TUKEY_NO;
	SET TUKEY;
	WHERE NOT OUTLIER;
RUN;

PROC SORT DATA=TUKEY_NO;
	BY BATCH;
RUN;

* Using OUTCOME of BC with gamma=0, check whether the outcomes of B1 to B7 differ significantly 
  from B0 using a one-way ANOVA model with Dunnett's adjustement.
;

* Fit the data to an ANOVA model;
PROC MIXED DATA=TUKEY_NO METHOD=TYPE3 CL;
	CLASS BATCH;
	MODEL OUTCOME = BATCH /SOLUTION CL;
	LSMEANS BATCH / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;
* Batch B2 and B3 get rejected;



* Using OUTCOME of BC with gamma=0, check whether the outcomes of B1-1 to B7-2 differ significantly 
  from B0 using a one-way ANOVA model with Dunnett's adjustement.
;

* Fit the data to an ANOVA model;
PROC MIXED DATA=TUKEY_NO METHOD=TYPE3 CL;
	CLASS BRID;
	MODEL OUTCOME = BRID /SOLUTION CL;
	LSMEANS BRID / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;
* Batch B2-2, B3-1, B3-2 and B7-1 get rejected;