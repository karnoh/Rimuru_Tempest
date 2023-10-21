-- Consolidated Summary of Changes in IBM Db2 LUW Database as of Today

-- Date of the summary
WITH DateSummary AS (
    SELECT CURRENT DATE AS SummaryDate
),

-- Tables added or modified today
TablesSummary AS (
    SELECT
        TABSCHEMA AS SchemaName,
        TABNAME AS TableName,
        CREATE_TIME AS Created,
        ALTER_TIME AS LastModified
    FROM
        SYSCAT.TABLES
    WHERE
        DATE(ALTER_TIME) = CURRENT DATE
),

-- Columns added or modified today
ColumnsSummary AS (
    SELECT
        TABSCHEMA AS SchemaName,
        TABNAME AS TableName,
        COLNAME AS ColumnName,
        CREATE_TIME AS Created,
        ALTER_TIME AS LastModified
    FROM
        SYSCAT.COLUMNS
    WHERE
        DATE(ALTER_TIME) = CURRENT DATE
),

-- Indexes added or modified today
IndexesSummary AS (
    SELECT
        INDSCHEMA AS SchemaName,
        INDNAME AS IndexName,
        CREATE_TIME AS Created,
        ALTER_TIME AS LastModified
    FROM
        SYSCAT.INDEXES
    WHERE
        DATE(ALTER_TIME) = CURRENT DATE
),

-- Procedures added or modified today
ProceduresSummary AS (
    SELECT
        ROUTINESCHEMA AS SchemaName,
        ROUTINENAME AS ProcedureName,
        CREATE_TIME AS Created,
        LAST_ALTERED AS LastModified
    FROM
        SYSCAT.ROUTINES
    WHERE
        DATE(LAST_ALTERED) = CURRENT DATE
),

-- Views added or modified today
ViewsSummary AS (
    SELECT
        VIEWSCHEMA AS SchemaName,
        VIEWNAME AS ViewName,
        CREATE_TIME AS Created,
        ALTER_TIME AS LastModified
    FROM
        SYSCAT.VIEWS
    WHERE
        DATE(ALTER_TIME) = CURRENT DATE
),

-- Summary of changes in tablespaces (added or modified)
TablespacesSummary AS (
    SELECT
        TBSP_NAME AS TablespaceName,
        CREATE_TIME AS Created,
        ALTER_TIME AS LastModified
    FROM
        SYSCAT.TABLESPACES
    WHERE
        DATE(ALTER_TIME) = CURRENT DATE
)

-- Consolidate all summaries into one table for reporting
SELECT
    ds.SummaryDate,
    'Table' AS ObjectType,
    ts.SchemaName,
    ts.TableName AS ObjectName,
    ts.Created,
    ts.LastModified
FROM DateSummary ds
JOIN TablesSummary ts ON 1=1

UNION ALL

SELECT
    ds.SummaryDate,
    'Column' AS ObjectType,
    cs.SchemaName,
    cs.TableName AS ObjectName,
    cs.Created,
    cs.LastModified
FROM DateSummary ds
JOIN ColumnsSummary cs ON 1=1

UNION ALL

SELECT
    ds.SummaryDate,
    'Index' AS ObjectType,
    is.SchemaName,
    is.IndexName AS ObjectName,
    is.Created,
    is.LastModified
FROM DateSummary ds
JOIN IndexesSummary is ON 1=1

UNION ALL

SELECT
    ds.SummaryDate,
    'Procedure' AS ObjectType,
    ps.SchemaName,
    ps.ProcedureName AS ObjectName,
    ps.Created,
    ps.LastModified
FROM DateSummary ds
JOIN ProceduresSummary ps ON 1=1

UNION ALL

SELECT
    ds.SummaryDate,
    'View' AS ObjectType,
    vs.SchemaName,
    vs.ViewName AS ObjectName,
    vs.Created,
    vs.LastModified
FROM DateSummary ds
JOIN ViewsSummary vs ON 1=1

UNION ALL

SELECT
    ds.SummaryDate,
    'Tablespace' AS ObjectType,
    tss.TablespaceName AS SchemaName,
    tss.TablespaceName AS ObjectName,
    tss.Created,
    tss.LastModified
FROM DateSummary ds
JOIN TablespacesSummary tss ON 1=1
ORDER BY ObjectType, SchemaName, ObjectName, LastModified;
