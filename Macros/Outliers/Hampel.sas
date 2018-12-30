* A macro that reports all outliers using Hampel's method.

  data = the dataset.
  var = the variable of interest.
  out = the name of the dataset the output should be written to.
  
  Note that outliers are marked with a value 1 in the outlier column.
;
%MACRO HAMPEL(DATA, VAR, OUT);

ODS SELECT NONE;
PROC MEANS DATA=&data MEDIAN;
	VAR &var;
	OUTPUT OUT=MEDIAN MEDIAN=MEDIAN;
RUN;

DATA &out;
	SET &data;
	if _n_ = 1 THEN SET MEDIAN;
	ABS_DEV = ABS(&var - MEDIAN);
RUN;

PROC MEANS DATA=&out MEDIAN;
	VAR ABS_DEV;
	OUTPUT OUT=ABS_DEV_MEDIAN MEDIAN=ABS_DEV_MEDIAN;
RUN;

DATA &out;
	SET &out;
	IF _n_ = 1 THEN SET ABS_DEV_MEDIAN;
	ABS_NORM_VAL = ABS_DEV / ABS_DEV_MEDIAN;
	OUTLIER = NOT (ABS_NORM_VAL <= 3.5);
	DROP _TYPE_ _FREQ_;
RUN;

/* PROC SORT DATA=&out; */
/* 	BY DESCENDING ABS_NORM_VAL; */
/* RUN; */
ODS SELECT ALL;

TITLE1 "Outliers found using Hampel's method.";
TITLE2 "Variable: &var";

PROC PRINT DATA=&out NOOBS LABEL;
	LABEL ABS_NORM_VAL = "Absolute normalized value (z_k)";
	WHERE OUTLIER;
RUN;
TITLE;

DATA &out;
	SET &out;
	DROP MEDIAN ABS_DEV ABS_NORM_VAL;
RUN;

%MEND HAMPEL;