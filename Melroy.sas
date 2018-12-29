* Set library;
LIBNAME SASDATA "/folders/myfolders/2DMT00-Applied-Statistics";

* Import .sas7bdat file from library;
DATA EXPANDED;
	SET SASDATA.Assignment2;
	BRID = catx('-', BATCH, RUN);
RUN;

proc sgplot data=EXPANDED;
	histogram OUTCOME / fillattrs=graphdata1 transparency=0.7 binwidth=1;
	yaxis grid; 
	xaxis values=(0 to 25 by 1);
run;

/* 
 *	A plot showing the frequency of the chosen units.
 * 	We expect to see an uniform random distribution here.
 */ 
proc freq data=EXPANDED nlevels;
	tables UNIT / plots=FreqPlot(scale=percent);
run;