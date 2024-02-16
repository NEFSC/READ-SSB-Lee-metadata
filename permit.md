# Overview


The following views can be found in the NEFSC_GARFO schema on nefscdb1

* NEFSC_GARFO.PERMIT_VPS_VESSEL - Holds vessel characteristic information (horsepower, length, gross tonnage) associated with a particular vessel permit 
* NEFSC_GARFO.PERMIT_VPS_FISHERY_NER - Detailed information on a vessel's associated permit types.  
Plan is the fishery management plan (FMP).  Cat is the category within that Plan.
* NEFSC_GARFO.PERMIT_DEALER - Contains information on federal dealer permit application information
* NEFSC_GARFO.PERMIT_VPS_OWNER -  Contains ownership information, including a business ID.

* NEFSC_GARFO.CLIENT_BUS_OWN -Contains business ownership information that describes the people that own a fishing firm.  Allows for grouping of permits into firms based on identical owners. See the CLIENT.md help file.
* NEFSC_GARFO.PERMIT_OWNER_HISTORY_PIDS -Contains *historical* business ownership information for firms with a groundfish or scallop permit prior to 2010.

The permit data contain information about fishing vessels, the fisheries they can participate in. These data are generated through permit applications that are submitted to GARFO by vessel owners.  A vessel owner will often submit more than one permit application per year. This can happen if a vessel owner renews some permits early in the year and others later in the year or if a vessel changes ownership. There are probably other reasons as well.

# Current Collection Methods

The [ownership forms](./external/vesownershipform.pdf) that are filled out by vessel operators can be useful to understand these data.

# Changes to Collections Methods

# Tips and Tricks

# General Caveats
* There is an AP_NUM. This is different from the APP_NUM in the MQRS system.

* The same permit number does not necessarily link to the same vessel through all years, as vessels may be upgraded or replaces. 

* The same permit number does not necessarily link to the same owner over time, as vessels (with accompanying permits) can be sold.

* The are 5 date fields in VPS_FISHERY_NER  

* There have been "clean ups" -- sometimes an entry gets put into PERMIT_VPS_VESSEL where the DATE_ISSUED is equal to the DATE_CANCELED. This may cause mis-merges.  You also may want to exclude these completely from your query.
```
select * from NEFSC_GARFO.PERMIT_VPS_VESSEL where (date_issued<>date_canceled or date_canceled is null);
```

* Similarly, you may  want to exclude rows where start_date >=end_date or start_date>=date_expired 
 
*  CLIENT_BUS_OWN and PERMIT_VPS_OWNER are used to aggregate multi-vessel firms together for Regulatory Flexibility Act Analysis. 

*  If a vessel is owned by one or more people or businesses in a partnership, then we use rank 2, 3, etc. for the additional owners in PERMIT_vps_owner.  The rank field does not represent any percentage ownership, hierarchy in the company, or majority ownership, it is simply used for mailing purposes.  The rank = 1 owner name shows up on the permit and we use that name for our mailings. (Ted Hawes - Sept 23, 2020)

* In the PERMIT_vps_owner table, we only populate the business_id for the rank = 1 records. Add a condition that rank = 1 to ensure that there are no missing business ids.   If you do, that would be an error. (Ted Hawes - Sept 23, 2020)

* The owners/shareholders of Company A  are entered in the Client system and given a person_id.  Each person in the system has a unique id that can be reused for any of the businesses that they may be a part of.  For new companies or changes in corporate owners, we then assign each person to the company.  Each year with our renewal applications, we collect the owner information and compare it to what we have in the system.  If there are no changes in owners, we don't alter any of the business information.  If a person is added to a company, we generate a person_id for them, if they don't already have one, and assign them to the business.  If a person leaves a company or dies, we don't delete them from the business.  We place an end_date on their relation with the company so that we can have a history of the owners.    (Ted Hawes - Sept 23, 2020)

# Sample Code

# Sample Projects

# Update Frequency and Completeness


# Other Metadata sources
+ INPORT.  https://inport.nmfs.noaa.gov/inport/item/12985
+ NEFSC's Data Dictionary  http://nova.nefsc.noaa.gov/datadict/


# Related Tables
+ CLIENT.BUS_OWN contains ownership data that is often linked to these PERMIT data. We'll put them in a separate section.
+ MQRS tracks the ability of a *thing* to participate in a moratorium fishery. We'll put them in a separate section.  Allocations are tracked in other places (DAS, DAS2, and AMS).
+ CPH
+ OPERATORS (captains) are permitted independently 




## Support Tables
  + VALID_FISHERY translates the PLAN and CAT into words.

