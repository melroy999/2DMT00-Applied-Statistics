* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
RUN;

%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Tukey.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Hampel.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Grubbs.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Outliers/Doornbos.sas';
%include '/folders/myfolders/2DMT00-Applied-Statistics/Macros/Boxcox.sas';

/* %TUKEY(DATA=EXPANDED, VAR=OUTCOME, OUT=OUTCOME); */
/* %HAMPEL(DATA=EXPANDED, VAR=OUTCOME, OUT=OUTCOME); */
/* %GRUBBS(DATA=EXPANDED, VAR=OUTCOME, OUT=OUTCOME); */
/* %DOORNBOS(DATA=EXPANDED, VAR=OUTCOME, OUT=OUTCOME); */

%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=-2);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=-1);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=-1/2);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=-1/3);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=1/3);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=1/2);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=1);
%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=RESULT, lambda=2);