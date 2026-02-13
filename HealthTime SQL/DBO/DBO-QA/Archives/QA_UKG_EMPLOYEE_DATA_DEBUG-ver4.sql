USE [HealthTime]
GO

DECLARE @EMPLID VARCHAR(11) = '10359068';
PRINT '=== QA DEBUG FOR EMPLID: ' + @EMPLID + ' ===';
PRINT '';

-- Step 1: Check if employee exists in base data
PRINT '1. Checking if employee exists in CURRENT_EMPL_DATA...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = @EMPLID)
    BEGIN
    PRINT '   ? Employee found in CURRENT_EMPL_DATA';


    SELECT
        EMPL.EMPLID, EMPL.JOB_INDICATOR, EMPL.VC_CODE, EMPL.DEPTID, EMPL.hr_status, EMPL.effdt,
        EMPL.PAY_FREQUENCY, EMPL.EMPL_TYPE, EMPL.JOBCODE, EMPL.position_nbr, POS.business_unit
    FROM health_ods.[health_ods]
.[RPT].CURRENT_EMPL_DATA EMPL
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_POSITION] POS ON EMPL.position_nbr = POS.position_nbr
    WHERE EMPL.EMPLID = @EMPLID;
END
    ELSE
    BEGIN
    PRINT '   ? Employee NOT found in CURRENT_EMPL_DATA';
    RETURN;
END

PRINT '';

-- Step 1b: Check if employee is a manager
PRINT '1b. Checking if employee is a manager...';
SELECT
    EMPL.EMPLID,
    CASE WHEN M.MANAGER_EMPLID IS NOT NULL THEN 'T' ELSE 'F' END AS 'Manager Flag',
    M.MANAGER_EMPLID,
    M.MANAGER_POSITION_NBR,
    M.MANAGER_HR_STATUS
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
    LEFT OUTER JOIN health_ods.[health_ods].[RPT].CURRENT_EMPL_REPORTS_TO M
    ON M.MANAGER_HR_STATUS = 'A'
        AND M.MANAGER_EMPLID = EMPL.EMPLID
        AND M.MANAGER_POSITION_NBR = EMPL.POSITION_NBR
WHERE EMPL.EMPLID = @EMPLID;

IF EXISTS (
    SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
    LEFT OUTER JOIN health_ods.[health_ods].[RPT].CURRENT_EMPL_REPORTS_TO M
    ON M.MANAGER_HR_STATUS = 'A'
        AND M.MANAGER_EMPLID = EMPL.EMPLID
        AND M.MANAGER_POSITION_NBR = EMPL.POSITION_NBR
WHERE EMPL.EMPLID = @EMPLID
    AND M.MANAGER_EMPLID IS NOT NULL
)
    BEGIN
    PRINT '   ✓ Employee IS a manager (Manager Flag = T)';
END
    ELSE
    BEGIN
    PRINT '   ✓ Employee is NOT a manager (Manager Flag = F)';
END

PRINT '';

-- Step 2: Check BYA exclusion
PRINT '2. Checking BYA exclusion (CTE_exclude_BYA)...';
IF EXISTS (
        SELECT 1
FROM health_ods.[health_ods].[stable].PS_JOB H
WHERE H.emplid = @EMPLID
    AND H.JOB_INDICATOR = 'P'
    AND H.DML_IND <> 'D'
    AND H.SAL_ADMIN_PLAN = 'BYA'
    )
    BEGIN
    PRINT '   ? Employee EXCLUDED due to SAL_ADMIN_PLAN = BYA';

    SELECT H.emplid, H.SAL_ADMIN_PLAN, H.FLSA_STATUS, H.JOB_INDICATOR, H.DML_IND, H.EFFDT
    FROM health_ods.[health_ods].[stable].PS_JOB H
    WHERE H.emplid = @EMPLID
        AND H.JOB_INDICATOR = 'P'
        AND H.DML_IND <> 'D'
        AND H.SAL_ADMIN_PLAN = 'BYA';
    RETURN;
END
    ELSE
    BEGIN
    PRINT '   ? Employee NOT excluded by BYA filter';
END

PRINT '';

-- Step 3: Check primary job criteria
PRINT '3. Checking primary job criteria...';
DECLARE @JobIndicator VARCHAR(1), @VcCode VARCHAR(10), @DeptId VARCHAR(10), @HrStatus VARCHAR(1), 
            @EffDt DATE, @PayFreq VARCHAR(1), @EmplType VARCHAR(1), @JobCode VARCHAR(10);

