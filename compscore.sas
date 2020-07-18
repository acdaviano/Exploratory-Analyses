libname nhanes 'F:\NHANES NCHS project';
/*original dataset */
proc contents data=nhanes.all_1114;
run;

data nhanes.sum;
set nhanes.all_1114;
run;

/* univariate analysis*/
proc contents data=nhanes.sum;
run;

proc freq data=nhanes.sum;
tables gender age race race1 citizen country pir HHsize HHcountry HHedu HHmar chlamydia HIV HSVII STI 
depressed alcabstain alcreg alcexcess serumsmoke eversex sexorient sexfirst oralsex1 analsex2 
olderpart partsmf condom mancirc evermj everalldrug;;
run;
proc means data=nhanes.sum;
var age;
run;

/* creating summary variable*/
proc freq data=nhanes.sum;
tables hhsize hhedu pir hhcountry hhmar depressed alcreg alcexcess 
serumsmoke sexfirst oralsex1 analsex2 olderpart partsmf condom evermj everalldrug;
run;

* model the outcome for each indicator;
proc logistic data=nhanes.sum;
model sti=mancirc gender race;
run;

* create new variable for each indicator, equal to 1 or missing if 0;
data nhanes.sum1;
set nhanes.sum;
if depressed=2 then sumdepressed=1;
if depressed=1 then sumdepressed=0;
run;
proc freq data=nhanes.sum1;
tables sumdepressed sumdepressed*depressed;
run;

data nhanes.sum2;
set nhanes.sum1;
if alcreg=2 then sumalcreg=1;
if alcreg=1 then sumalcreg=0;
run;
proc freq data=nhanes.sum2;
tables sumalcreg sumalcreg*alcreg;
run;

data nhanes.sum3;
set nhanes.sum2;
if serumsmoke=2 then sumsmoke=1;
if serumsmoke=1 then sumsmoke=0;
run;
proc freq data=nhanes.sum3;
tables sumsmoke sumsmoke*serumsmoke;
run;

data nhanes.sum4;
set nhanes.sum3;
if evermj=2 or everalldrug=2 then sumdrug=1;
if evermj=1 or everalldrug=1 then sumdrug=0;
run;
proc freq data=nhanes.sum4;
tables sumdrug sumdrug*(evermj everalldrug);
run;

data nhanes.sum5;
set nhanes.sum4;
if sexfirst=2 then sumsexfirst=1;
if sexfirst=1 then sumsexfirst=0;
run;
proc freq data=nhanes.sum5;
tables sumsexfirst sumsexfirst*sexfirst;
run;

data nhanes.sum6;
set nhanes.sum5;
if oralsex1=1 then sumoral=1;
if oralsex1=2 then sumoral=0;
run;
proc freq data=nhanes.sum6;
tables sumoral sumoral*oralsex1;
run;

data nhanes.sum7;
set nhanes.sum6;
if analsex2=1 then sumanal=1;
if analsex2=2 then sumanal=0;
run;
proc freq data=nhanes.sum7;
tables sumanal sumanal*analsex2;
run;

data nhanes.sum8;
set nhanes.sum7;
if olderpart=2 then sumolderpart=1;
if olderpart=1 then sumolderpart=0;
run;
proc freq data=nhanes.sum8;
tables sumolderpart sumolderpart*olderpart;
run;

data nhanes.sum9;
set nhanes.sum8;
if partsmf=2 then sumpartners=1;
if partsmf=1 then sumpartners=0;
run;
proc freq data=nhanes.sum9;
tables sumpartners sumpartners*partsmf;
run;

data nhanes.sum10;
set nhanes.sum9;
if condom=1 then sumcondom=0;
if condom=2 then sumcondom=1;
run;
proc freq data=nhanes.sum10;
tables sumcondom sumcondom*condom;
run;

proc freq data=nhanes.sum10;
tables sti*(sumdepressed sumalcreg sumsmoke sumdrug sumsexfirst sumoral sumanal sumolderpart sumpartners sumcondom);
run;

* create summary variable;
data nhanes.sumsyndemic;
set nhanes.sum10;
syndemicscore=sum(sumdepressed + sumalcreg + sumsmoke + sumdrug + sumsexfirst  + sumoral + sumanal + sumolderpart + sumpartners + sumcondom);
run;

proc gplot data=nhanes.sumsyndemic;
plot syndemicscore*sti/ haxis=1 to 2 by 0.2
						vaxis=0 to 10 by 1
						hminor=1
						regeqn;
run;

data nhanes.sumsyndemic1;
set nhanes.sumsyndemic;
if syndemicscore=. then syndemicscore=0;
run;
proc freq data=nhanes.sumsyndemic1;
tables syndemicscore sti*syndemicscore;
run;

data nhanes.sumsyndemic2;
set nhanes.sumsyndemic1;
if sti=2 then sti1=0;
if sti=1 then sti1=1;
run;
proc freq data=nhanes.sumsyndemic2;
tables sti1 sti1*sti;
run;

proc freq data=nhanes.sumsyndemic2;
tables syndemicscore;
run;
*create range variable for the syndemic regression;
data nhanes.sumsyndemic3;
set nhanes.sumsyndemic2;
if syndemicscore LT 3 then synscore=0;
if syndemicscore GE 3 LT 6 then synscore=1;
if syndemicscore GE 6 then synscore=2;
run;
proc freq data=nhanes.sumsyndemic3;
tables synscore synscore*syndemicscore;
run;

*genmod with reduced levels;
proc genmod data=nhanes.sumsyndemic3 descending;
class seqn syndemicscore (ref = first)/ param=glm;
model sti1 = synscore / dist=bin link=logit cl; 
repeated subject = seqn/type = unstr; 
estimate 'syndemic 1-2' synscore 0 -1/exp;
estimate 'syndemic 3-5' synscore 1 -1/exp;
estimate 'syndemic 6-9' synscore 2 -1/exp;
run;

*proc gemod for regression to reference each level;
proc genmod data=nhanes.sumsyndemic2 descending;
class seqn syndemicscore (ref = first)/ param=glm;
model sti1 = syndemicscore / dist=bin link=logit cl; 
repeated subject = seqn/type= unstr;
estimate 'syndemic 1' syndemicscore 0 1 0 0 0 0 0 0 0 0/exp;
estimate 'syndemic 2' syndemicscore 0 0 1 0 0 0 0 0 0 0/exp;
estimate 'syndemic 3' syndemicscore 0 0 0 1 0 0 0 0 0 0/exp;
estimate 'syndemic 4' syndemicscore 0 0 0 0 1 0 0 0 0 0/exp;
estimate 'syndemic 5' syndemicscore 0 0 0 0 0 1 0 0 0 0/exp;
estimate 'syndemic 6' syndemicscore 0 0 0 0 0 0 1 0 0 0/exp;
estimate 'syndemic 7' syndemicscore 0 0 0 0 0 0 0 1 0 0/exp;
estimate 'syndemic 8' syndemicscore 0 0 0 0 0 0 0 0 1 0/exp;
estimate 'syndemic 9' syndemicscore 0 0 0 0 0 0 0 0 0 1/exp;
run;






