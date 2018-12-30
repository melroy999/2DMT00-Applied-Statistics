* A macro that reports all outliers using the Doornbos test.

  data = the dataset.
  var = the variable of interest.
  out = the name of the dataset the output should be written to.
  alpha = the significance level to use.
  
  Note that outliers are marked with a value 1 in the outlier column.
;
%MACRO DOORNBOS(DATA, VAR, OUT, alpha=0.05);

ODS SELECT NONE;
PROC MEANS DATA=&data MEAN VAR N;
	VAR &var;
	OUTPUT OUT=OUT MEAN=MEAN VAR=VAR N=N;
RUN;

DATA &out;
	SET &data;
	if _n_ = 1 THEN SET OUT;
	VAR_LOO = ((N - 1) / (N - 2)) * VAR - (N / ((N - 1) * (N - 2))) * (&var - MEAN)**2;
	W = ABS((&var - MEAN) / SQRT(VAR_LOO * (N - 1) / N));
	C = QUANTILE("T", 1 - &alpha / (2 * N), N - 2);
	P_VALUE = MIN(2 * N * (1 - CDF("T", W, N - 2)), 1);
	OUTLIER = (W > C);
	DROP _TYPE_ _FREQ_;
RUN;

DATA SORTED;
	SET &out;
RUN;

PROC SORT DATA=SORTED;
	BY DESCENDING W;
RUN;

ODS SELECT ALL;

TITLE1 "Outlier found using Doornbos' test (alpha = &alpha).";
TITLE2 "Variable: &var";

PROC PRINT DATA=SORTED(OBS=1) NOOBS LABEL;
	LABEL P_VALUE = "P-value" W="Statistic (|W|)" C="Critical value";
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
	DROP MEAN VAR VAR_LOO W C P_VALUE;
RUN;

%MEND DOORNBOS;