SELECT @JobIndicator = JOB_INDICATOR, @VcCode = VC_CODE, @DeptId = DEPTID,
    @HrStatus = hr_status, @EffDt = effdt, @PayFreq = PAY_FREQUENCY,
    @EmplType = EMPL_TYPE, @JobCode = JOBCODE
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = @EMPLID;

-- Check each condition
IF @JobIndicator <> 'P'
    BEGIN
    PRINT '   ? JOB_INDICATOR is not P (Primary). Current value: ' + ISNULL(@JobIndicator, 'NULL');
    RETURN;
END
    ELSE PRINT '   ? JOB_INDICATOR = P (Primary)';

IF @VcCode <> 'VCHSH' AND NOT (@DeptId BETWEEN '002000' AND '002999' AND @DeptId NOT IN ('002230','002231','002280'))
    BEGIN
    PRINT '   ? VC_CODE/DEPTID criteria not met.';
    PRINT '     Valid criteria:';
    PRINT '     - VC_CODE must be VCHSH (Medical Center)';
    PRINT '     OR';
    PRINT '     - DEPTID must be between 002000 and 002999 (PHSO range)';
    PRINT '       AND DEPTID not in (002230, 002231, 002280)';
    PRINT '     Current values: VC_CODE = ' + ISNULL(@VcCode, 'NULL') + ', DEPTID = ' + ISNULL(@DeptId, 'NULL');
    RETURN;
END
    ELSE 
    BEGIN
    PRINT '   ? VC_CODE/DEPTID criteria met';
    IF @VcCode = 'VCHSH'
            PRINT '     - Employee is in Medical Center (VC_CODE = VCHSH)';
        ELSE
            PRINT '     - Employee is in PHSO range (DEPTID between 002000-002999, excluding 002230,002231,002280)';
END

IF NOT ((@HrStatus = 'A') OR (@HrStatus = 'I' AND CONVERT(DATE, @EffDt) = CONVERT(DATE, GETDATE())))
    BEGIN
    PRINT '   ? HR_STATUS criteria not met. HR_STATUS: ' + ISNULL(@HrStatus, 'NULL') + ', EFFDT: ' + ISNULL(CONVERT(VARCHAR, @EffDt), 'NULL');
    RETURN;
END
    ELSE PRINT '   ? HR_STATUS criteria met';

IF @PayFreq <> 'B'
    BEGIN
    PRINT '   ? PAY_FREQUENCY is not B (Biweekly). Current value: ' + ISNULL(@PayFreq, 'NULL');
    RETURN;
END
    ELSE PRINT '   ? PAY_FREQUENCY = B (Biweekly)';

IF @EmplType <> 'H'
    BEGIN
    PRINT '   ? EMPL_TYPE is not H (Hourly). Current value: ' + ISNULL(@EmplType, 'NULL');
    RETURN;
END
    ELSE PRINT '   ? EMPL_TYPE = H (Hourly)';

IF (@DeptId IN ('002053','002056','003919') AND @JobCode IN ('000770','000771','000772','000775','000776'))
    BEGIN
    PRINT '   ? Employee excluded due to ARC MSP population criteria. DEPTID: ' + @DeptId + ', JOBCODE: ' + @JobCode;
    RETURN;
END
    ELSE PRINT '   ? Not excluded by ARC MSP population criteria';

PRINT '';

-- Step 4: Check if in UKG_EMPL_E_T
PRINT '4. Checking if employee would be in STAGE.UKG_EMPL_E_T...';
PRINT '   ? Employee meets all UKG_EMPL_E_T criteria';

PRINT '';

-- Step 5: Check final query joins and conditions
PRINT '5. Checking final query table joins...';

-- Check if employee has business structure data
SELECT
    EMPL.EMPLID,
    FIN.POSITION_NBR,
    FIN.FDM_COMBO_CD,
    UKG_BS.COMBOCODE,
    UKG_BS.Organization,
    UKG_BS.EntityTitle,
    UKG_BS.ServiceLineTitle,
    UKG_BS.FinancialUnit,
    UKG_BS.FundGroup
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
    LEFT OUTER JOIN health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
    ON EMPL.POSITION_NBR = FIN.POSITION_NBR
    LEFT OUTER JOIN [hts].[UKG_BusinessStructure] UKG_BS
    ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
WHERE EMPL.EMPLID = @EMPLID;

PRINT '';
PRINT '=== DEBUG COMPLETE ===';
PRINT 'If employee meets all criteria above, check for data timing issues or recent changes.';


GO


