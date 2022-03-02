# Overview

SVDBS contains information from the fishery independent surveys.

Most of the information there has been processed to some degree.

# Current Collection Methods

# Changes to Collections Methods

# Tips and Tricks.

# General Caveats.

The survey uses the svspp set of species codes. This is different from the nespp3/4 codes. The best way to match to dealer data appears to be through using the itis codes, using data from these two tables:

```
select * from svdbs.itis_lookup
select nespp4, species_itis, common_name, scientific_name from cfdbs.species_itis_ne
```

# Sample Code

Code to extract GOM cod ages and lengths from the bottom trawl and MADMF survey

```
select cruise6, stratum, svspp,length, age, count(age) as count from UNION_FSCS_SVBIO
where cruise6 in 
  (select distinct cruise6 from svdbs_cruises where purpose_code in(10,11) and status_code=10 and Season in ( 'SPRING', 'FALL')) and
svspp in (73) and cruise6>=201201 and age is not null and ((stratum between 01260 and 01300) or (stratum between 01360 and 01400))
group by svspp, length, age, cruise6, stratum;
```


# Update Frequency and Completeness 

# Other Metadata sources

+ Preceded by: ?
+ Succeeded by: ?

# Related Tables 

# Support Tables 

