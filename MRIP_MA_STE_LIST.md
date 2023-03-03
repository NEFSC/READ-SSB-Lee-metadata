# Overview
Tables: 

* MRIP_MA_SITE_LIST

Location: Sole

Schema: MLEE.  This is in Min-Yang Lee's personal table space, you will have to email him for access. 

Recreational fishing trips that occur in Massachusetts sometimes must be assigned to the Gulf of Maine or Georges Bank.  Sites are classified as North or South.

North: 

1. Sites that are North of Cape Cod.
2. Sites on Cape Cod that face North into the Gulf of Maine.

South:

1. Sites that are South or West of Cape Cod.
2. Sites on Cape Cod that face South, West, or East into the Vineyard Sound, Buzzards Bay, or Georges Bank.

# Current Collection Methods
These sites were compiled by Scott Steinback.

# Changes to Collections Methods

# Tips and Tricks

# General Caveats

# Sample Code
Here is some sample SQL to get the data.  Use SQLDeveloper to connect to SOLE:  
```
select * from MLEE.MRIP_MA_SITE_LIST;
```



Starting with MRIP data trip data, I 
```
merge m:1 site_id using "${data_raw}/ma_site_allocation.dta", keepusing(stock_region_calc) keep(1 3)
rename  site_id intsite
drop _merge

/*classify into GOM or GBS */
gen str3 area_s="AAA"

replace area_s="GOM" if st==23 | st==33
replace area_s="GOM" if st==25 & strmatch(stock_region_calc,"NORTH")
replace area_s="GBS" if st==25 & strmatch(stock_region_calc,"SOUTH")

```
To classify trips into either the Gulf of Maine or Georges Bank.

# Sample Projects
* Min-Yang uses this to classify trips that target cod/haddock into GOM or GB.

# Update Frequency and Completeness

Infrequent

# Other Metadata sources


# Related Tables




## Support Tables

