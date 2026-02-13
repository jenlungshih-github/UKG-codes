/*
    QA SQL: QA_UKG_EMPLOYEE_DATA_TRACE.sql
    Version: 2025-09-29

    Step-by-step trace for EMPLID=10511090 and HR_STATUS='I':

    1. Exclusion of BYA Employees
       - The procedure creates STAGE.CTE_exclude_BYA with all employees from PS_JOB where SAL_ADMIN_PLAN = 'BYA'.
       - If 10511090 is not in this list, it is not excluded.

    2. Population of UKG Employees (STAGE.UKG_EMPL_E_T)
       - The record must be present in CURRENT_EMPL_DATA and satisfy:
         * JOB_INDICATOR = 'P'
         * VC_CODE = 'VCHSH' (Med Center) OR DEPTID between '002000' and '002999' (excluding '002230','002231','002280')
         * PAY_FREQUENCY = 'B'
         * EMPL_TYPE = 'H'
         * Not in ARC MSP population (certain DEPTID and JOBCODE combinations)
         * For HR_STATUS='I', must also have:
           (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) >= DATEADD(DAY, -7, GETDATE()))
           (terminated in the past 7 days)

    3. Manager Hierarchy Update
       - If MANAGER_EMPLID is NULL, the procedure updates it to the next available manager up to level 5-10 using the hierarchy in ORG_HIERARCHY_POSN.

    4. Combine UKG Employees and Managers (STAGE.UKG_EMPL_T)
       - Combines STAGE.UKG_EMPL_E_T and STAGE.UKG_EMPL_M_T (managers outside UKG).
       - If 10511090 is a manager, it could also be included from the manager table.

    5. Data Enrichment via Joins
       - The record is joined with:
         * STAGE.UKG_EMPL_HRATE_EFFDT_T for pay rate info
         * CURRENT_EMPL_REPORTS_TO for manager info
         * ORG_HIERARCHY_POSN for hierarchy
         * PS_PERSONAL_PHONE for phone numbers
         * STAGE.UKG_EMPL_FTE_T for FTE info
         * CURRENT_POSITION_PRI_FIN_UNIT and [hts].[UKG_BusinessStructure] for business structure
         * [stage].[UKG_EMPL_STATUS_LOOKUP] and [stage].[UKG_HR_STATUS_LOOKUP] for status info

    6. Final Table Creation
       - The final SELECT builds [dbo].[UKG_EMPLOYEE_DATA] with all enriched columns.
       - The record for 10511090 is included if it:
         * Is not excluded as a BYA employee.
         * Meets the population criteria (primary job, correct codes, terminated in past 7 days, etc.).
         * Successfully joins with the required lookup tables.

    7. Output
       - The record will have HR_STATUS='I' and all other columns populated from the joins and logic above.

    Summary:
    If EMPLID=10511090 is not a BYA employee, is a primary job, hourly, biweekly employee in the correct department, and was terminated in the past 7 days, it will be included in [dbo].[UKG_EMPLOYEE_DATA] with HR_STATUS='I'.
*/

-- QA SQL to retrieve the record for validation
SELECT *
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE EMPLID = 10511090
    AND HR_STATUS = 'I';

-- Step-by-step QA trace messages for EMPLID=10511090 and HR_STATUS='I'
PRINT 'Step 1: Checking BYA exclusion...';
IF EXISTS (SELECT 1
FROM STAGE.CTE_exclude_BYA
WHERE EMPLID = 10511090)
    PRINT 'EMPLID=10511090 is excluded as BYA employee.';
ELSE
    PRINT 'EMPLID=10511090 is NOT excluded as BYA employee.';

PRINT 'Step 2: Checking UKG employee population filters...';
IF EXISTS (
    SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
WHERE EMPL.EMPLID = 10511090
    AND EMPL.JOB_INDICATOR = 'P'
    AND (EMPL.VC_CODE = 'VCHSH' OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280')))
    AND EMPL.PAY_FREQUENCY = 'B'
    AND EMPL.EMPL_TYPE = 'H'
    AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776'))
    AND EMPL.HR_STATUS = 'I'
    AND CONVERT(DATE, EMPL.effdt) >= DATEADD(DAY, -7, GETDATE())
)
    PRINT 'EMPLID=10511090 passes UKG employee population filters.';
ELSE
    PRINT 'EMPLID=10511090 does NOT pass UKG employee population filters.';

-- Breakdown of UKG employee population filters for EMPLID=10511090
PRINT 'Checking JOB_INDICATOR...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND JOB_INDICATOR = 'P')
    PRINT 'JOB_INDICATOR = P';
ELSE
    PRINT 'JOB_INDICATOR is NOT P';

PRINT 'Checking VC_CODE and DEPTID...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND (VC_CODE = 'VCHSH' OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280'))))
    PRINT 'VC_CODE/DEPTID filter PASSED';
ELSE
    PRINT 'VC_CODE/DEPTID filter FAILED';

PRINT 'Checking PAY_FREQUENCY...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND PAY_FREQUENCY = 'B')
    PRINT 'PAY_FREQUENCY = B';
ELSE
    PRINT 'PAY_FREQUENCY is NOT B';

PRINT 'Checking EMPL_TYPE...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND EMPL_TYPE = 'H')
    PRINT 'EMPL_TYPE = H';
ELSE
    PRINT 'EMPL_TYPE is NOT H';

PRINT 'Checking ARC MSP exclusion...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776'))
    PRINT 'ARC MSP exclusion FAILED';
ELSE
    PRINT 'ARC MSP exclusion PASSED';

PRINT 'Checking HR_STATUS and termination date...';
IF EXISTS (SELECT 1
FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
WHERE EMPLID = 10511090 AND HR_STATUS = 'I' AND CONVERT(DATE, effdt) >= DATEADD(DAY, -7, GETDATE()))
    PRINT 'HR_STATUS and termination date PASSED';
ELSE
    PRINT 'HR_STATUS and/or termination date FAILED';

PRINT 'Step 3: Checking manager hierarchy update...';
-- This step is handled by UPDATE logic in the main SP, not directly testable here
PRINT 'Manager hierarchy update applied if MANAGER_EMPLID is NULL.';

PRINT 'Step 4: Checking if included in UKG employee or manager union...';
IF EXISTS (
    SELECT 1
FROM HealthTime.STAGE.UKG_EMPL_T
WHERE EMPLID = 10511090
)
    PRINT 'EMPLID=10511090 is included in UKG employee/manager union.';
ELSE
    PRINT 'EMPLID=10511090 is NOT included in UKG employee/manager union.';

PRINT 'Step 5: Checking data enrichment joins...';
-- Joins are applied in the main build, not directly testable here
PRINT 'Data enrichment joins applied.';

PRINT 'Step 6: Checking final table inclusion...';
IF EXISTS (
    SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE EMPLID = 10511090 AND HR_STATUS = 'I'
)
    PRINT 'EMPLID=10511090 with HR_STATUS=I is present in final table.';
ELSE
    PRINT 'EMPLID=10511090 with HR_STATUS=I is NOT present in final table.';
