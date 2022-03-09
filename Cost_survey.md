Hi!

The cost survey data can be found on the socialscience drive at 
\\net\work5\socialsci\Cost_survey_data_all_years

Here is a bit of R code that you can use to read in that data:
```
net<-full.path.to.net
cost_directory<-file.path(net,"work5","socialsci","Trip_Costs","2007-2020")
X2007_2012 <- read_excel(file.path(cost_directory,"2007_2012.xlsx"))
X2013_2020 <- read_excel(file.path(cost_directory,"2013_2020.xlsx"))
```

More to follow.  It is not stored in oracle.

