## Overview

Tables: CFDETSyyyy; CFDERSyyyy 

Location: Sole

Schema: CFDBS

The dealer data are transaction-level reports at the level of the “market-category.”  These data are primarily generated through mandatory reporting by federally-permitted fish dealers.  The federal reporting is supplemented with data from non-federally-permitted (state-only) fish dealers.  Data are currently reported electronically in partnership with ACCSP through SAFIS.

+ CFDETSyyyy contains “detailed species data” for 1994-2003
+ CFDERSyyyy contains “detailed species data” for 2004-present
+ CFLENyyyy -fish-level port sampling data for length


Additionally, APSD has a table of CFDERS for all years, so no need to loop through iterative lists in R or or use UNION in SQL.  This can be accessed with

select * from fso_admin.cfders_all_years@garfo_nefsc;

        
# Current Collection Methods
These data are the result of mandatory federal dealer reporting at the “trip-level”, supplemented by state-level, aggregated reporting.  Federally permitted fish dealers that are required to report purchases of all fish to NMFS.

# Changes to Collections Methods
+ The number of species triggering these requirements have increased over time, which has implications for completeness (50 CFR 648.6). For example, mandatory dealer reporting for Monkfish, herring, and hagfish began in 1999, 2001, and 2007 respectively.

+ Mandatory electronic reporting began in 2004. This improved quality of data, in particular, the collection of VTRSERNO,which improves matching to VTR data.        

+ The NEPORT=331627 was incorrectly mapping to BARNEGAT LIGHT/LONG BEACH. 331527 has been added as BARNEGAT LIGHT and 331627 now maps to LONG BEACH (ie, the entire Township). Legacy/Historical data with NEPORT=331627 will be updated to 331527 under the assumption that fishers were reporting based on Port Name.  This changes is effective approximately Jan, 2022 [Chris Tholke, Jan 13, 2022].

# Tips and Tricks

+ A dealer-veslog link can be made reasonbly well starting in 2005.  To make this link, match the the CFDBS.VTRSERNO to VESLOG.SERIAL_NUM.  Chances are that you care about Trip-level outcomes: be careful, because a vessel may have more than one SERIAL_NUM per TRIPID in the VESLOG tables.

+  APSD has a table of CFDERS for all years, so no need to loop through iterative lists in R or or use UNION in SQL.

```
select * from fso_admin.cfders_all_years@garfo_nefsc;
```

+ Here is a slick way to check confidentiality using dealer data:

```
 select year, port,
CASE WHEN LEAST(COUNT(distinct COALESCE(NULLIF(permit,'000000'),NULLIF(cf_license,'0'))),COUNT(distinct COALESCE(TO_CHAR(dealnum),state_dnum))) >=3  THEN 'N' ELSE 'Y' END confidential
from fso_admin.cfders_all_years@garfo_nefsc
where NESPP3 in (081, 082, 120, 122, 123, 124, 125, 147, 152, 153, 155, 240, 269, 512, 159, 250)
and year > 2018
group by year, port;
```

# General Caveats
* Dealers are only required to record one VTR serial per trip.  

* Outlier prices are always possible.  Filter these out carefully.

* The following species are sketchy:

    + Surfclam and Ocean Quahog dealer reports are contained in the SFCLAM schema (separate from CFDBS).  It is unclear whether reports of SC and OQ in CFDETS and CFDERS are duplicates or not, particularly for landings of Maine Mahogany Clam [Walden].

    + Giant Bluefin Tuna dealer are supposed to be reported individually and should be in a different schema.  Giant Bluefin Tuna in CFDERS are either misreporting or duplication [George Silva, NMFS HMS].

    + Herring stock assessments do not necessarily use Dealer data as the source for assessments [Jon Deroba, PDB].  This is because Maine DMR has collected herring data and comprises the population of catch. The dealer data does not match the ME DMR data for herring quantity landed.

* There are many species that have two NESPP3 codes (As of March,2018). 
    + Cod (080, 081) 
    + Monkfish (011, 012)
    + Winter flounder (119, 120)
    + Yellowtail flounder (122, 123)
    + Haddock (147, 148)
    + White hake (153, 154).  155 is Red/White mixed
    + Pollock (269, 270)
    
This bit of code may help:```select * from cfspp order by doc desc;```

* Some species were/are grouped together, but subsequently split apart. 

    +  Tilefish, which starts as NK, but becomes Blueline and Golden. 
    +  Skates
    
This bit of code may help:```select * from cfspp order by doc desc;```

* Data derived from “state” reporting may not include all fields that are populated by “federally reported” dealer reports.  This may affect the PORT, COUNTY, PORT2, PERMIT, HULLNUM, VTRSERNO, MONTH, and DAY fields.
    +  Permit numbers that do not correspond to a single vessel are:
        1.  000000, which means either "no vessel" (ex. from shore or aquaculture),or  "unknown" federal permit, which could be "no federal permit".
        2.  190998,390998 correspond to different size classes of vessels

*  Many NESPP4 codes will not match well to VTR’s SPPCODE. For example, VTR cod is all 0818 (unclassifed round). Almost all Cod will eventually be classified when sold; there is very little 0818 in dealer data.

* Ports are inconsistently encoded over time. 
    + Some “port groups” were split into mutiple ports.  (Hampton, Seabrook, and Hampton/Seabrook, NH is a good example).
    + Many records are entered only at the “state” or “county” level.  This is particularly frequent for “older” records and non-federal reports that are received through SAFIS.
    + The names corresponding to the port codes may or may not match to Census “units.”  The 2 digit state code does not correspond to FIPS codes.  
    + There is a table POPLACE_BASE that contains some Census Places. I'm not sure who made this, or if it's currently maintained.
    + month=0 or day=0 mean 'unknown' month or day.  I believe that both are due  to state-level reporting requirements that allow for monthly or yearly level reporting, instead of 'trip level' reporting.
