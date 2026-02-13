
WITH
    InactiveManagerHierarchy
    AS
    (
        SELECT
            I.[POSITION_NBR],
            I.[Inactive_EMPLID],
            I.[empl_NAME],
            H.POSITION_NBR_To_Check,
            H.[MANAGER_POSITION_NBR],
            H.[POSN_LEVEL]
        FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
            LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
            ON I.[POSITION_NBR] = H.[POSITION_NBR_To_Check]
        WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
            AND I.[POSITION_NBR] IN ( '40695802'
            )
            AND H.To_Trace_Up_1 = 'no'
    )
    UPDATE empl
    SET 
        [Reports to Manager] = CTE.MANAGER_POSITION_NBR
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN InactiveManagerHierarchy CTE
    ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];