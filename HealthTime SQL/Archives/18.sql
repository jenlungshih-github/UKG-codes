/****** Query to join UKG_EMPL_Inactive_Manager with UKG_EMPL_Inactive_Manager_Hierarchy ******/
SELECT
    I.[POSITION_NBR],
    I.[Inactive_EMPLID],
    I.[empl_NAME],
    I.[HR_STATUS],
    I.[EMPL_RCD],
    I.[DEPTID],
    I.[BUSINESS_UNIT],
    I.[LOCATION],
    I.[JOB_INDICATOR],
    I.[FTE],
    I.[UNION_CD],
    I.[JOBCODE],
    I.[ROW_NO],
    I.[UPDATED_DT],
    H.[HIERARCHY_LEVEL],
    H.[MANAGER_POSN_LEVEL],
    H.[MANAGER_EMPLID],
    H.[MANAGER_HR_STATUS],
    H.[MANAGER_POSN_STATUS],
    L.[POSN_LEVEL],
    L.[emplid] AS LOOKUP_EMPLID,
    L.[JOB_INDICATOR] AS LOOKUP_JOB_INDICATOR,
    L.[UPDATED_DT] AS LOOKUP_UPDATED_DT
FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
    INNER JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
    ON I.[POSITION_NBR] = H.[MANAGER_POSITION_NBR]
    LEFT JOIN [HealthTime].[stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
    ON L.[POSITION_NBR] = I.[POSITION_NBR]
WHERE L.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
ORDER BY I.[POSITION_NBR], H.[HIERARCHY_LEVEL];