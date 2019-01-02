* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
RUN;

* First, we check whether the provided unit ids follow an uniform distribution.
  The goal if this test is to detect cherry-picking for the provided samples.
  
  For this purpose, we use a chi-squared test. Note however that it is risky to 
  apply it in this situation, since both requirements are not valid: 
  	- Expected values are larger than 1 for all cells
  	- Expected values are larger than 5 for more than 80% of all cells
  
  However, the alternative requires a small sample size and works only on two groups.
  
  Additionally, we should be careful, since units 28, 29 and 30 do not occur.
;

* Convert the data to a frequency table;
PROC FREQ DATA=EXPANDED;
	TABLES UNIT / OUT=FREQ;
RUN;

* Do we have missing values in our range?;
DATA UNITS;
	DO UNIT=1 to 30;
		COUNT = 0;
		PERCENT = 0;
		OUTPUT;
	END;
RUN;

* Merge the two datasets;
PROC SQL;
	CREATE TABLE FREQ_M AS
	SELECT * FROM FREQ
	UNION
	SELECT * FROM UNITS WHERE UNIT NOT IN (SELECT UNIT FROM FREQ);
RUN;

* Check whether the chosen units are uniformly distributed by using a chisq test;
PROC FREQ DATA=FREQ_M;
	TABLE UNIT /MISSING CHISQ;
	WEIGHT COUNT /ZEROS;
	EXACT CHISQ /MC;
RUN;

* The exact test (with mc) reports a p-value of p /approx 0.8551 (depending on seed). 
  The null hypothesis is not rejected: the chosen sample ids are from an uniform distribution.
;




* Next, we check whether the selection can be considered random in the scope of a batch.

  Note that we should take the result of this test with a grain of salt, since each value 
  only occurs once per batch.
;

* Convert the data to a frequency table and group on batches;
PROC FREQ DATA=EXPANDED;
	BY BATCH;
	TABLES UNIT / OUT=FREQ;
RUN;

* Find the missing values and fill them in;
DATA UNITS;
	DO BATCH_ID=0 to 7;
		DO UNIT=1 to 30;
			BATCH = cats('B', BATCH_ID);
			COUNT = 0;
			PERCENT = 0;
			OUTPUT;
		END;
	END;
	DROP BATCH_ID;
RUN;

* Merge the two datasets;
PROC SQL;
	CREATE TABLE FREQ_M AS
	SELECT * FROM FREQ
	UNION
	SELECT BATCH, UNIT, COUNT, PERCENT FROM UNITS WHERE NOT EXISTS (
		SELECT FREQ.BATCH, FREQ.UNIT FROM FREQ 
		WHERE UNITS.BATCH EQ FREQ.BATCH AND UNITS.UNIT EQ FREQ.UNIT
	);
RUN;

* Check whether the chosen units are uniformly distributed by using a chisq test;
PROC FREQ DATA=FREQ_M;
	BY BATCH;
	TABLE UNIT /MISSING CHISQ;
	WEIGHT COUNT /ZEROS;
	EXACT CHISQ /MC;
RUN;

* In all cases, the exact test reports a p-value of p=1.
;



