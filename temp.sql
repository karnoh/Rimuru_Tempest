-- Create a temporary table to store the metrics
db2 "create table session.db2mon_metrics (
  sample_no int,
  db_name varchar(8),
  db_status varchar(8),
  db_conn_time bigint,
  db_act_time bigint,
  db_act_aborted bigint,
  db_act_completed bigint,
  db_act_rejected bigint,
  db_rows_read bigint,
  db_rows_written bigint,
  bp_name varchar(128),
  bp_id smallint,
  bp_cur_pages bigint,
  bp_async_data_read_reqs bigint,
  bp_async_data_write_reqs bigint,
  bp_async_index_read_reqs bigint,
  bp_async_index_write_reqs bigint,
  bp_direct_reads bigint,
  bp_direct_writes bigint,
  bp_direct_read_reqs bigint,
  bp_direct_write_reqs bigint
)"

-- Insert the metrics into the table using MON_GET functions
db2 "insert into session.db2mon_metrics select $i,
  mon_get_database(-2) as (db_name, db_status, db_conn_time, db_act_time, db_act_aborted, db_act_completed, db_act_rejected),
  mon_get_table('SYSIBMADM','SNAPDB',-2) as (db_rows_read, db_rows_written),
  mon_get_bufferpool(-2) as (bp_name, bp_id, bp_cur_pages),
  mon_get_bufferpool('',-2) as (bp_async_data_read_reqs, bp_async_data_write_reqs, bp_async_index_read_reqs, bp_async_index_write_reqs),
  mon_get_bufferpool('',-1) as (bp_direct_reads, bp_direct_writes),
  mon_get_bufferpool('',-1) as (bp_direct_read_reqs, bp_direct_write_reqs)"
