* Import the dataset.

  data = the dataset.
  out = the name of the dataset the output should be written to.
;
%MACRO IMPORT_DATA(DATA, OUT);

* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA &OUT;
	SET &DATA;
	LENGTH BRID $4;
	BRID = catx('-', BATCH, RUN);
	IF BRID EQ 'B0-1' OR BRID EQ 'B0-2' THEN BRID = 'B0';
RUN;

%MEND IMPORT_DATA;