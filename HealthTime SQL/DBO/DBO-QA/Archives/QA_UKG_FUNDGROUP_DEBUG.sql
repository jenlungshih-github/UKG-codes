USE [HealthTime]
GO

CREATE PROCEDURE [dbo].[QA_UKG_FUNDGROUP_DEBUG]
    @EMPLID VARCHAR(11) = '10420386'
AS
/***************************************
* Created By: Jim Shih	
* Purpose: QA stored procedure to debug UKG_BS.FundGroup value for specific employee
* Usage: EXEC [dbo].[QA_UKG_FUNDGROUP_DEBUG] '10420386'
* -- 08/26/2025 Jim Shih: Created to debug FundGroup lookup logic
******************************************/
BEGIN
    SET NOCOUNT ON;

    PRINT '=== QA FUNDGROUP DEBUG FOR EMPLID: ' + @EMPLID + ' ===';
    PRINT '';

    -- Step 1: Check if employee exists in UKG_EMPL_T equivalent
    PRINT '1. Checking employee basic data...';
    IF NOT EXISTS (SELECT 1
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
    WHERE EMPLID = @EMPLID)
    BEGIN
        PRINT '   ✗ Employee NOT found in CURRENT_EMPL_DATA';
        RETURN;
    END

    SELECT
        EMPLID, POSITION_NBR, DEPTID, VC_CODE, hr_status, JOBCODE, JOB_INDICATOR
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
    WHERE EMPLID = @EMPLID;

    PRINT '';

    -- Step 2: Check POSITION_NBR and FDM_COMBO_CD lookup
    PRINT '2. Checking POSITION financial unit lookup...';

    DECLARE @POSITION_NBR VARCHAR(20);
    SELECT @POSITION_NBR = POSITION_NBR
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
    WHERE EMPLID = @EMPLID AND JOB_INDICATOR = 'P';

    IF @POSITION_NBR IS NULL
    BEGIN
        PRINT '   ✗ No primary position found for employee';
        RETURN;
    END

    PRINT '   Position Number: ' + @POSITION_NBR;

    -- Show all financial unit records for this position
    SELECT
        POSITION_NBR,
        POSN_SEQ,
        FDM_COMBO_CD,
        JOBCODE
    FROM health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
    WHERE POSITION_NBR = @POSITION_NBR
    ORDER BY POSN_SEQ;

    PRINT '';

    -- Step 3: Check MIN_POSN_SEQ logic (mimicking STAGE.UKG_COMBOCD_T)
    PRINT '3. Checking MIN_POSN_SEQ selection logic...';

    DECLARE @MIN_POSN_SEQ INT, @SELECTED_COMBO_CD VARCHAR(20);

    SELECT
        @MIN_POSN_SEQ = MIN(FIN.POSN_SEQ),
        @SELECTED_COMBO_CD = MIN(FIN.FDM_COMBO_CD)
    -- MIN in case of ties
    FROM health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN,
        [hts].[UKG_BusinessStructure] UKG_BS
    WHERE UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
        AND FIN.POSITION_NBR = @POSITION_NBR;

    IF @MIN_POSN_SEQ IS NULL
    BEGIN
        PRINT '   ✗ No valid COMBO_CD found in UKG_BusinessStructure for this position';

        -- Show what COMBO_CDs exist for this position that are NOT in UKG_BusinessStructure
        SELECT DISTINCT
            'Missing COMBO_CD:' as Status,
            FIN.FDM_COMBO_CD
        FROM health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        WHERE FIN.POSITION_NBR = @POSITION_NBR
            AND FIN.FDM_COMBO_CD NOT IN (SELECT COMBOCODE
            FROM [hts].[UKG_BusinessStructure]);
        RETURN;
    END

    PRINT '   Selected MIN_POSN_SEQ: ' + CAST(@MIN_POSN_SEQ AS VARCHAR);
    PRINT '   Selected FDM_COMBO_CD: ' + @SELECTED_COMBO_CD;

    PRINT '';

    -- Step 4: Show the UKG_BusinessStructure record
    PRINT '4. Checking UKG_BusinessStructure lookup...';

    SELECT
        COMBOCODE,
        Organization,
        EntityTitle,
        ServiceLineTitle,
        FinancialUnit,
        FundGroup
    FROM [hts].[UKG_BusinessStructure]
    WHERE COMBOCODE = @SELECTED_COMBO_CD;

    PRINT '';

    -- Step 5: Show the final join result as it would appear in the main query
    PRINT '5. Final join result (as in main UKG_EMPLOYEE_DATA query)...';

    SELECT
        EMPL.EMPLID,
        EMPL.POSITION_NBR,
        FIN.POSN_SEQ,
        FIN.FDM_COMBO_CD,
        UKG_BS.COMBOCODE,
        UKG_BS.FundGroup,
        UKG_BS.Organization,
        UKG_BS.EntityTitle,
        UKG_BS.ServiceLineTitle,
        UKG_BS.FinancialUnit,
        'Fund Group Value: [' + ISNULL(UKG_BS.FundGroup, 'NULL') + ']' AS FundGroupStatus
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
        LEFT OUTER JOIN health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        ON EMPL.POSITION_NBR = FIN.POSITION_NBR
            AND FIN.POSN_SEQ = @MIN_POSN_SEQ -- Using the calculated MIN_POSN_SEQ
        LEFT OUTER JOIN [hts].[UKG_BusinessStructure] UKG_BS
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
    WHERE EMPL.EMPLID = @EMPLID
        AND EMPL.JOB_INDICATOR = 'P';

    PRINT '';

    -- Step 6: Check for any issues with the business structure data
    PRINT '6. Checking for potential data issues...';

    -- Check if FundGroup is empty/null
    IF EXISTS (
        SELECT 1
    FROM [hts].[UKG_BusinessStructure]
    WHERE COMBOCODE = @SELECTED_COMBO_CD
        AND (FundGroup IS NULL OR FundGroup = '' OR LTRIM(RTRIM(FundGroup)) = '')
    )
    BEGIN
        PRINT '   ⚠ WARNING: FundGroup is NULL or empty for this COMBO_CD';
    END
    ELSE
    BEGIN
        PRINT '   ✓ FundGroup has a value for this COMBO_CD';
    END

    -- Check if there are multiple active records
    DECLARE @RecordCount INT;
    SELECT @RecordCount = COUNT(*)
    FROM [hts].[UKG_BusinessStructure]
    WHERE COMBOCODE = @SELECTED_COMBO_CD;

    IF @RecordCount > 1
    BEGIN
        PRINT '   ⚠ WARNING: Multiple records found for COMBO_CD: ' + @SELECTED_COMBO_CD;
        PRINT '   Showing all records:';

        SELECT COMBOCODE, FundGroup
        FROM [hts].[UKG_BusinessStructure]
        WHERE COMBOCODE = @SELECTED_COMBO_CD;
    END

    PRINT '';
    PRINT '=== FUNDGROUP DEBUG COMPLETE ===';

END
GO
