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
-- Count emplid with HR_STATUS='I' and 'A', list mPOSN position_nbr
SELECT
    COUNT(empl.emplid) as emplid_count,
    STUFF((
        SELECT ', ' + CAST(mp2.position_nbr AS VARCHAR(MAX))
    FROM mPOSN mp2
    WHERE mp2.position_nbr IN (
            SELECT DISTINCT empl2.POSITION_REPORTS_TO
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl2
    WHERE empl2.POSITION_REPORTS_TO IN (SELECT position_nbr
        FROM mPOSN)
        AND empl2.MANAGER_EMPLID IS NOT NULL
        AND empl2.HR_STATUS IN ('I', 'A')
        )
    FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as position_nbr_list
FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
    INNER JOIN mPOSN mp
    ON mp.position_nbr = empl.[POSITION_REPORTS_TO]
WHERE empl.[POSITION_REPORTS_TO] IN (SELECT position_nbr
    FROM mPOSN)
    AND empl.MANAGER_EMPLID IS NOT NULL
    AND empl.HR_STATUS IN ('I', 'A')
