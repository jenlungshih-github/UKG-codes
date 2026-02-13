
DECLARE @emplid VARCHAR(20) = '10856229';

SELECT
    empl.EMPLID,
    empl.[First Name],
    empl.[Last Name],
    empl.[Employment Status],
    empl.[Home/Primary Job],
    empl.DEPTID,
    empl.[Reports to Manager],
    B.[Person Number],
    B.FundGroup,
    B.[Parent Path],
    B.Loaded_DT,
    CASE 
            WHEN UBS.combocode IS NOT NULL THEN 'MATCH FOUND'
            ELSE 'NO MATCH'
        END AS BusinessStructure_Match_Status,
    UBS.combocode AS Matched_BusinessStructure_ComboCode
FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] empl
    INNER JOIN stage.UKG_EMPL_Business_Structure B
    ON empl.EMPLID = B.[Person Number]
    LEFT JOIN [hts].[UKG_BusinessStructure] UBS
    ON B.FundGroup = UBS.FundGroup
WHERE empl.EMPLID = @emplid;
-- Return row count for verification
IF @@ROWCOUNT = 0
    BEGIN
    PRINT 'No employee found with EMPLID: ' + @emplid;
END
    ELSE
    BEGIN
    PRINT 'Employee data retrieved for EMPLID: ' + @emplid;
END


