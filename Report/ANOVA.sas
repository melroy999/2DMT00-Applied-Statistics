%include '/folders/myfolders/2DMT00-Applied-Statistics/Report/Macros/ImportData.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Report/Macros/Misc.sas';

%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Tukey.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Hampel.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Boxcox.sas';

* Import the dataset and call is SAMPLES;
%IMPORT_DATA(SASDATA.Assignment2, SAMPLES);

* Make the data normal and remove the outliers;
%BOXCOX(DATA=SAMPLES, VAR=OUTCOME, OUT=SAMPLES_NORMALIZED, lambda=0, delta=-0.40, normalityTest=0);
%TUKEY(DATA=SAMPLES_NORMALIZED, VAR=OUTCOME, OUT=SAMPLES_NORMALIZED);
%REMOVE_MARKED_OUTLIERS(DATA=SAMPLES_NORMALIZED, OUT=SAMPLES_N_MO);

/*  ===========================================================================================
 *	Fit the ANOVA model and draw conclusions.
 *  ===========================================================================================  */

* Fit the data to an ANOVA model;
PROC MIXED DATA=SAMPLES_N_MO METHOD=TYPE3 CL;
	CLASS BATCH;
	MODEL OUTCOME = BATCH /SOLUTION CL;
	LSMEANS BATCH / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;

/*  ===========================================================================================
 *	Fit the ANOVA model and draw conclusions. In this variant, we will use the BRID instead of BATCH.
 *  ===========================================================================================  */

* Fit the data to an ANOVA model;
PROC MIXED DATA=SAMPLES_N_MO METHOD=TYPE3 CL;
	CLASS BRID;
	MODEL OUTCOME = BRID /SOLUTION CL;
	LSMEANS BRID / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;