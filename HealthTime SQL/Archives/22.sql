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
    employee_manager_data
    AS
    (
        SELECT
            empl.emplid
        , empl.[Last Name] + ', ' + empl.[First Name] AS empl_NAME
        , empl.REports_To
        , imgr.[POSITION_NBR_To_Check]
        , imgr.[Inactive_Manager_EMPLID]
        , imgr.[Manager_To_Check]
        , imgr.[Manager_JOB_INDICATOR]
        , e.termination_dt
        , e.HR_STATUS
        , ROW_NUMBER() OVER (PARTITION BY imgr.[Inactive_Manager_EMPLID] ORDER BY e.termination_dt DESC) AS rn
        FROM [dbo].[UKG_EMPLOYEE_DATA] empl
            JOIN imgr
            ON empl.Reports_To = imgr.[POSITION_NBR_To_Check]
            LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] e
            ON imgr.[Inactive_Manager_EMPLID] = e.emplid
        WHERE 
        empl.hr_status='A'
            AND
            e.HR_STATUS='I'
    )
SELECT
    emplid
, empl_NAME
, Reports_To
, POSITION_NBR_To_Check
, Inactive_Manager_EMPLID
, Manager_To_Check
, Manager_JOB_INDICATOR
, termination_dt
, HR_STATUS
FROM employee_manager_data
WHERE rn = 1