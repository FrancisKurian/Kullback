* dataset to create the base sample;
data base;
seed =100000;
call streaminit(seed);
do stickprov = 1 to 100000;
SalesVolume_Base =round(rand ('normal',350000,13000),10);
Deposits_Base = round(rand ('normal',75000,20000),10);
AdResponse_Base = round(rand ('normal',8000,800),10);
CBM_Base = round(rand ('normal',610,50),1);
output;
end;
drop seed;
run;
* creating the ttd population with introduction of real life scenarios to show drift in distributions;
data base2;
set base;
SalesVolume_Sim =SalesVolume_Base;
Deposits_sim=Deposits_Base;
AdResponse_sim=AdResponse_Base;
CBM_sim=CBM_Base;
if (0 <= SalesVolume_Sim <=341224) and  ranuni(100) <= 0.5 then SalesVolume_Sim =SalesVolume_Base*1.1;
if  ranuni(100) <= 0.2 then Deposits_sim=Deposits_sim/1000;
if  ranuni(100) <= 0.1 then AdResponse_sim=0;
if  CBM_sim > 643 and ranuni(100) <= 0.5 then CBM_sim=CBM_sim-200;
run;

* saving with renamed source for psi calculations;
data base3;
set base2;
SalesVolume_Base=SalesVolume_Sim;
Deposits_Base=Deposits_sim;
AdResponse_Base=AdResponse_sim;
CBM_base=CBM_sim;
run;

proc univariate data=base;
var SalesVolume_Base Deposits_Base AdResponse_Base CBM_Base;
run;

proc univariate data=base2;
var  AdResponse_base AdResponse_sim;
run;


ods listing gpath='/home/u53002792/chapman/PSI' ; *edit for the destination;
ods graphics / width=400px height=300px;

proc sgplot data=base2 noborder;
    histogram SalesVolume_base / transparency=0; 
    histogram SalesVolume_sim / transparency=0.8; 
    xaxis grid label='Sales Volume';
    yaxis grid label='% Observations';
run;
proc sgplot data=base2 noborder;
    histogram Deposits_base / transparency=0; 
    histogram Deposits_sim / transparency=0.8; 
    xaxis grid label='Deposits';
    yaxis grid label='% Observations';

run;
proc sgplot data=base2 noborder;
    histogram AdResponse_base / transparency=0; 
    histogram AdResponse_sim / transparency=0.8; 
    xaxis grid label='Ad Responses';
    yaxis grid label='% Observations';
run;
proc sgplot data=base2 noborder;
    histogram CBM_base / transparency=0; 
    histogram CBM_sim / transparency=0.8; 
    xaxis grid label='CBM Score Range';
    yaxis grid label='% Observations';
run;
ods listing close;



