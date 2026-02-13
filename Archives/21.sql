
-- Create table variable to hold employee IDs and names for reference
DECLARE @employees TABLE (
    EMPLID VARCHAR(20),
    EmployeeName VARCHAR(100)
);

-- Insert employee IDs and names
INSERT INTO @employees
    (EMPLID, EmployeeName)
VALUES
    ('10400284', 'Stacey Williams'),
    ('10404558', 'Laura Yoshida'),
    ('10406748', 'Nikki Adlaon'),
    ('10407166', 'Celica Ramirez'),
    ('10414234', 'Vivika Wax'),
    ('10416759', 'Rosario Quismorio'),
    ('10421273', 'Jennifer Lasher'),
    ('10422497', 'Original Employee'),
    -- Original EMPLID from your query
    ('10455515', 'Amanda Booker'),
    ('10467173', 'Laura Kinney'),
    ('10545156', 'Yaritza Alcazar'),
    ('10557432', 'Martha Herrick'),
    ('10733777', 'Daryl Soriano'),
    ('10755336', 'Holly Haynes'),
    ('10800937', 'Melanie Carrasco');

-- Declare variables for cursor
DECLARE @emplid VARCHAR(20);
DECLARE @employeeName VARCHAR(100);
DECLARE @rowcount INT;

-- Cursor to iterate through each employee
DECLARE employee_cursor CURSOR FOR
SELECT EMPLID, EmployeeName
FROM @employees
ORDER BY EMPLID;

OPEN employee_cursor;
FETCH NEXT FROM employee_cursor INTO @emplid, @employeeName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '======================================';
    PRINT 'Checking EMPLID: ' + @emplid + ' (' + @employeeName + ')';
    PRINT '======================================';

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
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN stage.UKG_EMPL_Business_Structure B
        ON empl.EMPLID = B.[Person Number]
        LEFT JOIN [hts].[UKG_BusinessStructure] UBS
        ON B.FundGroup = UBS.FundGroup
    WHERE empl.EMPLID = @emplid;

    SET @rowcount = @@ROWCOUNT;

    -- Return row count for verification
    IF @rowcount = 0
    BEGIN
        PRINT 'No employee found with EMPLID: ' + @emplid + ' (' + @employeeName + ')';
    END
    ELSE
    BEGIN
        PRINT 'Employee data retrieved for EMPLID: ' + @emplid + ' (' + @employeeName + ') - ' + CAST(@rowcount AS VARCHAR(10)) + ' record(s) found';
    END
    PRINT '';
    -- Empty line for readability

    FETCH NEXT FROM employee_cursor INTO @emplid, @employeeName;
END

CLOSE employee_cursor;
DEALLOCATE employee_cursor;

-- Get the count separately to avoid subquery in PRINT statement
DECLARE @totalEmployees INT;
SELECT @totalEmployees = COUNT(*)
FROM @employees;

PRINT '======================================';
PRINT 'SUMMARY: Completed checking all ' + CAST(@totalEmployees AS VARCHAR(10)) + ' employees';
PRINT '======================================';


