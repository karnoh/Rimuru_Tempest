-- Comprehensive Database Health Report for IBM Db2 LUW

-- 1. Database Uptime
SELECT
    'Database Uptime' AS "Category",
    CASE
        WHEN DB_STATUS = 'ACTIVE' THEN 'Online'
        ELSE 'Offline'
    END AS "Status",
    CURRENT TIMESTAMP - DB_CONN_TIME AS "Uptime Duration"
FROM TABLE (SYSPROC.MON_GET_DATABASE('', -2)) AS T;

-- 2. Performance Metrics
SELECT
    'Performance Metrics' AS "Category",
    'Response Time' AS "Metric",
    AVG(DB2_CPU_TIME) AS "Average CPU Time",
    AVG(TOTAL_APP_COMMITS) AS "Average Commits",
    AVG(TOTAL_APP_ROLLBACKS) AS "Average Rollbacks"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(null, -2)) AS T;

-- 3. Tablespace Usage
SELECT
    'Tablespace Usage' AS "Category",
    TBSP_NAME,
    DECIMAL((TBSP_USED_PAGES * TBSP_PAGE_SIZE) / 1024, 10, 2) AS "Used Space (MB)",
    DECIMAL((TBSP_TOTAL_PAGES * TBSP_PAGE_SIZE) / 1024, 10, 2) AS "Total Space (MB)",
    DECIMAL((TBSP_USED_PAGES / TBSP_TOTAL_PAGES) * 100, 5, 2) AS "Used Percentage"
FROM SYSIBMADM.TBSP_UTILIZATION;

-- 4. Query Performance
SELECT
    'Query Performance' AS "Category",
    STMT_TEXT,
    TOTAL_EXECUTIONS AS "Total Executions",
    DECIMAL(AVG_EXEC_TIME_MS, 10, 2) AS "Average Execution Time (ms)"
FROM TABLE (SYSPROC.MON_GET_PKG_CACHE_STMT(null, -2)) AS T
WHERE TOTAL_EXECUTIONS > 0;

-- 5. Index Health
SELECT
    'Index Health' AS "Category",
    INDSCHEMA,
    INDNAME,
    CASE WHEN FRAGMENT_COUNT > 1 THEN 'Fragmented' ELSE 'Healthy' END AS "Status"
FROM SYSIBMADM.ADMINTABINFO;

-- 6. Locking and Blocking
SELECT
    'Locking and Blocking' AS "Category",
    AGENT_ID,
    APPLICATION_HANDLE,
    LOCK_WAIT_START_TIME,
    TABLE_SCHEMA,
    TABLE_NAME
FROM TABLE (SYSPROC.MON_GET_LOCKS(-2)) AS T
WHERE LOCK_WAIT_START_TIME IS NOT NULL;

-- 7. Deadlocks
SELECT
    'Deadlocks' AS "Category",
    LOCK_REQUESTOR_AGENT_ID,
    LOCK_WAITING_AGENT_ID,
    TABLE_SCHEMA,
    TABLE_NAME,
    LOCK_OBJECT_TYPE
FROM TABLE (SYSPROC.MON_GET_DEADLOCKS(-2)) AS T;

-- 8. Logs and Backup
SELECT
    'Logs and Backup' AS "Category",
    CASE
        WHEN NUM_LOG_SPAN = 0 THEN 'No Log Files'
        ELSE 'Log Files Present'
    END AS "Transaction Logs",
    CASE
        WHEN BACKUP_PENDING = 'NO' THEN 'Backup Up to Date'
        ELSE 'Backup Pending'
    END AS "Backup Status"
FROM TABLE (SYSPROC.ADMIN_GET_DB_STATUS()) AS T;

-- 9. Buffer Pool Usage
SELECT
    'Buffer Pool Usage' AS "Category",
    POOL_NAME,
    POOL_CURRENT_SIZE_PAGES AS "Current Size (Pages)",
    POOL_CUR_BUFF_WAIT_REQUESTS AS "Buffer Wait Requests",
    POOL_TOTAL_ASYNC_WRITE_REQUESTS AS "Async Write Requests"
FROM TABLE (SYSPROC.MON_GET_BUFFERPOOL(null, -2)) AS T;

-- 10. Database Configuration
SELECT
    'Database Configuration' AS "Category",
    NAME AS "Parameter",
    VALUE AS "Setting"
