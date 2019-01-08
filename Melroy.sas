* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
	IF BRID EQ 'B0-1' OR BRID EQ 'B0-2' THEN BRID = 'B0';
RUN;

TITLE1 "Histogram of OUTCOME (buckets of unit size)";
proc sgplot data=EXPANDED;
	histogram OUTCOME / fillattrs=graphdata1 transparency=0.7 binwidth=1;
	yaxis grid; 
	xaxis values=(0 to 25 by 1);
run;
TITLE;

/* 
 *	A plot showing the frequency of the chosen units.
 * 	We expect to see an uniform random distribution here.
 */ 
proc freq data=EXPANDED nlevels;
	tables UNIT / plots=FreqPlot(scale=percent);
run;


%BOXCOX(DATA=EXPANDED, VAR=OUTCOME, OUT=EXPANDED, lambda=0, delta=-0.5);

* Get a simple impression of the distribution of the data;
PROC BOXPLOT DATA=EXPANDED;
	PLOT OUTCOME*TIME;
RUN;

PROC MEANS DATA=EXPANDED MEDIAN MEAN MIN MAX N;
	VAR OUTCOME;
	CLASS TIME;
	OUTPUT OUT=MEANS MEDIAN=MEDIAN MIN=MIN MAX=MAX MEAN=MEAN;
RUN;

PROC SQL;
	CREATE TABLE OUTCOME AS
	SELECT * FROM EXPANDED, MEANS WHERE EXPANDED.TIME = MEANS.TIME;
RUN;

TITLE1 "Boxplot of OUTCOME grouped by TIME";
PROC SGPLOT DATA=OUTCOME;
	BAND X=TIME LOWER=MIN UPPER=MAX /FILLATTRS=(TRANSPARENCY=0.8 COLOR=GREEN) LEGENDLABEL="Min-Max band"; 
	VBOX OUTCOME /CATEGORY=TIME LEGENDLABEL="Outcome";
RUN;
TITLE;

TITLE1 "Boxplot of OUTCOME grouped by BATCH";
PROC SGPLOT DATA=OUTCOME;
	BAND X=BATCH LOWER=MIN UPPER=MAX /FILLATTRS=(TRANSPARENCY=0.8 COLOR=GREEN) LEGENDLABEL="Min-Max band"; 
	VBOX OUTCOME /CATEGORY=BATCH LEGENDLABEL="Outcome";
RUN;
TITLE;


* What if we combine the batch and run ids;
PROC MEANS DATA=EXPANDED MEDIAN MEAN MIN MAX N;
	VAR OUTCOME;
	CLASS BRID;
	OUTPUT OUT=MEANS MEDIAN=MEDIAN MIN=MIN MAX=MAX MEAN=MEAN;
RUN;

PROC SQL;
	CREATE TABLE OUTCOME AS
	SELECT * FROM EXPANDED, MEANS WHERE EXPANDED.BRID = MEANS.BRID;
RUN;

TITLE1 "Boxplot of OUTCOME grouped by BRID";
PROC SGPLOT DATA=OUTCOME;
	BAND X=BRID LOWER=MIN UPPER=MAX /FILLATTRS=(TRANSPARENCY=0.8 COLOR=GREEN) LEGENDLABEL="Min-Max band"; 
	VBOX OUTCOME /CATEGORY=BRID LEGENDLABEL="Outcome";
RUN;
TITLE;