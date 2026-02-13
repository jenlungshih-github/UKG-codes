USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD]    Script Date: 9/1/2025 7:23:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [stage].[SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD]
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
                empl.[Last Name] + ', ' + empl.[First Name] AS empl_NAME,
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
                JOIN [dbo].[UKG_EMPLOYEE_DATA] empl -- [dbo].[UKG_EMPLOYEE_DATA] empl
                ON J.POSITION_NBR = empl.REPORTS_TO
            WHERE J.DML_IND <> 'D'
                AND J.HR_STATUS = 'I' -- [dbo].[UKG_EMPLOYEE_DATA] empl has reports-to BUT HR_STATUS = 'I'
                AND J.EFFDT = (
                SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
            )
                AND J.EFFSEQ = (
                SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
            )
        )
    SELECT
        POSITION_NBR,
        EMPLID as Inactive_EMPLID,
        empl_NAME,
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
    -- -- [dbo].[UKG_EMPLOYEE_DATA] empl has reports-to BUT HR_STATUS = 'I'.  Create a table [stage].[UKG_EMPL_Inactive_Manager].
    FROM RankedJobs
    WHERE ROW_NO = 1
    --        AND JOB_INDICATOR IN ('P', 'N');

    PRINT 'Table [stage].[UKG_EMPL_Inactive_Manager] has been successfully created.';

    -- Create temp table for hierarchy positions analysis
    IF OBJECT_ID('Stage.UKG_ManagerHierarchy_TEMP') IS NOT NULL DROP TABLE Stage.UKG_ManagerHierarchy_TEMP;

    CREATE TABLE Stage.UKG_ManagerHierarchy_TEMP
    (
        Inactive_EMPLID VARCHAR(11),
        Inactive_EMPLID_POSITION_NBR VARCHAR(20),
        MANAGER_EMPLID VARCHAR(11),
        MANAGER_NAME VARCHAR(100),
        MANAGER_POSITION_NBR VARCHAR(20)
    );

    -- Populate hierarchy positions from [stage].[UKG_EMPL_Inactive_Manager] imgr into table Stage.UKG_ManagerHierarchy_TEMP
    INSERT INTO Stage.UKG_ManagerHierarchy_TEMP
    SELECT DISTINCT
        imgr.[Inactive_EMPLID],
        imgr.POSITION_NBR as Inactive_EMPLID_POSITION_NBR,
        empl.MANAGER_EMPLID,
        empl.MANAGER_NAME,
        empl.[POSITION_REPORTS_TO]
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] imgr
        ON empl.emplid = imgr.[Inactive_EMPLID]
            and empl.POSITION_NBR=imgr.POSITION_NBR
    --	where imgr.Inactive_EMPLID=	10470302
    ;

    -- check Stage.UKG_ManagerHierarchy_TEMP
    SELECT *
    FROM Stage.UKG_ManagerHierarchy_TEMP
    ;

    -- check Manager_Level from [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]  -- Note that there are 
    SELECT
        H.Inactive_EMPLID
, H.Inactive_EMPLID_POSITION_NBR
, H.MANAGER_POSITION_NBR
--,H.MANAGER_EMPLID
--,H.MANAGER_NAME
, EMPL.emplid
, EMPL.NAME
, EMPL.HR_STATUS
, EMPL.JOB_INDICATOR
    --,L.LEVEL as Manager_Level
    --,L.UPDATED_DT
    FROM Stage.UKG_ManagerHierarchy_TEMP H
        --LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
        --ON H.MANAGER_EMPLID=L.[emplid]
        --and H.MANAGER_POSITION_NBR=L.[POSITION_NBR]
        JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ON H.MANAGER_POSITION_NBR=EMPL.POSITION_NBR
    --and H.MANAGER_EMPLID=EMPL.EMPLID
    WHERE 
EMPL.JOB_INDICATOR='P'
    ;


    SELECT emplid, HR_STATUS, JOB_INDICATOR
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
    WHERE 
