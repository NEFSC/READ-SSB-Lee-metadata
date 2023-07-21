Cost survey data is currently being databased in Oracle (07.21.2023). As of today, data from 2001, 2012 and 2015 are found on Oracle. The cost survey working group is also allocating efforts to database the 2022 data and 2006, 2007 and 2008 data.
Location: NEFSCDB1 (new nova)
Schema: SSB_COST_SURVEY
Views: 
VCS_COMMON_COSTS_V 
Tables: 
VCS_COST20211 
VCS_COST20212 
VCS_COST20215 
VCS_SURVEY_DETAILS
VCS_COST_CATEGORIES 

Please reach out to Sam Werner and/or Greg Ardini with any questions 

In addition ll cost survey data can be found on the socialscience drive at in flat files (Excel): 
\\net\work5\socialsci\Cost_survey_data_all_years

Here is a bit of R code that you can use to read in that data:
```
net<-full.path.to.net
cost_directory<-file.path(net,"work5","socialsci","Trip_Costs","2007-2020")
X2007_2012 <- read_excel(file.path(cost_directory,"2007_2012.xlsx"))
X2013_2020 <- read_excel(file.path(cost_directory,"2013_2020.xlsx"))
```

More to follow.  It is not stored in oracle.

