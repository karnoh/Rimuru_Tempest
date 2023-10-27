WITH QueryPerformanceData AS (
    SELECT
        APPLICATION_HANDLE AS ApplicationHandle,
        STMT_TEXT AS QueryText,
        TOTAL_EXEC_TIME AS TotalExecutionTime,
        EXECUTION_TIME AS CPUTime,
        BUFFER_POOL_DATA_L_READS AS NumberOfRowsReturned,
        LOCK_WAIT_TIME AS LockWaitTime,
        SORTS_TOTAL_TIME AS SortTime,
        TOTAL_APP_COMMITS AS Commits,
        TOTAL_APP_ROLLBACKS AS Rollbacks,
        IO_TIME AS IOWaitTime
    FROM
        TABLE(MON_GET_ACTIVITY(-1, NULL)) AS MON
    WHERE
        STMT_TEXT IS NOT NULL
        AND EXECUTION_TIME > 0
)

SELECT
    *,
    (CASE
        WHEN TotalExecutionTime < 1000 THEN 0
        WHEN TotalExecutionTime BETWEEN 1000 AND 5000 THEN 1
        WHEN TotalExecutionTime BETWEEN 5000 AND 10000 THEN 2
        ELSE 3
    END
    +
    CASE
        WHEN CPUTime < 1000 THEN 0
        WHEN CPUTime BETWEEN 1000 AND 5000 THEN 1
        WHEN CPUTime BETWEEN 5000 AND 10000 THEN 2
        ELSE 3
    END
    +
    (CASE
        WHEN MemoryUsage < 1000 THEN 0
        WHEN MemoryUsage BETWEEN 1000 AND 10000 THEN 1
        WHEN MemoryUsage BETWEEN 10000 AND 100000 THEN 2
        ELSE 3
    END)
    +
    (CASE
        WHEN NumberOfRowsReturned < 100 THEN 0
        WHEN NumberOfRowsReturned BETWEEN 100 AND 1000 THEN 1
        WHEN NumberOfRowsReturned BETWEEN 1000 AND 10000 THEN 2
        ELSE 3
    END
    +
    (CASE
        WHEN LockWaitTime < 1000 THEN 0
        WHEN LockWaitTime BETWEEN 1000 AND 5000 THEN 1
        WHEN LockWaitTime BETWEEN 5000 AND 10000 THEN 2
        ELSE 3
    END
    +
    (CASE
        WHEN IOWaitTime < 1000 THEN 0
        WHEN IOWaitTime BETWEEN 1000 AND 5000 THEN 1
        WHEN IOWaitTime BETWEEN 5000 AND 10000 THEN 2
        ELSE 3
    END)
    ) AS TotalScore
FROM
    QueryPerformanceData;