position_nbr='40692683'
    ;



    DECLARE @sql NVARCHAR(MAX);

    -- Simplified approach: Process first inactive manager for debugging using dynamic SQL
    DECLARE @TestEMPLID VARCHAR(11);
    DECLARE @TestManagerName VARCHAR(100);

    SET @sql = N'
    SELECT TOP 1
        @TestEMPLID_OUT = Inactive_EMPLID,
        @TestManagerName_OUT = MANAGER_NAME
    FROM Stage.UKG_ManagerHierarchy_TEMP
	where Inactive_EMPLID=10403801
    ORDER BY Inactive_EMPLID;';

    EXEC sp_executesql @sql, 
        N'@TestEMPLID_OUT VARCHAR(11) OUTPUT, @TestManagerName_OUT VARCHAR(100) OUTPUT',
        @TestEMPLID_OUT = @TestEMPLID OUTPUT,
        @TestManagerName_OUT = @TestManagerName OUTPUT;

    IF @TestEMPLID IS NOT NULL
    BEGIN
        PRINT 'Processing Test Manager: ' + @TestEMPLID + ' - ' + ISNULL(@TestManagerName, 'Unknown Name');

        SELECT 'Step 2: Employee ' + @TestEMPLID + ' hierarchy details' as Debug_Step;
        SELECT *
        FROM Stage.UKG_ManagerHierarchy_TEMP
        WHERE Inactive_EMPLID = @TestEMPLID;

        -- Step 3: Create manager hierarchy staging table (iterative approach)
        IF OBJECT_ID('stage.UKG_ManagerHierarchy') IS NOT NULL DROP TABLE stage.UKG_ManagerHierarchy;

        CREATE TABLE stage.UKG_ManagerHierarchy
        (
            MANAGER_EMPLID VARCHAR(11),
            MANAGER_NAME VARCHAR(50),
            POSITION_NBR VARCHAR(11),
            POSN_LEVEL VARCHAR(50),
            --            HR_STATUS VARCHAR(1),
            --            NEXT_MANAGER_EMPLID VARCHAR(11),
            NEXT_MANAGER_POSITION_NBR VARCHAR(11),
            LEVEL_UP INT
        );


        -- Insert level 1 managers (inactive managers from our main query)
        INSERT INTO stage.UKG_ManagerHierarchy
        SELECT DISTINCT
            hp.MANAGER_EMPLID,
            hp.MANAGER_NAME,
            L.POSITION_NBR,
            L.LEVEL as POSN_LEVEL,
            --    hp.MANAGER_HR_STATUS,
            m.[POSITION_REPORTS_TO] as NEXT_MANAGER_POSITION_NBR,
            1 as LEVEL_UP
        FROM Stage.UKG_ManagerHierarchy_TEMP hp
            LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] m
            ON hp.MANAGER_EMPLID = m.EMPLID
            LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
            ON hp.MANAGER_EMPLID = L.emplid
                AND hp.MANAGER_POSITION_NBR = L.POSITION_NBR
        WHERE hp.MANAGER_EMPLID IS NOT NULL
            AND L.emplid IS NOT NULL;

        -- Debug Level 1 insertions
        SELECT 'Level 1: Manager of employee ' + @TestEMPLID as Debug_Step;
        SELECT mh.*
        FROM stage.UKG_ManagerHierarchy mh
            INNER JOIN Stage.UKG_ManagerHierarchy_TEMP hp ON mh.MANAGER_EMPLID = hp.MANAGER_EMPLID
        WHERE hp.Inactive_EMPLID = @TestEMPLID AND mh.LEVEL_UP = 1;
    END
    ELSE
    BEGIN
        PRINT 'No inactive managers found to process.';
    END

    ---- Insert level 2 managers
    --INSERT INTO stage.UKG_ManagerHierarchy
    --SELECT DISTINCT
    --    m.EMPLID as MANAGER_EMPLID,
    --    m.NAME as MANAGER_NAME,
    ----    m.HR_STATUS,
    --    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    --    2 as LEVEL_UP
    --FROM stage.UKG_ManagerHierarchy mh1
    --    INNER JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] m
    --    ON mh1.NEXT_MANAGER_EMPLID = m.EMPLID
    --WHERE mh1.LEVEL_UP = 1
    --    AND mh1.NEXT_MANAGER_EMPLID IS NOT NULL
    --    AND NOT EXISTS (SELECT 1
    --    FROM stage.UKG_ManagerHierarchy mh2
    --    WHERE mh2.MANAGER_EMPLID = m.EMPLID);

    ---- Debug Level 2 insertions
    --SELECT 'Level 2: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
    --FROM stage.UKG_ManagerHierarchy
    --WHERE LEVEL_UP = 2;

    ------

    --SELECT * 
    --FROM stage.UKG_ManagerHierarchy
    --WHERE 
    --LEVEL_UP = 2
    --AND
    --MANAGER_EMPLID=10405173
    --;


    --SELECT 'Level 2: Hierarchy chain for employee 10403801' as Debug_Step;
    --SELECT mh.*
    --FROM stage.UKG_ManagerHierarchy mh
    --WHERE mh.MANAGER_EMPLID IN (
    --    SELECT mh2.NEXT_MANAGER_EMPLID
    --    FROM stage.UKG_ManagerHierarchy mh2
    --        INNER JOIN Stage.UKG_ManagerHierarchy_TEMP hp ON mh2.MANAGER_EMPLID = hp.MANAGER_EMPLID
    --    WHERE hp.emplid = '10403801' AND mh2.LEVEL_UP = 1
    --) AND mh.LEVEL_UP = 2;


    -- Clean up temp tables
    --    IF OBJECT_ID('Stage.UKG_ManagerHierarchy_TEMP') IS NOT NULL DROP TABLE Stage.UKG_ManagerHierarchy_TEMP;
    --    IF OBJECT_ID('tempdb..stage.UKG_ManagerHierarchy') IS NOT NULL DROP TABLE stage.UKG_ManagerHierarchy;

    PRINT 'Inactive manager processing completed.';




END
GO


