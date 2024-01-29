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


Here is code to get landings for cod and haddock from particular stat areas from VTR.
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


And here is the code to get similar data from CAMS.

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

# Update Frequency and Completeness 

# Other Metadata sources

+ Preceded by: DMIS, CFDERS _AA
+ Succeeded by: n/a

# Related Tables 

# Support Tables 

