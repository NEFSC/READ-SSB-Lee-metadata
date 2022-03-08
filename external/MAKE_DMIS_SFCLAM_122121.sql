/*

Make DMIS_WIND table

BEN GALUARDI

12/16/21

this table build follows the testing done to explore missing IDNUM/IMGID from wind overlays

previous versions used   , max(vtrserno) as vtrserno (not sure why... double check)
and referenced DMIS schema for VTR tables. 
This version references NOAA schema directly for DOCUMENT/IMAGE/CATCH

update: dealnum added using logic from BRants function but in a left join fashion

01/03/22 updated adding SFCLAM up to current date (new table reference)
01/03/22 updated gearcodes; one scallop dredge was missing and PTL was coded as PTO

*/


-- drop tables


DROP TABLE BG_DMIS_2
/
DROP TABLE BG_VTR_1
/
DROP TABLE BG_DMIS_SFCLAM
/
DROP TABLE BG_DMIS_LL
/
DROP TABLE DMIS_WIND_TEST
/

-- get VTR data
CREATE TABLE BG_VTR_1 AS 

  SELECT 
  serial_num as vtrserno
--  , imgid
  ,vessel_permit_num as permit
  ,TO_NUMBER(carea) carea
  ,TO_NUMBER(area) area
  ,COALESCE(-NULLIF((lon_degree + (lon_minute/60) + NVL((lon_second/3600),0)),0)
  ,-NULLIF((clondeg + (clonmin/60) + NVL((clonsec/3600),0)),0)) ddlon
  ,COALESCE(NULLIF((lat_degree + (lat_minute/60) + NVL((lat_second/3600),0)),0)
  ,NULLIF((clatdeg + (clatmin/60) + NVL((clatsec/3600),0)),0)) ddlat
  FROM 
  noaa.document  d
  ,noaa.images v 
  LEFT OUTER JOIN 
  v_loran_key lk 
  ON lk.loran1 = v.loran1 AND lk.loran2 = v.loran2
  WHERE
  d.docid = v.docid
  AND D.DATE_SAIL >= '01-JAN-07'
--)
/

-- combine DMIS data for 2008-now
CREATE TABLE BG_DMIS_2 AS 

select d.*
--    , v.imgid
    , v.ddlon
    , v.ddlat
from (
    select DOCID
         , secgearfish
         , tripcatg
         , d.permit
         , d.area
         , area_source
         , live_pounds
         , landed
         , d.pounds
         , d.vtr_sail
         , d.vtr_land
         , trip_length
         , dlr_date
         , date_trip
         , d.nespp3
         , dollar
         , dollar_gdp
         , d.vtrserno
         , vtr_port
         , vtr_state
         , dealer_rpt_id 

         from apsd.dmis_all_years d
         
    union all
         select DOCID
         , secgearfish
         , tripcatg
         , permit
         , area
         , area_source
         , live_pounds
         , landed
         , pounds
         , vtr_sail
         , vtr_land
         , trip_length
         , dlr_date
         , date_trip
         , nespp3
         , dollar
         , dollar_gdp
         , vtrserno
         , vtr_port
         , vtr_state
         , dealer_rpt_id
         from fso.jml_t_grnd_trips_09
    union all
        select DOCID
         , secgearfish
         , tripcatg
         , permit
         , area
         , area_source
         , live_pounds
         , landed
         , pounds
         , vtr_sail
         , vtr_land
         , trip_length
         , dlr_date
         , date_trip
         , nespp3
         , dollar
         , dollar_gdp
         , vtrserno
         , vtr_port
         , vtr_state
         , dealer_rpt_id
         from fso.jml_t_grnd_trips_08
    union all
             select DOCID
         , secgearfish
         , tripcatg
         , permit
         , area
         , area_source
         , live_pounds
         , landed
         , pounds
         , vtr_sail
         , vtr_land
         , trip_length
         , dlr_date
         , date_trip
         , nespp3
         , dollar
         , dollar_gdp
         , vtrserno
         , vtr_port
         , vtr_state
         , dealer_rpt_id
         from fso.jml_t_grnd_trips_07
         ) d
         , BG_VTR_1 v
     
     WHERE v.permit = d.permit       
     AND v.vtrserno = d.vtrserno
     AND d.pounds > 0
     AND d.docid IS NOT NULL
