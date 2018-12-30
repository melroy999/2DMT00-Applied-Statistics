* A macro that reports all outliers using Grubbs' test.

  data = the dataset.
  var = the variable of interest.
  out = the name of the dataset the output should be written to.
  alpha = the significance level to use.
  
  Note that outliers are marked with a value 1 in the outlier column.
;
%MACRO GRUBBS(DATA, VAR, OUT, alpha=0.05);

ODS SELECT NONE;
PROC MEANS DATA=&data MEAN VAR N;
	VAR &var;
	OUTPUT OUT=OUT MEAN=MEAN VAR=VAR N=N;
RUN;

DATA &out;
	SET &data;
	if _n_ = 1 THEN SET OUT;
	U = ABS((&var - MEAN) / SQRT(VAR));
	T = QUANTILE("T", &alpha / (2 * N), N - 2);
	C = (N - 1) * sqrt(T**2 / (N * (T**2 + N - 2)));
	U_INV = U * SQRT((N - 2) * N) / SQRT(1 - (U**2 - (N - 2)) * N);
	P_VALUE = MIN(2 * N * (1 - CDF("T", U_INV, N - 2)), 1);
	OUTLIER = (U > C);
	DROP _TYPE_ _FREQ_;
RUN;

DATA SORTED;
	SET &out;
RUN;

PROC SORT DATA=SORTED;
	BY DESCENDING U;
RUN;

ODS SELECT ALL;

TITLE1 "Outlier found using Grubb's test (alpha = &alpha).";
TITLE2 "Variable: &var";

PROC PRINT DATA=SORTED(OBS=1) NOOBS LABEL;
	LABEL P_VALUE = "P-value" U="Statistic (|u|)" C="Critical value";
	WHERE OUTLIER;
RUN;
TITLE;

* Ensure that the output contains only one outlier;
PROC SQL;
	CREATE TABLE NON_OUTLIERS AS
	SELECT * 
	FROM &out
	EXCEPT ALL 
	SELECT * 
	FROM SORTED(OBS=1);
RUN;

DATA NON_OUTLIERS;
	SET NON_OUTLIERS;
	OUTLIER = 0;
RUN;

PROC SQL;
	CREATE TABLE &out AS
	SELECT *
	FROM SORTED(OBS=1)
	UNION
	SELECT *
	FROM NON_OUTLIERS;
RUN;

DATA &out;
	SET &out;
	DROP MEAN VAR N U T C U_INV P_VALUE;
RUN;

%MEND GRUBBS;