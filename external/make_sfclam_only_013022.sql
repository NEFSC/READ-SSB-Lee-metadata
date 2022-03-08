/*

Build SFCLAM data for WIND tables

CLipped from make_VTR_LL_v2.sql

This builds only the SFCLAM portion

run from FSO schema... 

Ben Galuardi

01/03/22

*/

drop table FSO.SFCLAM_BG_010322
/

create table FSO.SFCLAM_BG_010322 as 

with c as ( 
select cd
, bush
, pr
, pc as port_land
, st as state_land
, cy as county_land
, bush*pr as value
, num as permit
, dnum as dealnum
, vr_rec_id
, round(tas/24,2) as trip_length
, case when substr(anum, 1, 1) like 'C' then 769
       when substr(anum, 1, 1) like 'Q' then 754
       else 764 end as NESPP3
, case when substr(anum, 1, 1) like 'C' then bush*89
       when substr(anum, 1, 1) like 'Q' then bush*82.5
       else NULL end as spplivlb
, case when substr(anum, 1, 1) like 'C' then 'CLAM, SURF/BUSHEL'
       when substr(anum, 1, 1) like 'Q' then 'QUAHOGS/BUSHEL'
       else NULL end as SPPNAME     
  , CASE WHEN REGEXP_LIKE(clatdeg,'[^[:digit:]]') THEN NULL ELSE clatdeg END lat_degree
  ,CASE WHEN REGEXP_LIKE(clatmin,'[^[:digit:]]') THEN NULL ELSE clatmin END lat_minute
  ,CASE WHEN REGEXP_LIKE(clatsec,'[^[:digit:]]') THEN NULL ELSE clatsec END lat_second
  ,CASE WHEN REGEXP_LIKE(clondeg,'[^[:digit:]]') THEN NULL ELSE clondeg END lon_degree 
  ,CASE WHEN REGEXP_LIKE(clonmin,'[^[:digit:]]') THEN NULL ELSE clonmin END lon_minute
  ,CASE WHEN REGEXP_LIKE(clonsec,'[^[:digit:]]') THEN NULL ELSE clonsec END lon_second
from sfclam.sfoqvr
where substr(anum, 1, 1) in ('C','Q')  -- drops 49 records for the whole table... 
group by cd
, bush
, pr
, vr_rec_id
 , CASE WHEN REGEXP_LIKE(clatdeg,'[^[:digit:]]') THEN NULL ELSE clatdeg END 
  ,CASE WHEN REGEXP_LIKE(clatmin,'[^[:digit:]]') THEN NULL ELSE clatmin END 
  ,CASE WHEN REGEXP_LIKE(clatsec,'[^[:digit:]]') THEN NULL ELSE clatsec END 
  ,CASE WHEN REGEXP_LIKE(clondeg,'[^[:digit:]]') THEN NULL ELSE clondeg END  
  ,CASE WHEN REGEXP_LIKE(clonmin,'[^[:digit:]]') THEN NULL ELSE clonmin END 
  ,CASE WHEN REGEXP_LIKE(clonsec,'[^[:digit:]]') THEN NULL ELSE clonsec END 
, num 
, dnum
, pc
, st
, tas
, cy
, case when substr(anum, 1, 1) like 'C' then 769
       when substr(anum, 1, 1) like 'Q' then 754
       else 764 end
, case when substr(anum, 1, 1) like 'C' then bush*89
when substr(anum, 1, 1) like 'Q' then bush*82.5
else NULL end
, case when substr(anum, 1, 1) like 'C' then 'CLAM, SURF/BUSHEL'
       when substr(anum, 1, 1) like 'Q' then 'QUAHOGS/BUSHEL'
       else NULL end 
)

select c.cd as catch_date
, extract(year from c.cd) as year
, c.permit
, c.vr_rec_id
--, c.bush as bushels
--, c.pr as price_bushel
, c.value as value
, c.NESPP3
, c.SPPNAME
, c.spplivlb as POUNDS
, c.trip_length
, c.dealnum
, d.dlr as dealer
, d.city as deal_port
, d.st as deal_state
, p.portnm as VTR_PORT
, p.stateabb as VTR_STATE
, round(c.lat_degree + (c.lat_minute/60) + NVL(c.lat_second/3600, 0),4)  as lat
, -round(c.lon_degree + (c.lon_minute/60) + NVL(c.lon_second/3600, 0),4)  as lon
from c
left join(
    select year
    , dnum
    , max(dlr) as dlr
    , city
    , st
    from permit.dealer_permit
    group by year
    , dnum
    , city
    , st
) d
on (extract(year from c.cd) = d.year AND c.dealnum = d.dnum)
--left join(
-- select port2
-- , stateabb
-- , portnm
-- , statecd
-- , countycd
-- from vtr.port
--) p
--on (c.port_land = p.port2 AND c.state_land = p.statecd AND c.county_land = p.countycd)
left join (select  stateabb
       , portnm
       , port
       from vtr.vlporttbl      
       ) p
  on p.port = state_land||port_land||county_land
order by c.vr_rec_id desc
/

/
GRANT SELECT on FSO.SFCLAM_BG_010322 to APSD
/

-- switch to APSD... 
drop table APSD.SFCLAM_BG_010322
/
create table APSD.SFCLAM_BG_010322 as
select *
from FSO.SFCLAM_BG_010322
/
