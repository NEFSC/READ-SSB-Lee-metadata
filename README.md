# Social Sciences Branch Metadata
Describes data in the oracle databases with a special eye towards fields that are used by social scientists

Please help make this a valuable up-to-date resource.  To add your knowledge:
1.   [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) - It's in the top right of github.
1.   Make your changes  - click the file you want to edit and then the little pencil on the right side.  ![Here's a picture](/figures/fork_edit.jpg)
1.   [Pull Request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) so the changes get into the document.



# General things

1.  Many data tables are live, with nightly or continuous updates. For example, when working with the  dealer data, expect approximately 300 changes or additions to the current and previous year of data per day. Data is “complete” 6-9 months after the end of the calendar year; however, small changes are always occurring.
This has consequences for reproducibility if you do not store a copy of the data.

1.  Make sure the table that you're using is not "stale."  Alot of the data is copied from GARFO to NEFSC servers. Sometimes, they stop getting copied. Sometimes they are updated monthly. One way to check this is to get the maximum DE, DC, or some other date field.

1.  There are tables and there are views.  Sometimes, the sql that generates a view can help you figure out why you're getting an unexplainable result of a query. For example, the following bit of code shows that SECTOR_PARTIPANTS_CPH is based, in part on permit.vps_owner, permit.vps_vessel, and mqrs.mort_elig_criteria.
![sql picture](/figures/sql.png)

1.  If you want to figure out how to get the data, take a look [here](https://github.com/NEFSC/READ-SSB-Lee-project-templates)

1.  It's good practice to include the schema when you query data. That is, write:
```
select * from permit.vps_owner
```
instead of 
```
select * from vps_owner

```
# The Goods

[Veslog](veslog.md) : Vessel Trip Reports (VTRs)

[AMS and DAS ](AMS_DAS.md) : Allocation Management System (AMS); Days-at-Sea Management System

[DMIS](DMIS.md): Data Matching and Imputation System

[MQRS](MQRS.md) : Moratorium Qualification something System

[Dealer](dealer.md) Dealer or Commercial Fisheries Dealer Database (CFDBS)

[observer](observer.md): Fishery Observers

[permit](permit.md): Vessel permitting

[sector](sector.md) : Sector Databases


# NOAA Requirements
“This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.”


1. who worked on this project:  Min-Yang
1. when this project was created: Jan, 2021 
1. what the project does: Describes data in the oracle databases with a special eye towards fields that are used by social scientists
1. why the project is useful:  Describes data in the oracle databases with a special eye towards fields that are used by social scientists
1. how users can get started with the project: Just read the readme
1. where users can get help with your project:  Open an issue
1. who maintains and contributes to the project. Min-Yang

# License file
See here for the [license file](https://github.com/minyanglee/READ-SSB-Lee-metadata/blob/main/License.txt)
