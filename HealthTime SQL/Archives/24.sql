SELECT
    etc.[emplid],
    etc.[name],
    etc.[Reports_To] AS etc_Reports_To,
    ukg.[Reports_to] AS ukg_Reports_To,
    etc.[POSITION_NBR_To_Check],
    etc.[Inactive_Manager_EMPLID],
    etc.[Inactive_Manager_Termination_Date],
    CASE 
        WHEN ukg.EMPLID IS NULL THEN 'EMPLID NOT FOUND IN UKG'
        WHEN etc.[emplid] = ukg.EMPLID AND etc.[Reports_To] = ukg.[Reports_to] THEN 'COMPLETE MATCH'
        WHEN etc.[emplid] = ukg.EMPLID AND etc.[Reports_To] != ukg.[Reports_to] THEN 'EMPLID MATCH, REPORTS_TO MISMATCH'
        ELSE 'OTHER MISMATCH'
    END AS Match_Status,
    ukg.[First Name] + ' ' + ukg.[Last Name] AS ukg_Name
FROM [BCK].[empl_to_check] etc
    LEFT JOIN [dbo].[UKG_EMPLOYEE_DATA] ukg
    ON etc.[emplid] = ukg.EMPLID
WHERE NOT (etc.[emplid] = ukg.EMPLID AND etc.[Reports_To] = ukg.[Reports_to])
ORDER BY Match_Status, etc.[emplid]