--     AND d.vtrserno is not null
--     AND v.vtrserno is not null
     AND v.ddlon BETWEEN -78 AND -66  -- big area... 
     AND v.ddlat BETWEEN 33 AND 45  
     AND tripcatg IN (1, 4) --only include commercial and RSA catch, NO pchisq
     AND secgearfish <> 'CAR'
--     and dealer_rpt_id is not null  -- this needs to NoT be null... 
-- )

/
-- combine DMIS-VTR for lat/lon and IMGID
CREATE TABLE BG_DMIS_LL as 
 
  SELECT
     d.docid
     , i.imgid
     , TO_CHAR(date_trip,'YYYY') year
     , d.vtrserno
     , d.vtr_port as PORT_STATE
     , d.vtr_state as VTR_STATE
     , d.secgearfish
     , d.permit
     , d.area
     , d.area_source
     , SUM(d.landed) as landed
     , SUM(d.live_pounds) as live_pounds
     , SUM(d.pounds) as pounds
     , d.vtr_sail
     , d.vtr_land
     , d.trip_length
     , d.date_trip
     , d.nespp3
--                 , d.dealnum
     , dealer_rpt_id
      ,  CASE WHEN SECGEARFISH in ('DRM','DRO','DRU') THEN 'DREDGE-OTHER'
         WHEN SECGEARFISH in ('DRC') THEN 'DREDGE-CLAM' 
         WHEN SECGEARFISH in ('DRS', 'DTS', 'DTC', 'DSC') THEN 'DREDGE-SCALLOP'
         WHEN SECGEARFISH in ('GNS') THEN 'GILLNET-SINK'
         WHEN SECGEARFISH in ('GND', 'GNO','GNR','GNT') THEN 'GILLNET-OTHER'
         WHEN SECGEARFISH in ('FYK','WEI','TRP') THEN 'WEIR-TRAP'
         WHEN SECGEARFISH in ('PUR') THEN 'SEINE-PURSE'
         WHEN SECGEARFISH in ('SED','SEH','SES','STS') THEN 'SEINE-OTHER'
    --     WHEN SECGEARFISH in ('HND') THEN 'HANDLINE'
         WHEN SECGEARFISH in ('RAK','DIV','HRP','HND','CST') THEN 'HANDLINE'
         WHEN SECGEARFISH in ('OBP', 'OHS','OTB','OTC','OTF','OTO','OTR','OTS','OTT','PTB', 'TTS') THEN 'TRAWL-BOTTOM'
         WHEN SECGEARFISH in ('PTM','OTM') THEN 'TRAWL-MIDWATER'
         WHEN SECGEARFISH in ('LLB') THEN 'LONGLINE-BOTTOM'
         WHEN SECGEARFISH in ('LLP') THEN 'LONGLINE-PELAGIC'
     WHEN SECGEARFISH in ('PTC','PTE','PTF','PTH', 'PTO','PTS','PTW','PTX') THEN 'POT-OTHER' 
     WHEN SECGEARFISH in ('PTL') THEN 'POT-LOBSTER'    
     WHEN SECGEARFISH in ('CAR') THEN 'CARRIER'
     ELSE 'OTHER' END as GEARCODE
     , sum(d.dollar) as dollar
     , SUM(d.dollar_gdp) as dollar_gdp
--     , d.imgid
     , d.ddlon
     , d.ddlat
     FROM 
--         dmis d, vtr v
--        BG_VTR_1 v, 
        BG_DMIS_2 d
    left join(
	 select imgid, serial_num
	 from noaa.images
	 ) i
        on d.vtrserno = i.serial_num   
         
--         AND pounds > 0
--     AND d.docid IS NOT NULL
--     AND d.vtrserno is not null
--     AND v.vtrserno is not null
----                 AND d.dealer_rpt_id is not null
----                 AND v.ddlon BETWEEN -78 AND -73
----                 AND v.ddlat BETWEEN 33 AND 38  
--     AND v.ddlon BETWEEN -78 AND -66  -- big area... 
--     AND v.ddlat BETWEEN 33 AND 45
     
     GROUP BY 
     d.docid
     , i.imgid
