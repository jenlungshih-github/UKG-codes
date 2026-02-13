WITH
    mPOSN
    AS
    (
        SELECT emplid, [position_nbr]
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [Manager Flag]='T'
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
    )
SELECT DISTINCT
    mPOSN.[position_nbr]--, SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) as total_rows
FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
    INNER JOIN mPOSN
    ON mPOSN.position_nbr = empl.[POSITION_REPORTS_TO]
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
WHERE empl.MANAGER_EMPLID is not NULL
--    and empl.HR_STATUS <> 'A'
--	and mPOSN.[position_nbr]='40643157'
GROUP BY mPOSN.[position_nbr]
HAVING SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) = 0