SELECT
  'test1' AS sample_no,
  dbmon.db_name,
  dbmon.db_status,
  dbmon.db_conn_time,
  dbmon.db_act_time,
  dbmon.db_act_aborted,
  dbmon.db_act_completed,
  dbmon.db_act_rejected,
  dbmon.db_rows_read,
  dbmon.db_rows_written,
  bp.bp_name,
  bp.bp_id,
  bp.bp_cur_pages,
  bp.bp_async_data_read_reqs,
  bp.bp_async_data_write_reqs,
  bp.bp_async_index_read_reqs,
  bp.bp_async_index_write_reqs,
  bp.bp_direct_reads,
  bp.bp_direct_writes,
  bp.bp_direct_read_reqs,
  bp.bp_direct_write_reqs
FROM
  TABLE(MON_GET_DATABASE(-2)) AS dbmon
  CROSS JOIN
  LATERAL (SELECT * FROM TABLE(MON_GET_TABLE('SYSIBMADM', 'SNAPDB', -2))) AS db
  CROSS JOIN
  LATERAL (SELECT * FROM TABLE(MON_GET_BUFFERPOOL(-2))) AS bp