--                 , d.dealnum
     , dealer_rpt_id
     , d.secgearfish
     ,d.vtrserno
     , d.vtr_port 
     , d.vtr_state 
     ,d.permit
     , d.area
     , d.area_source
     ,d.vtr_sail
     , d.vtr_land
     , d.trip_length
     ,d.date_trip
     ,d.nespp3
     ,d.ddlon
     ,d.ddlat
    ,  CASE WHEN SECGEARFISH in ('DRM','DRO','DRU') THEN 'DREDGE-OTHER'
         WHEN SECGEARFISH in ('DRC') THEN 'DREDGE-CLAM' 
         WHEN SECGEARFISH in ('DRS', 'DTS', 'DTC', 'DSC') THEN 'DREDGE-SCALLOP'
         WHEN SECGEARFISH in ('GNS') THEN 'GILLNET-SINK'
         WHEN SECGEARFISH in ('GND', 'GNO','GNR','GNT') THEN 'GILLNET-OTHER'
         WHEN SECGEARFISH in ('FYK','WEI','TRP') THEN 'WEIR-TRAP'
         WHEN SECGEARFISH in ('PUR') THEN 'SEINE-PURSE'
         WHEN SECGEARFISH in ('SED','SEH','SES','STS') THEN 'SEINE-OTHER'
    --     WHEN SECGEARFISH in ('HND') THEN 'HANDLINE'
         WHEN SECGEARFISH in ('RAK','DIV','HRP','HND','CST') THEN 'HANDLINE'
         WHEN SECGEARFISH in ('OBP', 'OHS','OTB','OTC','OTF','OTO','OTR','OTS','OTT','PTB', 'TTS') THEN 'TRAWL-BOTTOM'
         WHEN SECGEARFISH in ('PTM','OTM') THEN 'TRAWL-MIDWATER'
         WHEN SECGEARFISH in ('LLB') THEN 'LONGLINE-BOTTOM'
         WHEN SECGEARFISH in ('LLP') THEN 'LONGLINE-PELAGIC'
     WHEN SECGEARFISH in ('PTC','PTE','PTF','PTH', 'PTO','PTS','PTW','PTX') THEN 'POT-OTHER' 
     WHEN SECGEARFISH in ('PTL') THEN 'POT-LOBSTER'    
     WHEN SECGEARFISH in ('CAR') THEN 'CARRIER'
     ELSE 'OTHER' END
/

--union with SFCLAM

CREATE TABLE BG_DMIS_SFCLAM AS

with sfclam_trimmed as (
    select  to_char(vr_rec_id) as IMGID
        , vr_rec_id as DOCID
        , to_char(YEAR) as YEAR
        , catch_date as date_trip
        , VTR_PORT
        , VTR_STATE
        , trip_length
        , PERMIT
        , NULL as dealer_rpt_id
        , to_char(DEALNUM) as DEALNUM
        , value as dollar
        , POUNDS 
        , case when NESPP3 = '769' then round(POUNDS/5.27)  -- from FSO_ADMIN.MV_SAFIS_SPECIES_QC
                 when NESPP3 = '754' then round(POUNDS/8.24) -- from FSO_ADMIN.MV_SAFIS_SPECIES_QC
                 when NESPP3 = '764' then POUNDS   -- only 45 records in all years... and most have NULL value.. 
                 end as LANDED
        , LON as DDLON
        , LAT as DDLAT
        , 'DREDGE-CLAM' as GEARCODE
        , 'DRC' as SECGEARFISH 
--        , SPPNAME
        , to_char(NESPP3) as NESPP3
        , 'SFCLAM' as source
    from SFCLAM_BG_010322
    where year > 2007
--    where year = 2019  -- 2019 only
    AND LON BETWEEN -78 AND -66
    AND LAT BETWEEN 33 AND 45  
    )   
    
