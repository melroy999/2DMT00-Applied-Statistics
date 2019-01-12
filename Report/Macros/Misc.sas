* Remove outliers from the dataset that have been marked as outliers.

  data = the dataset.
  out = the dataset which we should output to.
;
%MACRO REMOVE_MARKED_OUTLIERS(DATA, OUT);

* Remove the outliers;
DATA &OUT;
	SET &DATA;
	WHERE NOT OUTLIER;
RUN;

%MEND REMOVE_MARKED_OUTLIERS;