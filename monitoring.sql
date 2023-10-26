with 
utemp_check as ( 
  select count(*) utemp_count from syscat.tablespaces where datatype = 'U' ),
config_check as (
  select 
    cast(substr(name,1,20) as varchar(20)) name, 
    cast(substr(value,1,20) as varchar(20)) value
  from table(db_get_cfg(-1)) where 
    name in ('mon_req_metrics','mon_act_metrics','mon_obj_metrics') ),
req_check as (
  select value req_value from config_check where name = 'mon_req_metrics' ),
act_check as (
  select value act_value from config_check where name = 'mon_act_metrics' ),
obj_check as (
  select value obj_value from config_check where name = 'mon_obj_metrics' )
select t.prereq "db2mon Prerequisite", t.msg "Status"
from
  utemp_check,
  req_check,
  act_check,
  obj_check,
  table( values
    ( 'MON_REQ_METRICS correct? ', 
       case when req_value in ('BASE','EXTENDED') then 'OK (currently ' || rtrim(req_value) || ')' 
       else '******** Needs to be BASE or EXTENDED to get full data collection' end ),
    ( 'MON_ACT_METRICS correct? ', case when act_value in ('BASE','EXTENDED') then 'OK (currently ' || rtrim(act_value) || ')' 
       else '******** Needs to be BASE or EXTENDED to get full data collection' end ),
    ( 'MON_OBJ_METRICS correct? ', case when obj_value in ('BASE','EXTENDED') then 'OK (currently ' || rtrim(obj_value) || ')' 
       else '******** Needs to be BASE or EXTENDED to get full data collection' end ) ) as t(prereq,msg);
