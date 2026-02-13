USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD]    Script Date: 9/15/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************
* Created By: Jim Shih
* Procedure: dbo.SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD
* Purpose: Creates table [stage].[UKG_EMPLOYEE_DATA_TERMINATED] for terminated employees to upload to UKG
* EXEC [stage].[SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD]
* -- 09/15/2025 Jim Shih: Created procedure for terminated employee data
******************************************/

CREATE or Alter PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD]
AS
BEGIN
    SET NOCOUNT ON;

    -- Drop table if exists
    DROP TABLE IF EXISTS [stage].[UKG_EMPLOYEE_DATA_TERMINATED];

    -- Create terminated employee data table
    SELECT DISTINCT
        EMPL.DEPTID,
        empl.VC_CODE,
        fin.FDM_COMBO_CD,
        UKG_BS.COMBOCODE,
        empl.REPORTS_TO,
        empl.MANAGER_EMPLID,
        'F' AS NON_UKG_MANAGER_FLAG, -- Terminated employees are not managers
        empl.position_nbr,
        EMPL.EMPLID,
        empl.EMPL_RCD,
        empl.jobcode,
        empl.POSITION_DESCR,
        empl.hr_status,
        0 AS FTE_SUM, -- Terminated employees have 0 FTE
        empl.fte,
        empl.empl_Status,
        UKG_JC.JobGroup,
        ukg_bs.FundGroup,
        ISNULL(EMPL.EMPLID, '') AS 'Person Number',
        EMPL.LIVED_FIRST_NAME AS 'First Name',
        ISNULL(CAST(EMPL.LAST_NAME AS VARCHAR), '') AS 'Last Name',
        LEFT(EMPL.LIVED_MIDDLE_NAME,1) AS 'Middle Initial/Name',
        '' AS 'Short Name',
        '' AS 'Badge Number',
        ISNULL(CAST(EMPL.HIRE_DT AS VARCHAR), '') AS 'Hire Date',
        '' AS 'Birth Date',
        '' AS 'Seniority Date',
        'F' AS 'Manager Flag', -- Terminated employees are not managers
        COALESCE(REPLACE(PH1.phone, '/', '-'), '') AS 'Phone 1',
        COALESCE(REPLACE(PH2.phone, '/', '-'), '') AS 'Phone 2',
        CASE WHEN VC_CODE IN ('VCHSH', 'VCHSS') THEN REPLACE(EMPL.BUSN_EMAIL_ADDR, '@ucsd.edu', '@health.ucsd.edu')
             ELSE EMPL.BUSN_EMAIL_ADDR END AS 'Email',
        '' AS 'Address',
        '' AS 'City',
        '' AS 'State',
        '' AS 'Postal Code',
        '' AS 'Country',
        'Pacific' AS 'Time Zone',

        ISNULL
(UKG_ES.empl_Status, '') AS 'Employment Status', -- Replace EMPL.HR_STATUS with EMPL.empl_Status
        ISNULL
(CAST
(UKG_ES.EFFDT AS VARCHAR), '')  AS 'Employment Status Effective Date', -- 9/3 Replace EMPL.EFFDT with UKG_ES.EFFDT     
        '' AS 'Reports to Manager', -- Terminated employees don't report to active managers
        '' AS 'Union Code',
        '' AS 'Employee Type',
        '' AS 'Employee Classification',
        '' AS 'Pay Frequency',
        'T' AS 'Worker Type', -- Terminated
        '0' AS 'FTE %',
        '' AS 'FTE Standard Hours',
        '' AS 'FTE Full Time Hours',
        '' AS 'Standard Hours - Daily',
        '' AS 'Standard Hours - Weekly',
        '' AS 'Standard Hours - Pay Period',
        '' AS 'Base Wage Rate',
        '' AS 'Base Wage Rate Effective Date',
        EMPL.EMPLID AS 'User Account Name',
        'I' AS 'User Account Status', -- Inactive
        '' AS 'User Password',
        '' AS 'Home Business Structure Level 1 - Organization',
        '' AS 'Home Business Structure Level 2 - Entity',
        '' AS 'Home Business Structure Level 3 - Service Line',
        '' AS 'Home Business Structure Level 4 - Financial Unit',
        '' AS 'Home Business Structure Level 5 - Fund Group',
        '' AS 'Home Business Structure Level 6',
        '' AS 'Home Business Structure Level 7',
        '' AS 'Home Business Structure Level 8',
        '' AS 'Home Business Structure Level 9',
        '' AS 'Home/Primary Job',
        '' AS 'Home Labor Category Level 1',
        '' AS 'Home Labor Category Level 2',
        '' AS 'Home Labor Category Level 3',
        '' AS 'Home Labor Category Level 4',
        '' AS 'Home Labor Category Level 5',
        '' AS 'Home Labor Category Level 6',
        '' AS 'Home Job and Labor Category Effective Date',
        '' AS 'Custom Field 1',
        '' AS 'Custom Field 2',
        '' AS 'Custom Field 3',
        '' AS 'Custom Field 4',
        '' AS 'Custom Field 5',
        '' AS 'Custom Field 6',
        '' AS 'Custom Field 7',
        '' AS 'Custom Field 8',
        '' AS 'Custom Field 9',
        '' AS 'Custom Field 10',
        '' AS 'Custom Date 1',
        '' AS 'Custom Date 2',
        '' AS 'Custom Date 3',
        ISNULL
