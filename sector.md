# Overview
The SECTOR tables are related to MQRS.  They map MRIs to sectors and do other things.  

Tables: SECTOR and derivatives 

Location: NEFSCDB1

Schema: NEFSC_GARFO

NEFSC_GARFO.sector_mri_permit_vessel_history contains sector rosters
  
NEFSC_GARFO.SECTOR_PSC_MRI_AS_PERCENT - MRI level allocations, in percentage terms.    

NEFSC_GARFO.SECTOR_ACE_MRI_AS_POUNDS - MRI level allocations, in pounds.    

# Current Collection Methods

# Changes to Collections Methods

# Tips and Tricks

# General Caveats
* There is an AP_NUM. This is different from the APP_NUM in the MQRS system.

* The same permit number does not necessarily link to the same vessel through all years, as vessels may be upgraded or replaces. 

* The same permit number does not necessarily link to the same owner over time, as vessels (with accompanying permits) can be sold.

# Sample Code

# Sample Projects

# Update Frequency and Completeness


# Other Metadata sources
+ INPORT.  https://inport.nmfs.noaa.gov/inport/item/12989
+ NEFSC's Data Dictionary  http://nova.nefsc.noaa.gov/datadict/


# Related Tables
+ BUS_OWN contains ownership data that is often linked to these PERMIT data. We'll put them in a separate section.
+ MQRS tracks the ability of a *thing* to participate in a moratorium fishery. We'll put them in a separate section.  Allocations are tracked in other places (DAS, DAS2, and AMS).
+ CPH
+ OPERATORS (captains) are permitted independently 
## Support Tables

