WITH
    imgr
    AS
    (
        SELECT [POSITION_NBR] as [POSITION_NBR_To_Check]
              , [Inactive_EMPLID] as Inactive_Manager_EMPLID
              , [empl_NAME] as Manager_To_Check
              , [JOB_INDICATOR] as Manager_JOB_INDICATOR
        FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager]
    ),
    position_terminations
    AS
    (
        SELECT
            empl.POSITION_NBR,
            empl.EMPLID,
            empl.termination_dt,
            ROW_NUMBER() OVER (PARTITION BY empl.POSITION_NBR ORDER BY empl.termination_dt DESC) as rn
        FROM imgr
            JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
            ON imgr.[POSITION_NBR_To_Check] = empl.POSITION_NBR
        WHERE empl.HR_STATUS = 'I'
    ),
    latest_imgr
    AS
    (
        SELECT
            POSITION_NBR as [POSITION_NBR_To_Check],
            EMPLID as Inactive_Manager_EMPLID,
            termination_dt as Inactive_Manager_Termination_Date
        FROM position_terminations
        WHERE rn = 1
    )
SELECT distinct
    empl2.emplid,
    empl2.name,
    empl2.Reports_To,
    latest_imgr.[POSITION_NBR_To_Check],
    latest_imgr.Inactive_Manager_EMPLID,
    latest_imgr.Inactive_Manager_Termination_Date
FROM latest_imgr
    JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl2
    ON latest_imgr.[POSITION_NBR_To_Check] = empl2.Reports_To
WHERE 
empl2.HR_STATUS='A'
    AND
    latest_imgr.[POSITION_NBR_To_Check] = '40651890';