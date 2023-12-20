%macro divergence_estimator(data_col,base,ttd,dec);
proc rank data=&base
out = v1_out
groups = &dec;
var &data_col;
ranks decile;
run;
data v1_out;
set v1_out;
decile =decile+1;
run;

proc means noprint data =v1_out;
class decile;
var &data_col;
output out = sample1_sum
min=begin
max=end
mean=avg;
run;

data sample1_sum base_tot;
set sample1_sum;
class_label = compress(begin || "-"|| end);
if _type_ =0 then output base_tot;else output sample1_sum;
run;

Data _Null_;
Set base_tot;
Call Symput('base_total',_freq_);
Call Symput('base_min',begin);
Call Symput('base_max',end);
run;

*create the format ;
data ctrl;
   length label $ 20;
   set sample1_sum(rename=(begin=start class_label=label)) end=last;
   retain fmtname 'class_fmt' type 'n';
   output;
run;
proc format library=work cntlin=ctrl;
run;

* End of Baseline Decile creation ;


* create data matrix with percentage baseline ;

proc freq data= &base noprint;
tables &data_col/missing out=baseline(rename=(count=basecount) drop=percent) ; 
format &data_col class_fmt.;
run;
data baseline;
set baseline;
decile =_n_;
run;

* Create validation data;
data sample2;
set &ttd;
* handle outliers in the through the door population. Assign them to nearest bucket;
if &data_col <= &base_min then &data_col= &base_min;
if &data_col >= &base_max then &data_col= &base_max;
run;
proc sql noprint;
 select count(*) into :ttd_total from sample2;
quit;

proc freq data= sample2 noprint;
tables &data_col/missing out=ttd(rename=(count=ttdcount) drop=percent) ; 
format &data_col class_fmt.;
run;


* combine baseline and ttd  distributions;
proc sort data= baseline;by  &data_col;
proc sort data= ttd;by  &data_col;


data matrix;
merge baseline (in=a) ttd(in=b);
by  &data_col;
if a=b;
if a=b then match='Yes';else match='No';
if ttdcount =.  then ttdcount=0;
basepercent =basecount/&base_total;
ttdpercent =ttdcount/&ttd_total;
format basepercent ttdpercent percent10.;

run;


proc sgplot data=matrix;
series x= decile y=basepercent/ smoothconnect lineattrs=(thickness=3);
series x= decile y=ttdpercent /smoothconnect lineattrs=(thickness=3);
yaxis 
grid;
xaxis grid  type=discrete fitpolicy=none;;
TITLE "&data_col :Baseline vs Through the Door distribution of data";
run;

* compute psi statistics;
data matrix;
set matrix;
psi_part = log(ttdpercent/basepercent)*(ttdpercent-basepercent);
if psi_part =. then psi_part=0;
log_ttd2base=round(log(ttdpercent/basepercent),.0001);
diff_ttd2base=round(ttdpercent-basepercent,.0001);
run;
proc print data= matrix noobs;
 var decile &data_col basepercent ttdpercent diff_ttd2base log_ttd2base psi_part;
 sum psi_part;
Title "PSI Calculation:&data_col";
run;
%mend;

%divergence_estimator(SalesVolume_Base,base,base3,10);
%divergence_estimator(Deposits_Base,base,base3,10);
%divergence_estimator(AdResponse_base,base,base3,10);
%divergence_estimator(CBM_base,base,base3,10);

%divergence_estimator(SalesVolume_Base,base,base3,20);
%divergence_estimator(Deposits_Base,base,base3,20);
%divergence_estimator(AdResponse_base,base,base3,20);
%divergence_estimator(CBM_base,base,base3,20);



