
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

        UNION

            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                'Unknown Employee' AS empl_NAME,
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
                LEFT JOIN [dbo].[UKG_EMPLOYEE_DATA] empl
                ON J.POSITION_NBR = empl.REPORTS_TO
            WHERE J.DML_IND <> 'D'
                AND J.EMPLID IS NULL
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
--INTO [stage].[UKG_EMPL_Inactive_Manager]
-- -- [dbo].[UKG_EMPLOYEE_DATA] empl has reports-to BUT HR_STATUS = 'I'.  Create a table [stage].[UKG_EMPL_Inactive_Manager].
FROM RankedJobs
WHERE ROW_NO = 1