, dmis_trimmed as(
 select  to_char(IMGID) IMGID
        , docid
        , YEAR
        , date_trip
        , PORT_STATE as VTR_PORT
        , VTR_STATE
        , trip_length
        , PERMIT
        , dealer_rpt_id
        , NULL as DEALNUM
        , dollar
        , POUNDS
        , LANDED
        , DDLON
        , DDLAT
        , GEARCODE 
        , to_char(SECGEARFISH) as SECGEARFISH
--        , SPPNAME
        , to_char(NESPP3) as NESPP3
        , 'DMIS' as source
    from BG_DMIS_LL d
    WHERE 
     NOT EXISTS(select 'x' 
           from SFCLAM_BG_030220 b 
           where b.permit = d.permit 
           and b.year = d.year 
           and d.nespp3 IN (769,754) 
       )     --omit SF OQ landings from DMIS where permit exists within year in SFCLAM
)

select *
from sfclam_trimmed
union all
select *
from dmis_trimmed

/

-- join with CFDERS for DEALNUM to complete the table for Wind

CREATE TABLE APSD.DMIS_WIND_TEST as

with dealnums as (

select distinct dealer_rpt_id
    , dealnum
    , state_dnum
    , permit
    , year
    from cfders_all_years
    where permit not in '000000'
    AND dealer_rpt_id is not NULL
    and dealnum not in '0'
)


select a.*
--, NVL(NVL(TO_CHAR(d.dealnum), d.state_dnum), a.dealnum) as dealnum_fcn
, coalesce(to_char(a.DEALNUM), to_char(d.DEALNUM)) DEALNUM_C
, d.state_dnum
--, d.dealnum as cfders_dnum
from apsd.BG_DMIS_SFCLAM a
left join (
 select *
 from dealnums
) d
ON (a.permit = d.permit and a.dealer_rpt_id = d.dealer_rpt_id AND a.year = d.year)

/

-- drop original DEALNUM, use the coalesced one from above

ALTER TABLE apsd.dmis_wind_test DROP (DEALNUM, STATE_DNUM)
/

ALTER TABLE
    apsd.dmis_wind_test
RENAME COLUMN
    DEALNUM_C
TO
    DEALNUM
/

-- drop temp tables

DROP TABLE BG_DMIS_2
/
DROP TABLE BG_VTR_1
/
DROP TABLE BG_DMIS_SFCLAM
/
DROP TABLE BG_DMIS_LL
/

GRANT SELECT ON APSD.DMIS_WIND_TEST TO NEFSC
/

-- quick test using REV WIND overlays. look for missing IDNUMs 
/*
select count(distinct(IDNUM)) as idnum_missing
--, round(count(distinct(IDNUM))/(select count(distinct(IDNUM)) from rev_wind_deis_100421 where year = 2019),3) as percent_missing
--, w.AREA
, w.YEAR
from rev_wind_deis_100421 w
left join (
 select * from apsd.DMIS_WIND_TEST
-- select * from apsd.dmis_sfclam_040620 --original table
) d

on to_char(w.IDNUM) = to_char(d.IMGID)
where d.IMGID is null
--and w.year = 2019
--and d.landed > 0

group by w.YEAR  
/

/
--
---- which IDNUMS are in old version of DMIS_SFCLAM but not in new one
with idnums1 as (

select distinct idnum
--, w.AREA
--, w.YEAR
from rev_wind_deis_100421 w
left join (
 select * from apsd.DMIS_WIND_TEST
-- select * from apsd.dmis_sfclam_040620
) d

on to_char(w.IDNUM) = to_char(d.IMGID)
where d.IMGID is null

--group by w.YEAR  

)

SELECT count(distinct(imgid))
, source
, year
FROM idnums1 i
left join (
  select *
  from apsd.dmis_sfclam_040620
 ) a
 
 on a.imgid = i.idnum

group by source, year

--,idnums2 as (
--
--select distinct idnum
----, w.AREA
----, w.YEAR
--from rev_wind_deis_100421 w
--left join (
---- select * from apsd.DMIS_WIND_TEST
-- select * from apsd.dmis_sfclam_040620
--) d
--
--on to_char(w.IDNUM) = to_char(d.IMGID)
--where d.IMGID is null
--
--)
--
--select distinct(b.idnum)
--from idnums1 a, idnums2 bk
--where b.idnum not in a.idnum
/
--
--select *
--from apsd.dmis_wind_test
*/


