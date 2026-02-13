WITH
    JobData
    AS
    (
        SELECT
            J.POSITION_NBR,
            J.EMPLID,
            J.HR_STATUS,
            J.EMPL_RCD,
            J.JOBCODE,
            J.EFFDT,
            ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                EFFDT DESC) as ROWNO
        FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
        WHERE 
            J.DML_IND <> 'D'
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
    ),
    JobDataFiltered
    AS
    (
        SELECT
            POSITION_NBR,
            EMPLID,
            HR_STATUS,
            EMPL_RCD,
            JOBCODE,
            EFFDT,
            ROWNO
        FROM JobData
        WHERE ROWNO = 1
    ),
    CurrentEmplData
    AS
    (
        SELECT
            empl.POSITION_NBR,
            empl.HR_STATUS,
            empl.emplid,
            empl.EMPL_RCD,
            empl.EFFDT,
            ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
        FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
    ),
    CurrentEmplDataFiltered
    AS
    (
        SELECT
            POSITION_NBR,
            HR_STATUS,
            emplid,
            EMPL_RCD,
            EFFDT,
            RN_EMPL
        FROM CurrentEmplData
        WHERE RN_EMPL = 1
    ),
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
    ),
    FinalResultData
    AS
    (
        SELECT
            jd.POSITION_NBR,
            empl.EMPLID,
            empl.HR_STATUS as EMPL_HR_STATUS,
            empl.EFFDT as EMPL_EFFDT,
            pd.POSN_STATUS,
            ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
        FROM JobDataFiltered jd
            JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
            JOIN CurrentEmplDataFiltered empl ON empl.POSITION_NBR = jd.POSITION_NBR
        WHERE 
            pd.RN = 1
    )
SELECT top 10
    frd.POSITION_NBR,
    frd.EMPLID,
    frd.EMPL_HR_STATUS,
    frd.EMPL_EFFDT,
    frd.POSN_STATUS
FROM FinalResultData frd
WHERE frd.RN_FINAL = 1;