* Live and Landed weights are recorded.  
    + Scallop in-shell prices can be quite variable.
    + miscellaneous "parts" like monk liver, cod cheeks, or skate racks will have zero or null SPPLIVLB.

* The AA tables are created at the end of a calendar year and released mid-May of the following year
    + Used for Catch Accounting
    + More-or-less static
    + A guideline: use the AA tables if you need consistency with stock assessment or other products that also use them.

# Sample Code

* The length distribution of landed fish might be useful. This code extracts the length distribution for cod in 2010:
```
select year, state, nespp4, length, sum(numlen) as num_len from cflen2010
where nespp3=081
group by nespp4, year, state, length;
```

If you need to extract many years of CFBDB data, do it in a loop. 
*  Here is a bit of sample code in [R](https://github.com/NEFSC/READ-SSB-Lee-project-template/blob/main/R_code/data_extraction_processing/extraction/r_oracle_connection.R) and in [stata](https://github.com/NEFSC/READ-SSB-Lee-project-template/blob/main/stata_code/data_extraction_processing/extraction/extract_from_sole.do) for veslog, just modify it to query from CFDBS.



# Sample Projects
+ Construct prices for fish [Lee, Demarest, Ardini].
+ Construct trip revenues, post 2005 [Demarest]
+ Commercial Landings and Revenues for the “Community Profiles.” [Olson, Colburn]
+ “The record” of commercial landings for use in stock assessment.  Sort of. An "Area Allocation" usually need to be performed, because some species have multiple, spatially distinct stocks.[PopDy]
+ Construct entity-level gross revenues from commercial fishing for Regulatory Flexibility Act Analyses [Lee].  

## Update Frequency and Completeness
+ Nightly updates. Expect approximately 300 changes or additions to the current and previous year of data per day.
+ Data is “complete” 6-9 months after the end of the calendar year; however, small changes are always occurring.
+ This has consequences for reproducibility if you do not store a copy of the data.


## Other Metadata sources
+ INPORT.  https://inport.nmfs.noaa.gov/inport/item/12205
+ NEFSC's Data Dictionary  http://nova.nefsc.noaa.gov/datadict/

+ Preceded by: “Weighout” (WODETSyy and WODETTyy)
+ Succeeded by: CAMS (tbd), for just the AA tables.

# Support Tables 
## Related Tables
+ CFDERSyyyyAA tables - “perform some Area Allocation”
+ CFDETSyyyyAA tables - “perform some Area Allocation”
+ CFDETTyyyy contains “detailed trip data”  for 1994-2003
+ CFSUMTyyyy, CFSUMSyyyy - “summary tables” for 1994-2003
+ CFAGEyyyy - fish-level port sampling data.

## Support Tables
+ PORT, VALID_PORTS
+ GEAR
+ SPECIES_ITIS_NE  decodes into names, links to the species_itis system
+ CFSPP - decodes NESPP3 and NESPP4 into names


# Cool Stuff

##  Dealer data is the only source for these kinds of information
|	Column	|	Description
|:---------------	|:--------------------------------------------------------
|	SPPLNDLB	|
|	SPPVALUE	|
|	UTILCD		| Quality unknown
|	DISPOSITION_CODE| Quality unknown 
|	REPORTED_QUANTITY|		
|	UOM		|
|	GRADE_CODE	|	
|	MARKET_CODE 	|
|	SPPLIVB	 | Certain NESPP4 codes (monkfish livers, cod milt) convert into zero “live pounds.”  This is done to prevent potential double counting during the stock assessment.

##  Dealer data should probably be considered the primary source for these kinds of information
|	Column	|	Description
|:---------------	|:--------------------------------------------------------
|	YEAR	|	This may not be the same as the year in which fish was caught.
|	MONTH	|	This may not be the same as the month in which fish was caught.  May be zero.
|	DAY	|	This may not be the same as the day in which fish was caught.  May be zero.
|	DEALNUM	|	Dealer Identification number
|	NESPP4 [3]	|	There are 4 species codes (NESPP3, NESPP4, WHSPP, SPECIES_ITIS). 
|	WHSPP	|	
|	SPECIES_ITIS	|	
|	STATE_DNUM	|	


##  Dealer data should probably be considered a secondary source for these kinds of information. These fields might be more accurate somewhere else.

|	Column	|	Description
|:---------------	|:--------------------------------------------------------
|	PORT	|	 Concatenation of state, port, county
|	COUNTY	|	Data dictionary claims this is a string, but it is a 2 digit code.
|	NEGEAR	|	
|	NEGEAR2	|	
|	NEMAREA	|	
|	AREA	|	
|	HARVEST_AREA	|	
|	DEPTHCD	|	
|	SUBTRIP	|	
|	TONCLASS [TONCL1,TONCL2]	|	
|	FZONE	|	
|	PERMIT	|	
|	HULLNUM	|	
|	VTRSERNO	|	
|	SPRATIO	|	
|	FIPS_STATE	|	
|	FIPS_PLACE	|	
|	FIPS_COUNTY	|	
|	CF_LICENSE	|	
|	NEGEAR_VTR	|	


## These are the QA/QC fields 

|	Column	|	Description
|:---------------	|:--------------------------------------------------------
|	LINK	|	
|	DOCN	|	
|	EFFIND	|	
|	SOURCE	|	
|	DERSOURCE	|	
|	PARTNER_ID	|	
|	DEALER_RPT_ID	|	
|	DOE	|	
|	LANDING_SEQ	|	