(CAST
(UKG_HS.EFFDT AS VARCHAR), '')  AS 'Custom Date 4', -- 9/3/2025  Replace EMPL.EFFDT with UKG_HS.EFFDT
        '' AS 'Custom Date 5',
        '' AS 'Custom Field 11',
        '' AS 'Custom Field 12',
        '' AS 'Custom Field 13',
        '' AS 'Custom Field 14',
        '' AS 'Custom Field 15',
        '' AS 'Custom Field 16',
        '' AS 'Custom Field 17',
        '' AS 'Custom Field 18',
        '' AS 'Custom Field 19',
        '' AS 'Custom Field 20',
        '' AS 'Custom Field 21',
        '' AS 'Custom Field 22',
        '' AS 'Custom Field 23',
        '' AS 'Custom Field 24',
        '' AS 'Custom Field 25',
        '' AS 'Custom Field 26',
        '' AS 'Custom Field 27',
        '' AS 'Custom Field 28',
        '' AS 'Custom Field 29',
        '' AS 'Custom Field 30',
        '' AS 'Additional Fields for CRT lookups',
        empl.termination_dt
    INTO [stage].[UKG_EMPLOYEE_DATA_TERMINATED]
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
        LEFT OUTER JOIN health_ods.[health_ods].[stable].PS_PERSONAL_PHONE PH1
        ON PH1.EMPLID = EMPL.EMPLID
            AND PH1.DML_IND <> 'D'
            AND PH1.PHONE_TYPE IN ('CEL2')
        LEFT OUTER JOIN health_ods.[health_ods].[stable].PS_PERSONAL_PHONE PH2
        ON PH2.EMPLID = EMPL.EMPLID
            AND PH2.DML_IND <> 'D'
            AND PH2.PHONE_TYPE IN ('CELL')
        LEFT OUTER JOIN health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        ON EMPL.POSITION_NBR = FIN.POSITION_NBR
            AND FIN.POSN_SEQ = (SELECT MIN_POSN_SEQ
            FROM (
                SELECT FIN2.POSITION_NBR, MIN(FIN2.POSN_SEQ) AS MIN_POSN_SEQ
                FROM health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN2
                GROUP BY FIN2.POSITION_NBR
            ) T
            WHERE FIN.POSITION_NBR = T.POSITION_NBR)
        LEFT OUTER JOIN [hts].[UKG_BusinessStructure] UKG_BS
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
        LEFT OUTER JOIN hts.UKG_JOBCODES UKG_JC
        ON UKG_JC.JOBCODE = EMPL.JOBCODE
        LEFT JOIN [stage].[UKG_EMPL_STATUS_LOOKUP] UKG_ES
        ON EMPL.emplid = UKG_ES.emplid
        LEFT JOIN [stage].[UKG_HR_STATUS_LOOKUP] UKG_HS
        ON EMPL.emplid = UKG_HS.emplid
    WHERE EMPL.HR_STATUS = 'I' -- Only terminated employees
        AND CONVERT(DATE, EMPL.EFFDT) >= DATEADD(DAY, -7, GETDATE()) -- Last 7 days
        AND EMPL.PAY_FREQUENCY = 'B'
        AND EMPL.EMPL_TYPE = 'H'
        AND EMPL.JOB_INDICATOR = 'P'
        AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
        OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
       )
        AND EMPL.EMPLID NOT IN (SELECT emplid
        FROM STAGE.CTE_exclude_BYA)
        AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776'));

    PRINT 'UKG_EMPLOYEE_DATA_TERMINATED table created successfully';

    -- Show summary
    SELECT
        'Terminated employees processed' as Description,
        COUNT(*) as Count
    FROM [stage].[UKG_EMPLOYEE_DATA_TERMINATED];

END;

GO
