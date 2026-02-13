WITH
    mPOSN
    AS
    (
        SELECT emplid, [position_nbr]
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE emplid IN (
        '10235400', '10373215', '10401320', '10401447', '10402336', '10404345', '10405207', '10405770',
        '10406844', '10407170', '10407970', '10409211', '10409420', '10412739', '10412769', '10412919',
        '10412932', '10413539', '10415632', '10415635', '10416781', '10417802', '10418338', '10418506',
        '10419632', '10420796', '10420980', '10421049', '10422434', '10423407', '10423636', '10424641',
        '10425032', '10425191', '10425466', '10425683', '10425853', '10425930', '10426439', '10426458',
        '10426467', '10426824', '10427101', '10429427', '10471816', '10492499', '10581228', '10592313',
        '10595423', '10640519', '10699553', '10700654', '10709689', '10715898', '10754402', '10760249',
        '10779426', '10781453', '10821072'
    )
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
    empl.emplid,
    empl.HR_STATUS,
    empl.MANAGER_EMPLID,
    empl.MANAGER_NAME,
    empl.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR,
    pd.POSN_STATUS,
    pd.deptid as POSITION_DEPTID,
    pd.EFFDT as POSITION_EFFDT
FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
WHERE empl.[POSITION_REPORTS_TO] IN (SELECT position_nbr
FROM mPOSN)