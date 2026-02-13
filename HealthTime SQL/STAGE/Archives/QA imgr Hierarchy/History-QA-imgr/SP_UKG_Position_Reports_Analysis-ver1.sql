USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_Position_Reports_Analysis]    Script Date: 8/29/2025 3:06:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [stage].[SP_UKG_Position_Reports_Analysis]
AS
-- exec [stage].[SP_UKG_Position_Reports_Analysis]
/***************************************
* Created By: Jim Shih	
* Purpose: Analyze position reports data for inactive managers using cursor
* Table: Processes data from [stage].[UKG_EMPL_Inactive_Manager] and analyzes position hierarchy
* -- 08/29/2025 Jim Shih: Created based on 14.sql
******************************************/
BEGIN
    SET NOCOUNT ON;

    -- Create temp table to store results
    IF OBJECT_ID('[stage].[UKG_PositionReportsAnalysis_TEMP]', 'U') IS NOT NULL DROP TABLE [stage].[UKG_PositionReportsAnalysis_TEMP];

    CREATE TABLE [stage].[UKG_PositionReportsAnalysis_TEMP]
    (
        Inactive_EMPLID VARCHAR(11),
        Inactive_EMPLID_POSITION_NBR VARCHAR(20),
        MANAGER_EMPLID VARCHAR(11),
        MANAGER_NAME VARCHAR(100),
        POSITION_REPORTS_TO VARCHAR(20),
        POSN_STATUS VARCHAR(1),
        POSITION_DEPTID VARCHAR(10),
        POSITION_EFFDT DATE,
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
    DECLARE @RecordCount INT = 0;

    -- Declare cursor to loop through position reports data
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
        imgr.[Inactive_EMPLID],
        imgr.POSITION_NBR as Inactive_EMPLID_POSITION_NBR,
        empl.MANAGER_EMPLID,
        empl.MANAGER_NAME,
        empl.[POSITION_REPORTS_TO],
        pd.POSN_STATUS,
        pd.deptid as POSITION_DEPTID,
        pd.EFFDT as POSITION_EFFDT
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] imgr
        ON empl.emplid = imgr.[Inactive_EMPLID]
            AND empl.POSITION_NBR = imgr.POSITION_NBR
        LEFT JOIN PositionData pd
        ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
            AND pd.RN = 1
    WHERE empl.MANAGER_EMPLID IS NULL
    ORDER BY imgr.[Inactive_EMPLID];

    -- Open cursor and begin processing
    OPEN position_reports_cursor;

    FETCH NEXT FROM position_reports_cursor 
    INTO @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @MANAGER_EMPLID, @MANAGER_NAME, 
         @POSITION_REPORTS_TO, @POSN_STATUS, @POSITION_DEPTID, @POSITION_EFFDT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RecordCount = @RecordCount + 1;

        -- Process each position reports record
        PRINT 'Processing Record ' + CAST(@RecordCount AS VARCHAR(10)) + 
              ': Inactive Employee ' + ISNULL(@Inactive_EMPLID, 'NULL') + 
              ' - Position Reports To: ' + ISNULL(@POSITION_REPORTS_TO, 'NULL');

        -- Insert record into temp table for analysis
        INSERT INTO [stage].[UKG_PositionReportsAnalysis_TEMP]
            (
            Inactive_EMPLID,
            Inactive_EMPLID_POSITION_NBR,
            MANAGER_EMPLID,
            MANAGER_NAME,
            POSITION_REPORTS_TO,
            POSN_STATUS,
            POSITION_DEPTID,
            POSITION_EFFDT
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
                @POSITION_EFFDT
        );

        -- Additional processing for each POSITION_REPORTS_TO
        IF @POSITION_REPORTS_TO IS NOT NULL
        BEGIN
            PRINT '  - Analyzing Position: ' + @POSITION_REPORTS_TO + 
                  ' Status: ' + ISNULL(@POSN_STATUS, 'Unknown') +
                  ' Dept: ' + ISNULL(@POSITION_DEPTID, 'Unknown');

        -- You can add additional logic here to process each position
        -- For example: check position hierarchy, validate department mappings, etc.
        END
        ELSE
        BEGIN
            PRINT '  - WARNING: No POSITION_REPORTS_TO found for this employee';
        END

        -- Fetch next record
        FETCH NEXT FROM position_reports_cursor 
        INTO @Inactive_EMPLID, @Inactive_EMPLID_POSITION_NBR, @MANAGER_EMPLID, @MANAGER_NAME, 
             @POSITION_REPORTS_TO, @POSN_STATUS, @POSITION_DEPTID, @POSITION_EFFDT;
    END

    -- Clean up cursor
    CLOSE position_reports_cursor;
    DEALLOCATE position_reports_cursor;

    -- Display summary results
    PRINT 'Cursor processing completed. Total records processed: ' + CAST(@RecordCount AS VARCHAR(10));

    SELECT 'Position Reports Analysis Summary' as Summary_Step;
    SELECT
        COUNT(*) as Total_Records,
        COUNT(POSITION_REPORTS_TO) as Records_With_Position_Reports,
        COUNT(*) - COUNT(POSITION_REPORTS_TO) as Records_Without_Position_Reports,
        COUNT(DISTINCT POSITION_REPORTS_TO) as Unique_Positions
    FROM [stage].[UKG_PositionReportsAnalysis_TEMP];

    SELECT 'Position Status Distribution' as Distribution_Step;
    SELECT
        ISNULL(POSN_STATUS, 'NULL') as Position_Status,
        COUNT(*) as Count
    FROM [stage].[UKG_PositionReportsAnalysis_TEMP]
    GROUP BY POSN_STATUS
    ORDER BY COUNT(*) DESC;

    SELECT 'All Processed Records' as Records_Step;
    SELECT *
    FROM [stage].[UKG_PositionReportsAnalysis_TEMP]
    ORDER BY Inactive_EMPLID;

    -- Clean up temp table
--    IF OBJECT_ID('[stage].[UKG_PositionReportsAnalysis_TEMP]', 'U') IS NOT NULL DROP TABLE [stage].[UKG_PositionReportsAnalysis_TEMP];

    PRINT 'SP_UKG_Position_Reports_Analysis completed successfully.';

END
GO


