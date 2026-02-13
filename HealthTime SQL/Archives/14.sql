
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
        FROM health_ods.health_ods.stable.PS_POSITION_DATA
        WHERE dml_ind <> 'D'
    )
SELECT DISTINCT top 1
    imgr.[Inactive_EMPLID],
    imgr.POSITION_NBR as Inactive_EMPLID_POSITION_NBR,
    empl.MANAGER_EMPLID,
    empl.MANAGER_NAME,
    empl.[POSITION_REPORTS_TO],
    pd.POSN_STATUS,
    pd.deptid as POSITION_DEPTID,
    pd.EFFDT as POSITION_EFFDT
FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] empl
    INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] imgr
    ON empl.emplid = imgr.[Inactive_EMPLID]
        and empl.POSITION_NBR=imgr.POSITION_NBR
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
where empl.MANAGER_EMPLID is NULL