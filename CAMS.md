# Overview
CAMS is slated to replace both the CFDBS_AA tables and the DMIS tables.

Location: NEFSC_USERS

Schema: CAMS_GARFO

Metadata can be found here:

https://www.greateratlantic.fisheries.noaa.gov/ro/fso/reports/cams/index.html

and here

http://nerswind/cams/cams_documentation/index.html


# Current Collection Methods

# Changes to Collections Methods

# Tips and Tricks.

# General Caveats.

# Sample Code

Some sample code can be found here: 

https://www.greateratlantic.fisheries.noaa.gov/ro/fso/reports/cams/articles/common_query_examples.html


+ select * from CAMS_GARFO.CAMS_LANDINGS; 


## landings for cod and haddock from particular stat areas

### From CAMS.

```
	odbc load,  exec("select sum(nvl(lndlb,0)) as landings,  sum(livlb) as livelnd, year, month, itis_tsn from cams_garfo.cams_land cl where 
		cl.area between 511 and 515 and 
		cl.year between $commercial_grab_start and $commercial_grab_end and
		itis_tsn in ('164712','164744')
		group by year, month, itis_tsn;") $myNEFSC_USERS_conn ;	
```

And discards
```
odbc load,  exec("select year, extract(month from date_trip) as month, itis_tsn, sum(nvl(cams_discard,0)) as discard from cams_garfo.cams_discard_all_years cl where 
		cl.area between 511 and 515 and 
		year between $commercial_grab_start and $commercial_grab_end and
		itis_tsn in (164712,164744)
		group by year, extract(month from date_trip), itis_tsn;") $myNEFSC_USERS_conn ;		
		
```


### From VTR
```
forvalues yr=$commercial_grab_start(1)$commercial_grab_end {;
/* and here is the odbc load command */
	clear;
	tempfile new;
	local files `"`files'"`new'" "';
	odbc load,  exec("select g.carea, s.gearid, s.tripid, s.sppcode, s.qtykept, s.datesold from vtr.veslog`yr's s, vtr.veslog`yr'g g where g.gearid=s.gearid and s.sppcode in ('COD', 'HADD') and g.carea between 511 and 515;
") $oracle_cxn ;
	gen year=`yr';
	quietly save `new';
};
```


## All permits that landed Summer Flounder in 2014

```
SELECT distinct PERMIT
  from cams_garfo.cams_land where 
  ITIS_TSN=172735 and YEAR in ('2014')
```

## Summer Flounder example

### All permits that landed summer flounder in 2014
```
SELECT distinct PERMIT
  from cams_garfo.cams_land where 
  ITIS_TSN=172735 and YEAR in ('2014')
```

### Subtrip level info for permits that landed summer flounder in 2014

```
select * FROM cams_garfo.cams_subtrip s 
    where s.YEAR in ('2014') and s.PERMIT in (SELECT distinct PERMIT
    from cams_garfo.cams_land where 
    ITIS_TSN=172735 and YEAR in ('2014'));
```



### Catch level info for those trips

This query adds landings level information for those subtrips, retains just some subtrip-level columns, and does some ordering.

```
SELECT t.CAMSID, t.DOCID, t.VTRSERNO, t.PERMIT, t.ITIS_TSN, t.DLRID, t.DLR_DATE, t.STATE, t.PORT, t.DLR_MKT, t.DLR_GRADE, t.LNDLB, t.VALUE, t.NEGEAR, t.WEEK, s.VTR_CREW, s.RECORD_SAIL, s.RECORD_LAND, s.VTR_TRIPCATG, s.subtrip, s.YEAR 
  FROM cams_garfo.cams_land t
LEFT OUTER JOIN 
    (select CAMSID, VTR_CREW, RECORD_SAIL, RECORD_LAND,
    VTR_TRIPCATG, SUBTRIP, YEAR, permit FROM cams_garfo.cams_subtrip) s 
    on t.SUBTRIP=s.SUBTRIP AND
    t.CAMSID=s.CAMSID
    where t.YEAR in ('2014') and 
      t.PERMIT in (SELECT distinct PERMIT
           from cams_garfo.cams_land 
              where ITIS_TSN=172735 and YEAR in ('2014'))
    order by t.permit, t.camsid, itis_tsn, dlr_mkt, dlr_grade;
```

You may want to filter out the PERMIT=000000, add discards, or add VTR orphans depending the your project.



# Update Frequency and Completeness 

# Other Metadata sources

+ Preceded by: DMIS, CFDERS _AA
+ Succeeded by: n/a

# Related Tables 

# Support Tables 

