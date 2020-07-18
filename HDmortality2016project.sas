/*load the file
FILENAME REFFILE '/folders/myshortcuts/General_Data2/Heart_Disease_Mortality_Data_Among_US_Adults__35___by_State_Territory_and_County___2015-2017.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=GD2.HDmort;
	GETNAMES=YES;
RUN;*/

/*View the contents of what we loaded
PROC CONTENTS DATA=GD2.HDmort; RUN;*/

/*look at the data to see what is missing
proc means data = GD2.HDmort n nmiss mean min max range;
run;*/

/*first drop the columns we dont need then assess the missing data from what we see above
data GD2.HDmort1;
	set GD2.HDmort (drop = Y_lat X_lon DataSource year topic);
run;*/

/*look at the data to see what is missing after dropping lat and lon
proc means data = GD2.HDmort1 n nmiss mean min max range;
run;*/

proc freq data= GD2.HDmort1 nlevels;
	table topic;
run;

/*reformat the values as needed
data GD2.HDmort1;
	set GD2.HDmort1;
	format */