FROM TABLE (SYSPROC.ENV_GET_INST_INFO()) AS T
WHERE IS_DATABASE_CONFIGURATION = 1;

-- 11. Security and Access Controls
SELECT
    'Security and Access Controls' AS "Category",
    AUTHID AS "Authorization ID",
    CASE
        WHEN SECMECH = 'U' THEN 'User ID and Password'
        WHEN SECMECH = 'K' THEN 'Kerberos'
        ELSE 'Other'
    END AS "Security Mechanism"
FROM TABLE (SYSPROC.AUTH_LIST()) AS T;

-- 12. Table and Data Consistency
SELECT
    'Table and Data Consistency' AS "Category",
    TABLE_SCHEMA,
    TABLE_NAME,
    CASE
        WHEN CHECK_PENDING = 'NO' THEN 'Data Consistent'
        ELSE 'Data Inconsistent'
    END AS "Consistency Status"
FROM TABLE (SYSPROC.ADMIN_GET_TAB_COMPRESS_STATUS('')) AS T;

-- 13. High Availability and Failover
SELECT
    'High Availability and Failover' AS "Category",
    HA_ROLE AS "High Availability Role",
    CASE
        WHEN HAS_STATE = 'PRIMARY' THEN 'Primary'
        ELSE 'Standby'
    END AS "Database State"
FROM TABLE (SYSPROC.HADR_GET_ROLE(null)) AS T;

-- 14. Resource Utilization
SELECT
    'Resource Utilization' AS "Category",
    SUBSTR(MEM_CATEGORY, 1, 20) AS "Memory Category",
    DECIMAL(MEM_USED_MB, 10, 2) AS "Used Memory (MB)"
FROM TABLE (SYSPROC.ADMIN_GET_MEM_USAGE()) AS T;

-- 15. Database Logs and Events
SELECT
    'Database Logs and Events' AS "Category",
    MESSAGE_TIMESTAMP,
    MESSAGE_LEVEL,
    MESSAGE_TEXT
FROM TABLE (SYSPROC.ADMIN_GET_MSGS('','')) AS T
WHERE MESSAGE_LEVEL = 'E' OR MESSAGE_LEVEL = 'S';

-- 16. SQL Workload Analysis
SELECT
    'SQL Workload Analysis' AS "Category",
    STMT_TEXT,
    TOTAL_EXECUTIONS AS "Total Executions",
    DECIMAL(AVG_EXEC_TIME_MS, 10, 2) AS "Average Execution Time (ms)"
FROM TABLE (SYSPROC.MON_GET_PKG_CACHE_STMT(null, -2)) AS T
WHERE TOTAL_EXECUTIONS > 0;

-- 17. Capacity Planning
SELECT
    'Capacity Planning' AS "Category",
    'Storage Capacity' AS "Metric",
    DECIMAL(TOTAL_PAGES * PAGE_SIZE / 1024 / 1024, 10, 2) AS "Total Storage (GB)"
FROM TABLE (SYSPROC.ADMIN_GET_SNAPSHOT(null, -2)) AS T;

-- 18. Regular Maintenance
SELECT
    'Regular Maintenance' AS "Category",
    ACTIVITY_TYPE AS "Maintenance Activity",
    DECIMAL(ELAPSED_TIME / 1000, 10, 2) AS "Elapsed Time (seconds)"
FROM TABLE (SYSPROC.ADMIN_GET_MAINTENANCE_INFO('','')) AS T;

-- 19. Database Monitoring Tools
SELECT
    'Database Monitoring Tools' AS "Category",
    'Db2 Event Monitor' AS "Tool Name",
    CASE
        WHEN EVENT_STATUS = 'ACTIVE' THEN 'Enabled'
        ELSE 'Disabled'
    END AS "Status"
FROM TABLE (SYSPROC.MON_GET_EVENT_MONITORS(null, -2)) AS T
WHERE EVENT_STATUS = 'ACTIVE';

-- 20. Documentation and Alerts
SELECT
    'Documentation and Alerts' AS "Category",
    'Alert Configuration' AS "Alert Type",
    CASE
        WHEN ACTION_NAME IS NOT NULL THEN 'Configured'
        ELSE 'Not Configured'
    END AS "Status"
FROM TABLE (SYSPROC.ADMIN_GET_ALERTCFG(null)) AS T;
