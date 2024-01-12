SELECT
        ts,
        member,
        workload_name,
        pool_read_time + direct_read_time AS total_read_time,
        pool_write_time + direct_write_time AS total_write_time,
        pool_data_l_reads + pool_index_l_reads + pool_xda_l_reads + pool_col_l_reads AS total_logical_reads,
        pool_data_p_reads + pool_index_p_reads + pool_xda_p_reads + pool_col_p_reads AS total_physical_reads,
        pool_data_writes + pool_index_writes + pool_xda_writes + pool_col_writes AS total_writes,
        prefetch_wait_time + lob_prefetch_wait_time AS total_prefetch_wait_time,
        ext_table_recv_wait_time + ext_table_send_wait_time AS total_ext_table_wait_time,
        CASE WHEN pool_data_l_reads = 0 THEN 100 ELSE 100 * (pool_data_l_reads - pool_data_p_reads) / pool_data_l_reads END AS data_hit_ratio,
        CASE WHEN pool_index_l_reads = 0 THEN 100 ELSE 100 * (pool_index_l_reads - pool_index_p_reads) / pool_index_l_reads END AS index_hit_ratio,
        CASE WHEN pool_xda_l_reads = 0 THEN 100 ELSE 100 * (pool_xda_l_reads - pool_xda_p_reads) / pool_xda_l_reads END AS xda_hit_ratio,
        CASE WHEN pool_col_l_reads = 0 THEN 100 ELSE 100 * (pool_col_l_reads - pool_col_p_reads) / pool_col_l_reads END AS col_hit_ratio,
        (pool_read_time + direct_read_time) / (pool_data_p_reads + pool_index_p_reads + pool_xda_p_reads + pool_col_p_reads) AS avg_read_time,
        (pool_write_time + direct_write_time) / (pool_data_writes + pool_index_writes + pool_xda_writes + pool_col_writes) AS avg_write_time,
        CASE WHEN pool_data_p_reads = 0 THEN 100 ELSE 100 * (pool_data_p_reads - skipped_prefetch_data_p_reads) / pool_data_p_reads END AS data_prefetch_efficiency,
        CASE WHEN pool_index_p_reads = 0 THEN 100 ELSE 100 * (pool_index_p_reads - skipped_prefetch_index_p_reads) / pool_index_p_reads END AS index_prefetch_efficiency,
        CASE WHEN data_hit_ratio < 80 THEN 'RED' WHEN data_hit_ratio BETWEEN 80 AND 90 THEN 'YELLOW' ELSE 'GREEN' END AS result_color -- Assign a color code based on data hit ratio
    FROM
        TABLE(MON_GET_WORKLOAD(NULL, -2)) t
    WHERE
        ts BETWEEN '2024-01-01 00:00:00' AND '2024-01-12 23:59:59' -- Filter by time range
    GROUP BY
        member, workload_name -- Aggregate by member and workload name
    HAVING
        avg_read_time > 10 -- Filter by average read time
    ORDER BY
        data_hit_ratio DESC; -- Sort by data hit ratio
