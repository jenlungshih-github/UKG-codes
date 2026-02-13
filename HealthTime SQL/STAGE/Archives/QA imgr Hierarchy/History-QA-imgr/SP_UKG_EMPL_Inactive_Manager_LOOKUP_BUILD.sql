USE [HealthTime]
GO

CREATE or Alter PROCEDURE [stage].[SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD]
AS
-- exec [stage].[SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD]
/***************************************
* Created By: Jim Shih	
* Purpose: Creates lookup table for inactive managers in UKG employee data
* Table: This SP creates table [stage].[UKG_EMPL_Inactive_Manager] for inactive manager lookup
* -- 08/27/2025 Jim Shih: Created 
******************************************/
BEGIN
    SET NOCOUNT ON;

    -- Drop the table if it exists
    IF OBJECT_ID('[stage].[UKG_EMPL_Inactive_Manager]', 'U') IS NOT NULL
    BEGIN
        DROP TABLE [stage].[UKG_EMPL_Inactive_Manager];
    END
;
    -- Create the lookup table using CTE for ranking
    WITH
        RankedJobs
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                empl.[Last Name] + ', ' + empl.[First Name] AS MANAGER_NAME,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.DEPTID,
                J.BUSINESS_UNIT,
                J.LOCATION,
                J.JOB_INDICATOR,
                J.FTE,
                J.UNION_CD,
                J.JOBCODE,
                ROW_NUMBER() OVER(
                PARTITION BY J.EMPLID 
                ORDER BY (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                         J.FTE DESC 
            ) AS ROW_NO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
                JOIN [dbo].[UKG_EMPLOYEE_DATA] empl
                ON J.POSITION_NBR = empl.REPORTS_TO
            WHERE J.DML_IND <> 'D'
                AND J.HR_STATUS = 'I'
                AND J.EFFDT = (
                SELECT MAX(J1.EFFDT)
                FROM [HEALTH_ODS].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
            )
                AND J.EFFSEQ = (
                SELECT MAX(J2.EFFSEQ)
                FROM [HEALTH_ODS].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
            )
        )
    SELECT
        POSITION_NBR,
        EMPLID as MANAGER_EMPLID,
        MANAGER_NAME,
        HR_STATUS,
        EMPL_RCD,
        DEPTID,
        BUSINESS_UNIT,
        LOCATION,
        JOB_INDICATOR,
        FTE,
        UNION_CD,
        JOBCODE,
        ROW_NO,
        GETDATE() AS UPDATED_DT
    INTO [stage].[UKG_EMPL_Inactive_Manager]
    FROM RankedJobs
    WHERE ROW_NO = 1
        AND JOB_INDICATOR IN ('P', 'N');

    PRINT 'Table [stage].[UKG_EMPL_Inactive_Manager] has been successfully created.';

    -- Check if the table was created successfully and has data
    IF OBJECT_ID('[stage].[UKG_EMPL_Inactive_Manager]', 'U') IS NOT NULL
    BEGIN
        DECLARE @RecordCount INT;
        SELECT @RecordCount = COUNT(*)
        FROM [stage].[UKG_EMPL_Inactive_Manager];
        PRINT 'Table [stage].[UKG_EMPL_Inactive_Manager] contains ' + CAST(@RecordCount AS VARCHAR(10)) + ' records.';
    END
    ELSE
    BEGIN
        PRINT 'ERROR: Table [stage].[UKG_EMPL_Inactive_Manager] was not created successfully.';
        RETURN;
    END

    -- Create temp table for hierarchy positions analysis
    IF OBJECT_ID('tempdb..#HierarchyPositions') IS NOT NULL DROP TABLE #HierarchyPositions;

    CREATE TABLE #HierarchyPositions
    (
        emplid VARCHAR(11),
        MANAGER_EMPLID VARCHAR(11),
        MANAGER_NAME VARCHAR(100),
        MANAGER_HR_STATUS VARCHAR(1),
        POSITION_NBR VARCHAR(20),
        DEPTID VARCHAR(10),
        BUSINESS_UNIT VARCHAR(10)
    );

    -- Populate hierarchy positions from UKG employee data
    INSERT INTO #HierarchyPositions
    SELECT DISTINCT
        empl.EMPLID,
        mgr.MANAGER_EMPLID,
        mgr.MANAGER_NAME,
        mgr.HR_STATUS as MANAGER_HR_STATUS,
        mgr.POSITION_NBR,
        mgr.DEPTID,
        mgr.BUSINESS_UNIT
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] mgr
        ON empl.REPORTS_TO = mgr.POSITION_NBR;



    -- -- Verify column names exist
    -- SELECT 'Column verification' as Debug_Step;
    -- SELECT COLUMN_NAME
    -- FROM INFORMATION_SCHEMA.COLUMNS
    -- WHERE TABLE_SCHEMA = 'stage'
    --     AND TABLE_NAME = 'UKG_EMPL_Inactive_Manager'
    -- ORDER BY ORDINAL_POSITION;

    -- Cursor to loop through inactive managers (using dynamic SQL to avoid compilation issues)
    -- Note: Cursor implementation replaced with simplified approach for debugging

    -- For now, let's skip the cursor implementation and use dynamic SQL to show the data
    DECLARE @sql NVARCHAR(MAX);

    -- -- Show inactive managers found using dynamic SQL
    -- SET @sql = N'
    -- SELECT ''Inactive Managers Found:'' as Debug_Step;
    -- SELECT TOP 5
    --     MANAGER_EMPLID,
    --     MANAGER_NAME,
    --     HR_STATUS,
    --     POSITION_NBR,
    --     DEPTID,
    --     BUSINESS_UNIT
    -- FROM [stage].[UKG_EMPL_Inactive_Manager]
    -- ORDER BY MANAGER_EMPLID;';

    -- EXEC sp_executesql @sql;

    -- Simplified approach: Process first inactive manager for debugging using dynamic SQL
    DECLARE @TestEMPLID VARCHAR(11);
    DECLARE @TestManagerName VARCHAR(100);

    SET @sql = N'
    SELECT TOP 1
        @TestEMPLID_OUT = MANAGER_EMPLID,
        @TestManagerName_OUT = MANAGER_NAME
    FROM [stage].[UKG_EMPL_Inactive_Manager]
    ORDER BY MANAGER_EMPLID;';

    EXEC sp_executesql @sql, 
        N'@TestEMPLID_OUT VARCHAR(11) OUTPUT, @TestManagerName_OUT VARCHAR(100) OUTPUT',
        @TestEMPLID_OUT = @TestEMPLID OUTPUT,
        @TestManagerName_OUT = @TestManagerName OUTPUT;

    IF @TestEMPLID IS NOT NULL
    BEGIN
        PRINT 'Processing Test Manager: ' + @TestEMPLID + ' - ' + ISNULL(@TestManagerName, 'Unknown Name');

        SELECT 'Step 2: Employee ' + @TestEMPLID + ' hierarchy details' as Debug_Step;
        SELECT *
        FROM #HierarchyPositions
        WHERE emplid = @TestEMPLID;

        -- Step 3: Create manager hierarchy staging table (iterative approach)
        IF OBJECT_ID('tempdb..#ManagerHierarchy') IS NOT NULL DROP TABLE #ManagerHierarchy;

        CREATE TABLE #ManagerHierarchy
        (
            MANAGER_EMPLID VARCHAR(11),
            MANAGER_NAME VARCHAR(50),
            HR_STATUS VARCHAR(1),
            NEXT_MANAGER_EMPLID VARCHAR(11),
            LEVEL_UP INT
        );

        -- Insert level 1 managers (inactive managers from our main query)
        INSERT INTO #ManagerHierarchy
        SELECT DISTINCT
            hp.MANAGER_EMPLID,
            hp.MANAGER_NAME,
            hp.MANAGER_HR_STATUS,
            NULL as NEXT_MANAGER_EMPLID, -- Simplified: Set to NULL for now
            1 as LEVEL_UP
        FROM #HierarchyPositions hp;

        -- Debug Level 1 insertions
        SELECT 'Level 1: Manager of employee ' + @TestEMPLID as Debug_Step;
        SELECT mh.*
        FROM #ManagerHierarchy mh
            INNER JOIN #HierarchyPositions hp ON mh.MANAGER_EMPLID = hp.MANAGER_EMPLID
        WHERE hp.emplid = @TestEMPLID AND mh.LEVEL_UP = 1;
    END
    ELSE
    BEGIN
        PRINT 'No inactive managers found to process.';
    END

    -- Clean up temp tables
    IF OBJECT_ID('tempdb..#HierarchyPositions') IS NOT NULL DROP TABLE #HierarchyPositions;
    IF OBJECT_ID('tempdb..#ManagerHierarchy') IS NOT NULL DROP TABLE #ManagerHierarchy;

    PRINT 'Inactive manager processing completed.';




END
GO
