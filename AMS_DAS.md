# Overview
These are the three schema that track Allocations.  DAS begat DAS2. DAS2 begat AMS.

Tables: 

AMS can be found in the NEFSC_GARFO schema. The relevant tables are prefixed with AMS_.
DAS can be found in the NEFSC_GARFO schema, the relevant tables are prefixed with DAS_.
DAS2 have been removed from SOLE and cannot be accessed through the GARFO_NEFSC schema. They can be requested from cold storage.  


# Changes to Collections Methods

# Tips and Tricks

# General Caveats
+ You can't simply "stack" data from these three datasets because there are some duplicate entries.  I think this happened because GARFO transitioned from one to the next and continued to record in both. 
    + Use DAS for multispecies fishing years 2004 and 2005
    + Use DAS2 for FYs 2006-2008 inclusive.  Scallop and multispecies allocations are stored here. 
    + use AMS for 2009 and after.  Scallop and multispecies allocations are stored here. There may be other stuff too.
    + I think these guidelines are okay for other species, but I'm not positive.    
+ In general, there are (BASE) Allocations, base allocation adjustments, carryover, Leases (in and out), transfers, and sanctions.

AMS stores transfers in a funky way:
The allocation_transfer table has a different structure than the ams.allocation_tx table. The column is called allocation number,and the value may be an MRI. That is because GC scallop has MRI's but tilefish does not, It uses allocation numbers. They serve the same purpose, which is to uniquely identify an access privilege, whether it is an MRI or allocation number. The from/to tells what allocation number the pounds came from or to. If the amount is positive, the from/to column contains the allocation number that bought the pounds. If the amount is negative the from/to column contains the allocation number that sold them. In AMS, there are two rows, one for the seller and one for the buyer. . They each have columns called "root_mri" and "charge_mri" - which is misleading because the tilfish entries are not MRI's [Steve Cohen @ GARFO. April, 2016]

+ I've embedded some code to extract initial allocations, usage, leases, and transfers. I think it works for multispecies, but you might want to double check before just running it.

+ Initial Allocations    
To extract initial allocations from DAS:

```
select * from das.das_allocation 
  where fishery='MUL' and das_category='A' 
    and fishing_year between 2004 and 2005;
rename fishery fmp;
rename das_category das_type;
rename right_to_days_id mri;
keep if transfer_id==.;
keep mri das_net_allocation fishing_year;
rename das_net categoryA_DAS;
```

To extract initial allocations of A-Days from DAS2:

```
SQL: "select * from das2.allocation where plan='MUL' and category_name='A';"  
STATA:
rename plan fmp;
rename category_name das_type;
destring, replace;
keep if fishing_year>=2006 & fishing_year<=2008;
collapse (sum) quantity, by(right_id credit_type fishing_year);
 drop if inlist(credit_type,"LEASE IN", "LEASE OUT");
rename right_id mri;
 rename quantity categoryA_DAS;
```

To extract initial allocations from AMS:

```
SQL: select *  from NEFSC_GARFO.AMS_allocation_tx where FMP='MULT' and das_type='A-DAYS';  
STATA:
destring, replace;
keep if fishing_year>=2009;
collapse (sum) quantity, by(fishing_year allocation_type root_mri);
rename allocation_type credit_type;
rename root_mri right_id;
 drop if inlist(credit_type,"LEASE IN", "LEASE OUT");
 rename quantity categoryA_DAS;
```
Then, stack them all together.

+ Transfers and leases.  

To get leases from DAS

```
SQL: select * from das.das_transfer_lease where fishery='MUL' and das_category='A' 
  and TRANSACTION_TYPE='L' order by nmfs_approval_date desc;")

Stata:
keep if inlist(fishing_year, 2004, 2005);
rename grantor_right_to_days_id right_id_seller;
rename grantee_right_to_days_id right_id_buyer;

rename grantor_permit_number permit_seller;
rename grantee_permit_number permit_buyer;
drop user_changed date_changed user_entered transaction_type; 
replace nmfs_approval_date=dofc(nmfs_approval_date);
replace date_entered=dofc(date_entered);

format nmfs_approval_date date_entered %td;
rename das_leased quantity;
rename das_price dollar_value;
rename nmfs_approval date_of_trade;
drop fishery date_entered das_category;
```

To get leases from DAS2

```    
SQL:
select * from das2.allocation_use where category_name='A' and plan='MUL'
    and allocation_use_type='LEASE' and approval_status='APPROVED' ;

Stata:
keep if fishing_year>=2006 & fishing_year<=2008;

gen date_of_trade=dofc(au_date_time);
format date_of_trade %td;
collapse (sum) quantity (first) dollar_value, by(permit_d permit_c right_id 
    right_id_c date_of_trade fishing_year);
rename permit_d permit_seller;
rename permit_c permit_buyer;
rename right_id_c right_id_buyer;
rename right_id right_id_seller;
order date fishing_year;
sort fishing_year date permit_s;
* there were a few data correction issues, mostly wrong/bad matches.
replace right_id_buyer=1807 if right_id_buyer==. & permit_buyer==121546;
replace right_id_buyer=559 if right_id_buyer==. & permit_buyer==310912;
replace right_id_buyer=455 if right_id_buyer==. & permit_buyer==251364;
replace right_id_buyer=2055 if right_id_buyer==. & permit_buyer==149334;
```

To get AMS lease data.  I'm not 100% sure this is correct.

