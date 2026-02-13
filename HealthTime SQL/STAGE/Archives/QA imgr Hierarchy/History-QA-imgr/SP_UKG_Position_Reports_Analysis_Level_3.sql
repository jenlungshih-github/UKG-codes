USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_Position_Reports_Analysis_Level_3]    Script Date: 8/30/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [stage].[SP_UKG_Position_Reports_Analysis_Level_3]
AS
-- exec [stage].[SP_UKG_Position_Reports_Analysis_Level_3]
/***************************************
* Created By: Jim Shih	
* Purpose: Analyze position reports data for Level 3 using results from Level 2 (UKG_PositionReportsAnalysis_Level_UP_TEMP)
* Table: Processes data from [stage].[UKG_PositionReportsAnalysis_Level_UP_TEMP] and analyzes position hierarchy for Level 3
* -- 08/30/2025 Jim Shih: Created for Level 3 analysis based on Level 2 results
******************************************/
BEGIN
    SET NOCOUNT ON;

    -- Create temp table to store Level 3 results
    IF OBJECT_ID('[stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]', 'U') IS NOT NULL DROP TABLE [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP];

    CREATE TABLE [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]
    (
        Inactive_EMPLID VARCHAR(11),
        Inactive_EMPLID_POSITION_NBR VARCHAR(20),
        MANAGER_EMPLID VARCHAR(11),
        MANAGER_NAME VARCHAR(100),
        POSITION_REPORTS_TO VARCHAR(20),
        POSN_STATUS VARCHAR(1),
        POSITION_DEPTID VARCHAR(10),
        POSITION_EFFDT DATE,
        PS_JOB_EMPLID VARCHAR(11),
        PS_JOB_HR_STATUS VARCHAR(1),
        NOTE VARCHAR(255),
        PROCESSED_DT DATETIME DEFAULT GETDATE()
    );

    -- Declare cursor variables
    DECLARE @Inactive_EMPLID VARCHAR(11);
    DECLARE @Inactive_EMPLID_POSITION_NBR VARCHAR(20);
    DECLARE @MANAGER_EMPLID VARCHAR(11);
    DECLARE @MANAGER_NAME VARCHAR(100);
    DECLARE @POSITION_REPORTS_TO VARCHAR(20);
    DECLARE @POSN_STATUS VARCHAR(1);
    DECLARE @POSITION_DEPTID VARCHAR(10);
    DECLARE @POSITION_EFFDT DATE;
    DECLARE @PS_JOB_EMPLID VARCHAR(11);
    DECLARE @PS_JOB_HR_STATUS VARCHAR(1);
    DECLARE @NOTE VARCHAR(255);
    DECLARE @RecordCount INT = 0;
    DECLARE @PSJobExists INT;

    -- Debug: Check how many records we're starting with from Level 2
    PRINT 'Debug: Starting Level 3 analysis with records from UKG_PositionReportsAnalysis_Level_UP_TEMP where PS_JOB_EMPLID is not null';
    SELECT @RecordCount = COUNT(*)
    FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_Level_UP_TEMP]
    WHERE [PS_JOB_EMPLID] IS NOT NULL;
    PRINT 'Debug: Found ' + CAST(@RecordCount AS VARCHAR(10)) + ' records in Level 2 source table with PS_JOB_EMPLID';

    -- Debug: List all PS_JOB_EMPLID values from Level 2
    PRINT 'Debug: PS_JOB_EMPLID values from Level 2:';
    DECLARE @DebugEMPLID VARCHAR(11);
    DECLARE debug_cursor CURSOR FOR
    SELECT DISTINCT PS_JOB_EMPLID
    FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_Level_UP_TEMP]
    WHERE PS_JOB_EMPLID IS NOT NULL
    ORDER BY PS_JOB_EMPLID;

    OPEN debug_cursor;
    FETCH NEXT FROM debug_cursor INTO @DebugEMPLID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '  - PS_JOB_EMPLID: ' + @DebugEMPLID;
        FETCH NEXT FROM debug_cursor INTO @DebugEMPLID;
    END
    CLOSE debug_cursor;
    DEALLOCATE debug_cursor;

    -- Reset record count for actual processing
    SET @RecordCount = 0;

    -- Declare cursor to loop through Level 2 results and find their position reports
    DECLARE position_reports_cursor CURSOR FOR
    WITH
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        )
    SELECT DISTINCT
        temp.[PS_JOB_EMPLID] as Inactive_EMPLID,
        empl.[POSITION_REPORTS_TO] as Inactive_EMPLID_POSITION_NBR,
        NULL as MANAGER_EMPLID,
        NULL as MANAGER_NAME,
        empl.[POSITION_REPORTS_TO] as POSITION_REPORTS_TO,
        pd.POSN_STATUS,
        pd.deptid as POSITION_DEPTID,
        pd.EFFDT as POSITION_EFFDT
    FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_Level_UP_TEMP] temp
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        ON empl.emplid = temp.[PS_JOB_EMPLID]
        LEFT JOIN PositionData pd
        ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
            AND pd.RN = 1
    WHERE temp.[PS_JOB_EMPLID] IS NOT NULL
        AND empl.[POSITION_REPORTS_TO] IS NOT NULL
    ORDER BY temp.[PS_JOB_EMPLID];

    -- Open cursor and begin processing
    OPEN position_reports_cursor;

    FETCH NEXT FROM position_reports_cursor 
    INTO @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @MANAGER_EMPLID, @MANAGER_NAME, 
         @POSITION_REPORTS_TO, @POSN_STATUS, @POSITION_DEPTID, @POSITION_EFFDT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RecordCount = @RecordCount + 1;

        -- Process each Level 3 position reports record
        PRINT 'Processing Level 3 Record ' + CAST(@RecordCount AS VARCHAR(10)) + 
              ': Employee ' + ISNULL(@Inactive_EMPLID, 'NULL') + 
              ' - Position Reports To: ' + ISNULL(@POSITION_REPORTS_TO, 'NULL');

        -- Insert record into temp table for Level 3 analysis (using dynamic SQL)
        DECLARE @InsertSQL NVARCHAR(MAX);
        SET @InsertSQL = N'
        INSERT INTO [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]
            (
            Inactive_EMPLID,
            Inactive_EMPLID_POSITION_NBR,
            MANAGER_EMPLID,
            MANAGER_NAME,
            POSITION_REPORTS_TO,
            POSN_STATUS,
            POSITION_DEPTID,
            POSITION_EFFDT,
            PS_JOB_EMPLID,
            PS_JOB_HR_STATUS,
            NOTE
            )
        VALUES
            (
                @Inactive_EMPLID,
                @Inactive_EMPLID_POSITION_NBR,
                @MANAGER_EMPLID,
                @MANAGER_NAME,
                @POSITION_REPORTS_TO,
                @POSN_STATUS,
                @POSITION_DEPTID,
                @POSITION_EFFDT,
                NULL,
                NULL,
                ''''
        )';

        EXEC sp_executesql @InsertSQL, 
            N'@Inactive_EMPLID VARCHAR(11), @Inactive_EMPLID_POSITION_NBR VARCHAR(20), @MANAGER_EMPLID VARCHAR(11), @MANAGER_NAME VARCHAR(100), @POSITION_REPORTS_TO VARCHAR(20), @POSN_STATUS VARCHAR(1), @POSITION_DEPTID VARCHAR(10), @POSITION_EFFDT DATE',
            @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @MANAGER_EMPLID, @MANAGER_NAME, @POSITION_REPORTS_TO, @POSN_STATUS, @POSITION_DEPTID, @POSITION_EFFDT;

        -- Initialize PS_JOB fields
        SET @PS_JOB_EMPLID = NULL;
        SET @PS_JOB_HR_STATUS = NULL;
        SET @NOTE = '';

        -- Additional processing for each POSITION_REPORTS_TO
        IF @POSITION_REPORTS_TO IS NOT NULL
        BEGIN
            PRINT '  - Analyzing Level 3 Position: ' + @POSITION_REPORTS_TO + 
                  ' Status: ' + ISNULL(@POSN_STATUS, 'Unknown') +
                  ' Dept: ' + ISNULL(@POSITION_DEPTID, 'Unknown');

            -- Check if position exists in PS_JOB with ROW_NO = 1 and get EMPLID and HR_STATUS
            SET @PSJobExists = 0;

            SELECT
                @PSJobExists = COUNT(*),
                @PS_JOB_EMPLID = MAX(EMPLID),
                @PS_JOB_HR_STATUS = MAX(HR_STATUS)
            FROM (
                SELECT
                    J.POSITION_NBR,
                    J.EMPLID,
                    J.HR_STATUS,
                    J.EMPL_RCD,
                    J.DEPTID,
                    J.BUSINESS_UNIT,
                    J.LOCATION,
                    J.JOB_INDICATOR,
                    J.FTE,
                    J.UNION_CD,
                    J.JOBCODE,
                    J.EFFDT,
                    J.DML_IND,
                    ROW_NUMBER() OVER(PARTITION BY J.EMPLID ORDER BY (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), J.EFFDT DESC) as ROW_NO
                FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
                WHERE 
                    J.POSITION_NBR = @POSITION_REPORTS_TO
                    AND J.DML_IND <> 'D'
                    AND J.EMPLID IS NOT NULL
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
            ) PS_JOB_DATA
            WHERE ROW_NO = 1;

            IF @PSJobExists = 0
            BEGIN
                SET @NOTE = 'missing in PS_JOB';
                PRINT '    - WARNING: Level 3 Position ' + @POSITION_REPORTS_TO + ' missing in PS_JOB';
            END
            ELSE
            BEGIN
                SET @NOTE = 'found in PS_JOB - EMPLID: ' + ISNULL(@PS_JOB_EMPLID, 'NULL') + ', HR_STATUS: ' + ISNULL(@PS_JOB_HR_STATUS, 'NULL');
                PRINT '    - OK: Level 3 Position ' + @POSITION_REPORTS_TO + ' found in PS_JOB - EMPLID: ' + ISNULL(@PS_JOB_EMPLID, 'NULL') + ', HR_STATUS: ' + ISNULL(@PS_JOB_HR_STATUS, 'NULL');
            END
        END
        ELSE
        BEGIN
            SET @NOTE = 'No POSITION_REPORTS_TO found';
            PRINT '  - WARNING: No POSITION_REPORTS_TO found for this Level 3 employee';
        END

        -- Update the NOTE field and PS_JOB fields for the record just inserted (using dynamic SQL)
        DECLARE @UpdateSQL NVARCHAR(MAX);
        SET @UpdateSQL = N'
        UPDATE [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]
        SET NOTE = @NOTE,
            PS_JOB_EMPLID = @PS_JOB_EMPLID,
            PS_JOB_HR_STATUS = @PS_JOB_HR_STATUS
        WHERE Inactive_EMPLID = @Inactive_EMPLID
            AND Inactive_EMPLID_POSITION_NBR = @Inactive_EMPLID_POSITION_NBR
            AND ISNULL(POSITION_REPORTS_TO, '''') = ISNULL(@POSITION_REPORTS_TO, '''')';

        EXEC sp_executesql @UpdateSQL,
            N'@NOTE VARCHAR(255), @PS_JOB_EMPLID VARCHAR(11), @PS_JOB_HR_STATUS VARCHAR(1), @Inactive_EMPLID VARCHAR(11), @Inactive_EMPLID_POSITION_NBR VARCHAR(20), @POSITION_REPORTS_TO VARCHAR(20)',
            @NOTE, @PS_JOB_EMPLID, @PS_JOB_HR_STATUS, @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @POSITION_REPORTS_TO;

        -- Fetch next record
        FETCH NEXT FROM position_reports_cursor 
        INTO @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @MANAGER_EMPLID, @MANAGER_NAME, 
             @POSITION_REPORTS_TO, @POSN_STATUS, @POSITION_DEPTID, @POSITION_EFFDT;
    END

    -- Clean up cursor
    CLOSE position_reports_cursor;
    DEALLOCATE position_reports_cursor;

    -- Display summary results
    PRINT 'Level 3 Cursor processing completed. Total records processed: ' + CAST(@RecordCount AS VARCHAR(10));

    SELECT 'Position Reports Analysis Level 3 Summary' as Summary_Step;
    SELECT
        COUNT(*) as Total_Records,
        COUNT(POSITION_REPORTS_TO) as Records_With_Position_Reports,
        COUNT(*) - COUNT(POSITION_REPORTS_TO) as Records_Without_Position_Reports,
        COUNT(DISTINCT POSITION_REPORTS_TO) as Unique_Positions,
        COUNT(PS_JOB_EMPLID) as Records_With_PS_JOB_EMPLID
    FROM [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP];

    SELECT 'Level 3 PS_JOB_EMPLID List' as PS_JOB_EMPLID_Step;
    SELECT DISTINCT
        PS_JOB_EMPLID,
        PS_JOB_HR_STATUS,
        COUNT(*) as Count
    FROM [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]
    WHERE PS_JOB_EMPLID IS NOT NULL
    GROUP BY PS_JOB_EMPLID, PS_JOB_HR_STATUS
    ORDER BY PS_JOB_EMPLID;

    SELECT 'All Processed Level 3 Records' as Records_Step;
    SELECT *
    FROM [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP]
    ORDER BY Inactive_EMPLID;

    -- Insert Level 3 results into the level by level tracking table with LEVEL UP = 3
    INSERT INTO [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
        (
        Inactive_EMPLID,
        Inactive_EMPLID_POSITION_NBR,
        MANAGER_EMPLID,
        MANAGER_NAME,
        POSITION_REPORTS_TO,
        POSN_STATUS,
        POSITION_DEPTID,
        POSITION_EFFDT,
        PS_JOB_EMPLID,
        PS_JOB_HR_STATUS,
        NOTE,
        PROCESSED_DT,
        [LEVEL UP]
        )
    SELECT
        Inactive_EMPLID,
        Inactive_EMPLID_POSITION_NBR,
        MANAGER_EMPLID,
        MANAGER_NAME,
        POSITION_REPORTS_TO,
        POSN_STATUS,
        POSITION_DEPTID,
        POSITION_EFFDT,
        PS_JOB_EMPLID,
        PS_JOB_HR_STATUS,
        NOTE,
        PROCESSED_DT,
        3 as [LEVEL UP]
    FROM [stage].[UKG_PositionReportsAnalysis_Level_3_TEMP];

    PRINT 'SP_UKG_Position_Reports_Analysis_Level_3 completed successfully.';

END
GO
