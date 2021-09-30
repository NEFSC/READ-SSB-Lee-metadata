
# Overview
The Data Matching and Imputation System is maintained by GARFO. Just email Michael Lanning at GARFO, he's got all the answers. j.michael.lanning@noaa.gov 

Tables: 
APSD.t_ssb_trip@garfo_nefsc
APSD.t_ssb_catch@garfo_nefsc 
APSD.t_ssb_discard@garfo_nefsc

APSD.t_ssb_trip_current@garfo_nefsc
APSD.t_ssb_catch_current@garfo_nefsc 
APSD.t_ssb_discard_current@garfo_nefsc


Location: GARFO super secret server

Schema: 

# GARFO provided metadata

Here are a few documents that describe DMIS.

1.  [DMIS Data Dictionary](/external/DMIS%20Data%20Dictionary%20(SSB).docx). Circulated by Tammy Murphy on April 27, 2020.
1.  [DMIS Data Dictionary part 2](/external/DMIS_Table_Dictionaries_July_2012.docx).  Circulated by Tammy Murphy on May 1, 2020. I'm not sure how this differs from the previous.
1.  [DMIS Documentation](/external/DMIS%20Documentation.pdf).   This appears to be from J. Michael Lanning and last modified on September 26, 2019.
1.  [DMIS and AA comparison](/external/NRCC-Report-Catch-Differences-180511-Lanning.pdf).   J. Michael Lanning's Presentation that describes AA and DMIS, given to [NRCC on May 15,2018](https://www.nefmc.org/calendar/may-15-16-2018-nrcc-meeting).
  



# Linking to Veslog

Linking to VESLOG with DMIS DOCID has a few issues. (Chad Demarest, May 14, 2020)
1.  JML adds digits to DMIS DOCID to denote subtrips.
1.  Another is that some data handling protocols (varies by file type) truncate a digit off the end of the EVTR serial numbers.
1.  A third is that DMIS will Give positive (mostly correct) match’s where the DOCID fails for these and other reasons.



# On Home Consumption Fish

> The code for this stuff is BHC_ (either _LIVE_POUNDS or _LANDED_POUNDS).  "BHC" stands for "Bait and Home Consumption".  A few years ago they added LUMF (Legal UnMarketable Fish) to this category as well.  LUMF, at lease for here, and at least as I understand it, is derived from observer trips only.  But I'm not 100% sure on that. If you use DLR_LIVE or DLR_LANDED (or DLR_DOLLAR) you won't get the BHC fish.  If you use LANDED or POUNDS or DOLLAR_SSB/GDP you'll get 'em, plus imputed values for the DOLLAR field. Starting on the next run of DMIS, fish that are authorized to be landed on EFP trips but are not sold thu a dealer will be added to the BHC_ fish.   Chad's email April 11, 2018.

# Versions

> There is a "_current" versioning of tables. As of April 2020, current contains a little bit more data. I now use _trip for everything, whereas a yearly ago I used _current.  There were some discrepancies for earlier years (2013?) that _trip had correct and _trip_current did not.  Otherwise I believe they are the same. (Chad)

> I have been using current since there is more recent data included. Hopefully for older data the two match up, but I haven't looked into that in a while. (Greg)
 

# Prices

Here is the algorithm for doing prices in DMIS circulated on March 7, 2021.

