SELECT 'Database Health Report' AS "Category", '' AS "Metric", '' AS "Value"
UNION ALL

-- Query Performance
SELECT 'Query Performance' AS "Category",
       'Number of Queries' AS "Metric",
       COUNT(*) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Query Performance' AS "Category",
       'Total Execution Time (ms)' AS "Metric",
       SUM(TOTAL_EXEC_TIME_MS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Query Performance' AS "Category",
       'Average Execution Time (ms)' AS "Metric",
       AVG(TOTAL_EXEC_TIME_MS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Query Performance' AS "Category",
       'Max Execution Time (ms)' AS "Metric",
       MAX(TOTAL_EXEC_TIME_MS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Transaction Statistics
SELECT 'Transaction Statistics' AS "Category",
       'Number of Transactions' AS "Metric",
       COUNT(*) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Transaction Statistics' AS "Category",
       'Total Commits' AS "Metric",
       SUM(COMMIT_SQL_STMTS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Transaction Statistics' AS "Category",
       'Total Rollbacks' AS "Metric",
       SUM(ROLLBACK_SQL_STMTS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Locking and Blocking
SELECT 'Locking and Blocking' AS "Category",
       'Total Deadlocks' AS "Metric",
       SUM(TOTAL_DEADLOCKS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Locking and Blocking' AS "Category",
       'Total Lock Timeouts' AS "Metric",
       SUM(TOTAL_LOCK_TIMEOUTS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Locking and Blocking' AS "Category",
       'Total Lock Escalations' AS "Metric",
       SUM(TOTAL_LOCK_ESCALATIONS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Buffer Pool Usage
SELECT 'Buffer Pool Usage' AS "Category",
       'Data Logical Reads' AS "Metric",
       SUM(POOL_DATA_L_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Index Logical Reads' AS "Metric",
       SUM(POOL_INDEX_L_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Data Physical Reads' AS "Metric",
       SUM(POOL_DATA_P_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Index Physical Reads' AS "Metric",
       SUM(POOL_INDEX_P_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Async Data Reads' AS "Metric",
       SUM(POOL_ASYNC_DATA_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Async Index Reads' AS "Metric",
       SUM(POOL_ASYNC_INDEX_READS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Async Data Writes' AS "Metric",
       SUM(POOL_ASYNC_DATA_WRITES) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Buffer Pool Usage' AS "Category",
       'Async Index Writes' AS "Metric",
       SUM(POOL_ASYNC_INDEX_WRITES) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Sort Activity
SELECT 'Sort Activity' AS "Category",
       'Total Sorts' AS "Metric",
       SUM(TOTAL_SORTS) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Sort Activity' AS "Category",
       'Total Sort Time (ms)' AS "Metric",
       SUM(TOTAL_SORT_TIME) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Application Connections
SELECT 'Application Connections' AS "Category",
       'Number of Active Connections' AS "Metric",
       COUNT(DISTINCT APPL_ID) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T

UNION ALL

-- Resource Utilization
SELECT 'Resource Utilization' AS "Category",
       'Average Statement Execution Time (s)' AS "Metric",
       DECIMAL(AVG_STMT_EXEC_TIME / 1000, 10, 2) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Resource Utilization' AS "Category",
       'Average Lock Wait Time (s)' AS "Metric",
       DECIMAL(AVG_LOCK_WAIT_TIME / 1000, 10, 2) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T
UNION ALL
SELECT 'Resource Utilization' AS "Category",
       'Max Agent CPU Time (s)' AS "Metric",
       DECIMAL(MAX_AGENT_CPU_TIME / 1000, 10, 2) AS "Value"
FROM TABLE (SYSPROC.MON_GET_ACTIVITY(NULL, -2)) AS T;
