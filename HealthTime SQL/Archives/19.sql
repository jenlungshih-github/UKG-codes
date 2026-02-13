/****** Query to join UKG_EMPL_Inactive_Manager with UKG_EMPL_Inactive_Manager_Hierarchy ******/
SELECT
    I.[POSITION_NBR],
    I.[Inactive_EMPLID],
    I.[empl_NAME],
    --I.[HR_STATUS],
    --I.[EMPL_RCD],
    --I.[DEPTID],
    --I.[BUSINESS_UNIT],
    --I.[LOCATION],
    --I.[JOB_INDICATOR],
    --I.[FTE],
    --I.[UNION_CD],
    --I.[JOBCODE],
    --I.[ROW_NO],
    --I.[UPDATED_DT],
    H.POSITION_NBR_To_Check,
    H.[MANAGER_POSITION_NBR],
    H.[POSN_LEVEL]
FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
    LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
    ON I.[POSITION_NBR] = H.[POSITION_NBR_To_Check]
--LEFT JOIN [HealthTime].[stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
--ON L.[POSITION_NBR] = I.[POSITION_NBR]
WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
    and
    I.[POSITION_NBR]
IN (
    '40688126', '40695802', '40697146', '40699053', '40700950', '40702349',
    '40703703', '40704589', '40709698', '40709834', '40887613', '41042579'
)
    and
    H.To_Trace_Up_1='no'