```
SQL "select lease_exch_id,from_permit, to_permit, from_right, to_right, fishing_year, quantity, price, 
approval_date  from NEFSC_GARFO.AMS_LEASE_EXCH_APPLIC
	    where FMP='MULT' and from_das_type='A-DAYS' 
	    and approval_status='APPROVED' and fishing_year>=2009;" 
Stata:
destring, replace;
rename to_permit permit_buyer;
rename from_permit permit_seller;
rename to_right right_id_buyer;
rename from_right right_id_seller;
compress;
rename approval_date date_of_trade;
rename price dollar_value;
replace date_of_trade=dofc(date_of_trade);
format date_of_trade %td;
gen schema="AMS" ;
```
You should be able to stack all three of these together.
    
  
  
+ USAGE
  DAS and DAS2 keep track of usage differently.  
  To extract usage from DAS:
  
```
Part 1
SQL Code:
select du.fishing_year, du.das_transaction_id, du.permit_number, du.das_charged_days, tr.sailing_port,
tr.sailing_state, tr.sail_date_time as date_sail, tr.landing_port, tr.landing_state, 
tr.landing_date_time as date_land,tr.gillnet_vessel, tr.day_trip, 
tr.observer_onboard, tr.das_charged_fixed, tr.fishery_code, 
tr.vessel_name	from das.das_used du, das.trips tr
  where du.das_transaction_id=tr.das_transaction_id 
  and du.permit_number=tr.permit_number 
  and du.das_category='A' and du.fishery='MUL';") ;  
	
Stata code: 
keep if inlist(fishing_year, 2004, 2005);
rename permit permit;
rename das_charged_days charge;
rename fishery_code activity_code;

collapse (sum) charge (first) gillnet_vessel day_trip observer_onboard das_charged_fixed vessel_name ,
    by(fishing_year permit sailing_port sailing_state date_sail
    landing_port landing_state date_land activity_code );
gen schema="DAS";
```


  To extract usage from DAS2:
```
Part 2a
SQL: " select du.das_trip_id, du.allocation_use_type, du.au_date_time_debited, du.permit_debited, 
du.permit_credited, du.quantity, du.category_name, du.plan, du.right_id,du.credit_type, 
du.fishing_year, du.dollar_value, activity_code, dt.permit_num, dt.sailing_port, 
dt.sailing_state, dt.trip_start, dt.trip_end, dt.landing_port, dt.landing_state
  from das2.allocation_use du, das2.das_trip dt
     where du.category_name='A' and du.plan='MUL' 
     and du.allocation_use_type='TRIP' 
     and du.quantity<>0 and du.das_trip_id=dt.das_trip_id;"
 
Stata: 
keep if fishing_year>=2006 & fishing_year<=2008;
tempfile t1 reg_use2006;  
rename permit_debited permit_seller;
rename right_id right_id_seller;
rename permit_credited permit_buyer;
keep if allocation_use_type=="TRIP";
notes: This has ONLY TRIPS. This has no PTU in it.;
```

If DAS were leased and then subsequently used, these trips were stored in a different place. God knows why.  
```
Part 2b
SQL: "select du.das_trip_id, du.allocation_use_type, du.au_date_time_debited, du.pt_permit_debited,
du.permit_debited, du.quantity, du.category_name, du.plan, du.right_id, du.credit_type,
du.fishing_year, activity_code, dt.permit_num, dt.sailing_port, dt.sailing_state, 
dt.trip_start, dt.trip_end, dt.landing_port, dt.landing_state
 from das2.private_transaction_use du, das2.das_trip dt
 where du.category_name='A' and du.plan='MUL'  and du.quantity<>0
 and du.das_trip_id=dt.das_trip_id;"
 
 keep if fishing_year>=2006 & fishing_year<=2008;

```
Stack the results of parts 2a and 2 and then

```
rename permit_num permit;
rename quantity charge;
rename trip_start date_sail;
rename trip_end date_land;
drop plan category;
collapse (sum) charge, by (au_date_time_debited permit_debited permit right_id fishing_year
activity_code sailing_port sailing_state date_sail date_land landing_port landing_state);
gen schema="DAS2";
```

To get Days at sea from AMS:
```
SQL:
"select * from NEFSC_GARFO.AMS_TRIP_AND_CHARGE where fmp='MULT' and DAS_TYPE='A-DAYS'
  and charge<>0 and fishing_year>=2009;"

Stata:
drop running_clock observer rsa mult_override fmp trip_de-charge_uc trip_source
fishing_area das_type das_id trip_id tc_id charge_type; 

rename permit_nbr permit;
destring, replace;
compress;
 collapse (sum) charge, by(permit date_s date_l fishing activity_code);
 gen schema="AMS";
```
Charge is denominated in days. There was one entry in AMS that was negative. I don't think it's a data error. 

This is not quite working properly - there seem to be some entries in AMS.TRIP_AND_CHARGE  that indicate that multispecies A-days are charged to vessels that don't have any A-DAYS, a right_id for Multispecies, or even a Limited Access multispecies permit. It seems like this is from MNK.  These should be excluded, probably by matching to valid per_nums in mqrs.mort_elig_criteria.




You should be able to stack the results of all of these to form a giant table of DAS usage from 2004-present.  Permit, charge, fishing_year, date_sail, date_land, fishing_year and activity_code are in all. Sailing port, state, landings port state, gillnet, and observer were only databased in AMS.  DAS2 contains right_ids, but DAS and AMS do not. 

# Sample Projects

# Sample Code


# Update Frequency and Completeness
+ Not sure about AMS.
+ DAS and DAS2 are "legacy" GARFO tables. GARFO doesn't really care about maintaining them.

# Other Metadata sources
+ INPORT.  https://inport.nmfs.noaa.gov/inport/item/11773
+ NEFSC's Data Dictionary  http://nova.nefsc.noaa.gov/datadict/

# Related Tables

# Support Tables

