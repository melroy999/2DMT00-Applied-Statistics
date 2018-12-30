* A macro that reports all outliers using Tukey's method.

  data = the dataset.
  var = the variable of interest.
  out = the name of the dataset the output should be written to.
  
  Note that outliers are marked with a value 1 in the outlier column.
;
%MACRO TUKEY(DATA, VAR, OUT);

ODS SELECT NONE;
PROC MEANS DATA=&data MEDIAN P25 P75;
	VAR &var;
	OUTPUT OUT=QUANTILES P25=P25 P75=P75;
RUN;

DATA &out;
	SET &data;
	if _n_ = 1 THEN SET QUANTILES;
	IQR = P75 - P25;
	LOWER = P25 - 1.5 * IQR;
	UPPER = P75 + 1.5 * IQR;
	OUTLIER = NOT (&var >= LOWER AND &VAR <= UPPER);
	DROP _TYPE_ _FREQ_;
RUN;
ODS SELECT ALL;

TITLE1 "Outliers found using Tukey's method.";
TITLE2 "Variable: &var";

PROC PRINT DATA=&out NOOBS LABEL;
	LABEL LOWER = "Lower limit" upper="Upper limit" IQR = "Interquartile range (IQR)";
	WHERE OUTLIER;
RUN;
TITLE;

DATA &out;
	SET &out;
	DROP LOWER UPPER IQR P25 P75;
RUN;

%MEND TUKEY;