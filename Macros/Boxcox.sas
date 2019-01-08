* Perform a boxcox tranformation upon the given dataset.

  data = the dataset.
  var = the variable of interest.
  out = the name of the dataset the output should be written to.
  lambda = the boxcox parameter.
  delta = a correction that makes the var strictly positive.
  
  Note that this version is not the one given in the lecture: 
  the -1 component has been moved to avoid calculation errors.
;
%MACRO BOXCOX(DATA, VAR, OUT, lambda=0, VAROUT=&VAR, delta=0);

PROC SQL;
	CREATE TABLE METADATA AS
	SELECT MIN(OUTCOME) AS MIN
	FROM &DATA; 
RUN;

DATA METADATA;
	SET METADATA;
	MIN_PLUS_DELTA = MIN + &delta;
	LAMBDA = &lambda;
RUN;

TITLE1 'Minimum value should be corrected through delta such that VAR + delta > 0.';
PROC PRINT DATA=METADATA NOOBS;
RUN;
TITLE;

DATA &OUT;
	SET &DATA;
	IF &lambda = 0 THEN &VAROUT = LOG(&VAR + &delta);
	ELSE &VAROUT = ((&VAR + &delta)**&lambda - 1) /&lambda;
RUN;

PROC UNIVARIATE DATA=&OUT NORMAL;
	VAR &VAROUT;
	HISTOGRAM &VAROUT /NORMAL;
RUN;

%MEND BOXCOX;