```
======  what you sent ====== 
The imputation is in the following order: 
Day / (NESPP3 , MARKET GRADE) / Port                      :     Code:   D4P 
Day / (NESPP3 , MARKET GRADE) / County                 :     Code:   D4C 
Day / (NESPP3 , MARKET GRADE) / State                    :     Code:   D4S 
Day / (NESPP3 , MARKET GRADE) / Region                 :     Code:   D4P 
Day / (NESPP3 , MARKET GRADE) / North East           :     Code:   D4 
Week/ (NESPP3 , MARKET GRADE) / North East         :     Code:   W4 
Month / (NESPP3 , MARKET GRADE) / North East        :     Code:   M4 

Then 

Day / (NESPP3 ) / Por                      :     Code:   D3P 
Day / (NESPP3) / County                 :     Code:   D3C 
Day / (NESPP3) / State                    :     Code:   D3S 
Day / (NESPP3) / Region                 :     Code:   D3P 
Day / (NESPP3) / North East           :     Code:   D3 
Week/ (NESPP3) / North East         :     Code:   W3 
Month / (NESPP3) / North East        :     Code:   M3 
================== 

MODIFICATION: 

The imputation is in the following order: 

Day / (NESPP3 , MARKET GRADE) / Port                      :     Code:   D4P 
Day / (NESPP3 , MARKET GRADE) / County                 :     Code:   D4C 
Day / (NESPP3 , MARKET GRADE) / State                    :     Code:   D4S 
Day / (NESPP3 , MARKET GRADE) / Region                 :     Code:   D4P  (D4R??) 
Day / (NESPP3 , MARKET GRADE) / North East           :     Code:   D4 

Then FOR NON-MONKFISH: 

Day / (NESPP3 ) / Port                      :     Code:   D3P 
Day / (NESPP3) / County                 :     Code:   D3C 
Day / (NESPP3) / State                    :     Code:   D3S 
Day / (NESPP3) / Region                 :     Code:   D3P (D3R??) 
Day / (NESPP3) / North East           :     Code:   D3 

Week/ (NESPP3) / North East         :     Code:   W3 
Month / (NESPP3) / North East        :     Code:   M3 

THEN FOR MONKFISH ONLY: 

Week / (NESPP3 , MARKET GRADE) / Port
Week / (NESPP3 , MARKET GRADE) / County
Week / (NESPP3 , MARKET GRADE) / State
Week / (NESPP3 , MARKET GRADE) / Region
Week/ (NESPP3 , MARKET GRADE) / North East      


Month / (NESPP3 , MARKET GRADE) / Port
Month / (NESPP3 , MARKET GRADE) / County
Month / (NESPP3 , MARKET GRADE) / State
Month / (NESPP3 , MARKET GRADE) / Region
Month / (NESPP3 , MARKET GRADE) / North East
       
Week/ (NESPP3) / North East
Month / (NESPP3) / North East     

```
# Price Variables

There are two different price variables within DMIS.

DLR_DOLLAR: The value of landed catch to the nearest dollar, paid to fishermen by the dealer, for a given species. All value from for this variable comes directly from dealer reports.

DOLLAR_SSB: In addition to the values represented in the DLR_DOLLAR variable, DOLLAR_SSB imputs values according to the above code. Imputation is performed in the cases of bait and home consumption (BHC) or if there is a VTR record, but no matching dealer report.
*Greg has some correspondence from Dan Caless that he can forward to anyone interested.

# Completeness of Fishery Revenue data
For many fisheries in the Greater Atlantic Region, DMIS (APSD.t_ssb_catch_current@garfo_nefsc) includes the vast majority of ex-vessel revenues as compared to CFDBS. However, in fisheries which have large state waters components, or unqiue reporting requirements, DMIS may fail to capture a significant portion of revenues. A comparison of fishery ex-vessel revenues in 2018 for the two data sources is provided below. Note lobster and SC/OQ. 

| Schema   | Black Sea Bass| 	Bluefish| 	 Groundfish| 	Herring| 	    Jonah Crab| 	  Lobster| 	    Mackerel| 	  Monkfish| 	    Red Crab|
|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|            
|DMIS Query 	 | $9,488,729| 	    $956,188| 	 $47,767,489| 	$23,096,764| 	$18,313,781| 	$459,191,551 |	$4,276,065| 	$14,782,472 |	$3,594,397|
|Dealer Query| $12,060,017| 	    $2,073,282| $48,352,305| 	$23,150,685| 	$18,574,993| 	$631,134,282| 	$4,348,775| 	$14,937,020| 	$3,594,397|

| Schema   |       Scup 	  |   Sea Scallop| 	  Skate| 	    Spiny Dogfish| 	Squid| 	      Summer Flounder| 	Surf Clam / Ocean Quahog| 	Tilefish| 	  Whiting|
|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|            
|DMIS Query| 	 $8,537,625|  $524,952,412| 	$7,042,994| 	$2,627,879| 	    $61,797,190| 	$22,780,233| 	    $3,023,109| 	              $5,098,011| 	$9,967,509|
|Dealer Query| $9,708,960|  $532,086,840| 	$7,437,288| 	$2,832,603| 	    $62,300,665| 	$25,395,970| 	    $61,321,459| 	            $5,152,426| 	$10,040,221|

# Matching to Observer data
1.  [Code](/code_fragments/DMIS_observer_match.sas) to match observer data to DMIS 

