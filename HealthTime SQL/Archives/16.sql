
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
        FROM health_ods.[health_ods].stable.PS_POSITION_DATA
        WHERE dml_ind <> 'D'
    )
SELECT DISTINCT
    imgr.POSITION_NBR as POSITION_NBR_To_Check
        , empl.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR
		, L.POSN_LEVEL
FROM
    [stage].[UKG_EMPL_Inactive_Manager] imgr
    LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
    ON empl.emplid = imgr.[Inactive_EMPLID]
        AND empl.POSITION_NBR = imgr.POSITION_NBR
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
    LEFT JOIN [stage].[UKG_ManagerHierarchy] L
    ON empl.[POSITION_REPORTS_TO]=L.POSITION_NBR