
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
				ROW_NUMBER() OVER(PARTITION BY J.EMPLID ORDER BY (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), EFFDT desc) as ROWNO
FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
WHERE 
J.POSITION_NBR='40887613'
--and
--             J.DML_IND <> 'D'
--                AND J.EFFDT = (
--                SELECT MAX(J1.EFFDT)
--                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
--                WHERE J1.EMPLID = J.EMPLID
--                    AND J1.EMPL_RCD = J.EMPL_RCD
--                    AND J1.EFFDT <= GETDATE()
--                    AND J1.DML_IND <> 'D'
--            )
--                AND J.EFFSEQ = (
--                SELECT MAX(J2.EFFSEQ)
--                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
--                WHERE J2.EMPLID = J.EMPLID
--                    AND J2.EMPL_RCD = J.EMPL_RCD
--                    AND J2.EFFDT = J.EFFDT
--                    AND J2.DML_IND <> 'D'
--            )

			order by J.EFFDT desc