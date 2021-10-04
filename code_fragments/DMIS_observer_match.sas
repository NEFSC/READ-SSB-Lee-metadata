 /*SAS code to link DMIS data to observer data */

libname test '~gardini/SAS/DMIS_Observer/only_2019';

proc sql;
	connect to oracle (user = gardini password = "MYACTUALPASSWORD" path = sole);

create view dmis_trips as select * from connection to oracle
(select * from APSD.t_ssb_trip_current@garfo_nefsc
where mult_year in (2019)
order by permit, trip_id);

create view dmis_catch as select * from connection to oracle
(select * from APSD.t_ssb_catch_current@garfo_nefsc
where trip_id like '2019%'
and fishery_group in ('GROUND', 'OTHER2')
order by permit, trip_id);

create view dmis_link_1 as select * from connection to oracle /*Used to get dmis_trip_id variable*/
(select docid, das_id, dmis_trip_id from APSD.MV_DMIS_MATCH_AMS_VTR@garfo_nefsc);

create view dmis_link_2 as select * from connection to oracle /*Used to get link1 variable to merge to observer data*/
(select dmis_trip_id, link1 from APSD.MV_DMIS_MATCH_OBS_LINK@garfo_nefsc
where link1 is not null); /*Need to have a link1 in order to match to observer data*/

disconnect from oracle;
quit;

proc sql;
        connect to oracle (user = gardini orapw = "XXXXXXXXXXXX" path = nova);

create view observed_trips as select * from connection to oracle
(select link1 from obdbs.obtrp
where year in ('2019', '2020')
union
select link1 from obdbs.asmtrp
where year in ('2019', '2020'));

disconnect from oracle;
  quit;



proc means noprint data=dmis_catch;
by permit trip_id;
vars dlr_dollar;
output out=dollar_by_trip sum=;


/*Merge DMIS trip and catch, then merge to Observed trips*/
data test.aa; /*7,690 obs.*/
merge dmis_trips (in=inone) dollar_by_trip (in=intwo);
by permit trip_id;
if inone=1; if intwo=1;
docid_1 = strip(put(docid, 32.)); drop docid; 
proc sort; by docid_1;

data test.bb; set dmis_link_1;
docid_1 = docid; drop docid;
proc sort nodupkey; by docid_1; /*there are multiple das_id per docid in some cases. Very confusing. Best to just go with docid for linking and avoid das_id*/

data test.cc; /*7,676 obs- loss of 14 obs.*/
merge test.aa (in=inone) test.bb (in=intwo);
by docid_1;
if inone=1; if intwo=1;
proc sort; by dmis_trip_id; /*there is only 1 dmis_trip_id per docid*/

data test.dd; set dmis_link_2;
proc sort; by dmis_trip_id; /*do not want to eliminate duplicate tripids here because multiple link1s can exist for each*/

data test.ee; /*1,427 obs.*/
merge test.cc (in=inone) test.dd (in=intwo);
by dmis_trip_id;
if inone=1; if intwo=1;
proc sort; by link1;

data test.ff; set observed_trips; /*pulled from obdbs*/
proc sort; by link1;

data test.observed_trips; merge test.ee (in=inone) test.ff (in=intwo); /*1,427 obs.*/ 
by link1; if inone=1; if intwo=1; 
/*Calculated observer coverage of 18.6% (1,427/7,690). Slightly below realized FY19 coverage rate of 21.9%
https://www.greateratlantic.fisheries.noaa.gov/ro/fso/reports//Sectors/ASM/FY2021_Multispecies_Sector_ASM_Requirements_Summary.pdf*/

















