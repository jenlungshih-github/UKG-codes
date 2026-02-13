WITH
    RankedTerminations
    AS
    (
        SELECT
            EMPLID,
            termination_dt,
            action_dt,
            snapshot_date,
            NOTE,
            [Employment Status],
            [Employment Status Effective Date],
            ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY termination_dt DESC) AS rn
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        WHERE 
        termination_dt < action_dt
            AND NOTE IN ('','I')
    )
SELECT
    EMPLID,
    termination_dt,
    action_dt,
    snapshot_date,
    NOTE,
    [Employment Status],
    [Employment Status Effective Date],
    -- Generate EXEC statement
    'EXEC [stage].[SP_UKG_EMPLOYEE_DATA_RETRO_ONLY_INSERT] ' +
    '@p_source_table = ''BCK.[UKG_EMPLOYEE_DATA_V_SNAPSHOT_' + CONVERT(VARCHAR(10), snapshot_date, 120) + ']'', ' +
    '@p_emplid = ''' + CAST(EMPLID AS VARCHAR(10)) + ''';' AS EXEC_Statement
FROM RankedTerminations
WHERE rn = 1
ORDER BY snapshot_date;

-- Generate individual EXEC statements for copy-paste execution
PRINT '=== INDIVIDUAL EXEC STATEMENTS FOR COPY-PASTE ==='
WITH
    RankedTerminations
    AS
    (
        SELECT
            EMPLID,
            snapshot_date,
            ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY termination_dt DESC) AS rn
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        WHERE 
        termination_dt < action_dt
            AND NOTE IN ('','I')
    )
SELECT
    'EXEC [stage].[SP_UKG_EMPLOYEE_DATA_RETRO_ONLY_INSERT] ' +
    '@p_source_table = ''BCK.[UKG_EMPLOYEE_DATA_V_SNAPSHOT_' + CONVERT(VARCHAR(10), snapshot_date, 120) + ']'', ' +
    '@p_emplid = ''' + CAST(EMPLID AS VARCHAR(10)) + ''';' AS EXEC_Statement
FROM RankedTerminations
WHERE rn = 1
ORDER BY snapshot_date;