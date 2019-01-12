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
 *	First, we have to determine which test is most appropriate.
 * 	In practice, this is a choice between the Anderson-Darling and the Shapiro-Wilk tests.
 * 	Thus, we should check whether the data contains ties.
 *  ===========================================================================================  */

* Find the number of entries;
PROC MEANS DATA=SAMPLES N;
	VAR OUTCOME;
RUN;

* Find the number of entries per batch;
PROC MEANS DATA=SAMPLES N;
	VAR OUTCOME;
	BY BATCH;
RUN;

* Find the number of entries per brid;
PROC MEANS DATA=SAMPLES N;
	VAR OUTCOME;
	BY BRID;
RUN;

* Generate a frequency table for outcome;
PROC FREQ DATA=SAMPLES NLEVELS;
	TABLES OUTCOME;
RUN;

* Generate a frequency table for outcome per batch;
PROC FREQ DATA=SAMPLES NLEVELS;
	TABLES OUTCOME;
	BY BATCH;
RUN;

* Generate a frequency table for outcome per brid;
PROC FREQ DATA=SAMPLES NLEVELS;
	TABLES OUTCOME;
	BY BRID;
RUN;

/*  
	In general, the Shapiro-Wilk test can be used when occasional ties occur.
	
	As seen in the results above, a considerable amount of ties exist in the original data.
	This would imply that the Anderson-Darling is more powerful than Shapiro-Wilk in this context.

	It would seem that the Shapiro-Wilk test becomes more conservative when ties exist:
	"Sensitive to ties in the data: when ties are a result of rounding, than normality can incorrectly be rejected"
	
	We have that the results are rounded with a grouping interval of 0.1 au, which implies that ties might be a result of rounding.
	
	Thus, if normality is accepted by Shapiro-Wilk with ties, we can still use it to assert normality.
 */

/*  ===========================================================================================
 *	Next, we may check whether the data is normally distributed our chosen test.
 *  ===========================================================================================  */

* Check for overall normality;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_N_MO NORMAL;
	VAR OUTCOME;
RUN;
ODS SELECT ALL;

* Check for normality in the individual batches;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_N_MO NORMAL;
	VAR OUTCOME;
	BY BATCH;
RUN;
ODS SELECT ALL;

/*  
	For our choice of delta=-0.50 in the boxcox transformation, the data is normally distributed.
	This observation holds for both the overall picture and on a batch per batch basis.
 */

/*  ===========================================================================================
 *	Next, we should check whether the residuals in the ANOVA model are normally distributed.
 *  ===========================================================================================  */

* Fit the data to an ANOVA model;
PROC MIXED DATA=SAMPLES_N_MO METHOD=TYPE3 CL;
	CLASS BATCH;
	MODEL OUTCOME = BATCH /SOLUTION OUTP=SAMPLES_PRED CL;
	LSMEANS BATCH / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;

* Find the number of entries;
PROC MEANS DATA=SAMPLES_PRED N;
	VAR RESID;
RUN;

* Generate a frequency table for the residials;
PROC FREQ DATA=SAMPLES_PRED NLEVELS;
	TABLES RESID;
RUN;

* Check for normality;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_PRED NORMAL;
	VAR RESID;
RUN;
ODS SELECT ALL;

/*
	The test above shows that the residuals are normally distributed.
*/

/*  ===========================================================================================
 *	Finally, we should check the homogeneity of the risidual variance across the groups.
 *  ===========================================================================================  */

* Test the homogeneity of residual variances using different tests;
ODS SELECT HOVFTest BARTLETT;
PROC GLM DATA=SAMPLES_PRED;
	CLASS BATCH;
	MODEL RESID = BATCH;
	MEANS BATCH / HOVTEST=BF;
	MEANS BATCH / HOVTEST=BARTLETT;
	MEANS BATCH / HOVTEST=LEVENE;
	MEANS BATCH / HOVTEST=LEVENE(TYPE=ABS);
ODS GRAPHICS OFF;
RUN;
ODS GRAPHICS ON;

/*
	It would appear that the homogeneity of the risidual variance assumption is violated.
*/

*   ###########################################################################################;
*   ###########################################################################################;
*   ###########################################################################################;
*   ###########################################################################################;
*   ###########################################################################################;

/*  ===========================================================================================
 *	Next, we may check whether the data is normally distributed our chosen test.
 * 	In this variant, we will use the BRID instead of BATCH.
 *  ===========================================================================================  */

* Check for overall normality;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_N_MO NORMAL;
	VAR OUTCOME;
RUN;
ODS SELECT ALL;

* Check for normality in the individual batches;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_N_MO NORMAL;
	VAR OUTCOME;
	BY BRID;
RUN;
ODS SELECT ALL;

/*  
	For our choice of delta=-0.50 in the boxcox transformation, the data is normally distributed.
	This observation holds for both the overall picture and on a batch per batch basis.
 */

/*  ===========================================================================================
 *	Next, we should check whether the residuals in the ANOVA model are normally distributed.
 * 	In this variant, we will use the BRID instead of BATCH.
 *  ===========================================================================================  */

* Fit the data to an ANOVA model;
PROC MIXED DATA=SAMPLES_N_MO METHOD=TYPE3 CL;
	CLASS BRID;
	MODEL OUTCOME = BRID /SOLUTION OUTP=SAMPLES_PRED CL;
	LSMEANS BRID / DIFF=CONTROL('B0') ADJUST=DUNNETT CL;
RUN;

* Find the number of entries;
PROC MEANS DATA=SAMPLES_PRED N;
	VAR RESID;
RUN;

* Generate a frequency table for the residials;
PROC FREQ DATA=SAMPLES_PRED;
	TABLES RESID;
RUN;

* Check for normality;
ODS SELECT TestsForNormality;
PROC UNIVARIATE DATA=SAMPLES_PRED NORMAL;
	VAR RESID;
RUN;
ODS SELECT ALL;

/*
	The test above shows that the residuals are normally distributed.
*/

/*  ===========================================================================================
 *	Finally, we should check the homogeneity of the risidual variance across the groups.
 * 	In this variant, we will use the BRID instead of BATCH.
 *  ===========================================================================================  */

* Test the homogeneity of residual variances using different tests;
ODS SELECT HOVFTest BARTLETT;
PROC GLM DATA=SAMPLES_PRED;
	CLASS BRID;
	MODEL RESID = BRID;
	MEANS BRID / HOVTEST=BF;
	MEANS BRID / HOVTEST=BARTLETT;
	MEANS BRID / HOVTEST=LEVENE;
	MEANS BRID / HOVTEST=LEVENE(TYPE=ABS);
ODS GRAPHICS OFF;
RUN;
ODS GRAPHICS ON;

/*
	It would appear that the homogeneity of the risidual variance assumption is NOT violated Bartlett's test.
	
	It is violated for Levene's test.
*/