SELECT DISTINCT
    emplid  AS 'Labor Category List Name',
    LIVED_FIRST_LAST_NAME AS  [List Description],
    'Comp' AS 'Labor Category Name',
    'Comp or Pay' AS [Assigned Entry]
INTO #TEMP_PH
FROM health_ods.[Health_ODS].[RPT].current_empl_data empl
WHERE 1=1
    AND EMPL.FLSA_STATUS = 'N'
    AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
    OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280')) ) -- PHSO
    AND ((EMPL.hr_status = 'A') -- active empl
    OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE())) --terminated empl today
    )
    AND PAY_FREQUENCY = 'B'
    AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
    AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776'))
--exclude ARC MSP POPULATION
;


SELECT DISTINCT
    [Labor Category List Name] AS 'Labor Category Profile Name',
    [List Description] AS 'Profile Description',
    'Comp or Pay' AS 'Labor Category List',
    'Comp'   AS 'Labor Category List Category'
FROM #TEMP_PH

; 



--DROP TABLE #TEMP_PH
GO

