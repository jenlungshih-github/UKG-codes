-- QA Query for emplid=10406844 - Manager Flag Analysis -- Not for NON-UKG Manager
-- This query explains why the Manager Flag is set to 'T' for this employee
-- even if they have no active direct reports

DECLARE @emplid VARCHAR(20) = '10406844';

-- 1. Basic employee information
SELECT
    'Employee Details' as Section,
    emplid,
    [First Name] + ' ' + [Last Name] as Employee_Name,
    position_nbr,
    [Manager Flag],
    hr_status,
    [Employment Status]
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE emplid = @emplid;

-- 2. Check for active direct reports
SELECT
    'Active Direct Reports' as Section,
    COUNT(*) as Active_Reports_Count,
    CASE WHEN COUNT(*) > 0 THEN 'Has Active Reports' ELSE 'No Active Reports' END as Status
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE reports_to = (SELECT position_nbr
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE emplid = @emplid)
    AND hr_status = 'A'
    AND emplid != @emplid;
-- Exclude self-reports

-- 3. Check for terminated direct reports
SELECT
    'Terminated Direct Reports' as Section,
    COUNT(*) as Terminated_Reports_Count,
    CASE WHEN COUNT(*) > 0 THEN 'Has Terminated Reports - This explains Manager Flag = T' ELSE 'No Terminated Reports' END as Explanation
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE reports_to = (SELECT position_nbr
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE emplid = @emplid)
    AND hr_status = 'I'
    AND emplid != @emplid;
-- Exclude self-reports

-- 4. List all terminated employees who report to this position
SELECT
    'Terminated Employees Reporting to This Position' as Section,
    TE.emplid,
    TE.[First Name] + ' ' + TE.[Last Name] as Terminated_Employee_Name,
    TE.position_nbr as Terminated_Employee_Position,
    TE.[Employment Status],
    TE.[termination_dt]
FROM [dbo].[UKG_EMPLOYEE_DATA] TE
WHERE TE.reports_to = (SELECT position_nbr
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE emplid = @emplid)
    AND TE.hr_status = 'I'
    AND TE.emplid != @emplid
-- Exclude self-reports
ORDER BY TE.[termination_dt] DESC;

-- 5. Check the logic from the stored procedure
-- This shows what the SP_UKG_EMPL_Update_Manager_Flag-Step4 procedure would identify
WITH
    TERMINATED_empl
    AS
    (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
    ),
    Positions_With_Terminated_Reports
    AS
    (
        SELECT DISTINCT
            E.position_nbr,
            E.emplid,
            E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
            COUNT(TE.emplid) as Terminated_Reports_Count
        FROM [dbo].[UKG_EMPLOYEE_DATA] E
            INNER JOIN TERMINATED_empl TE
            ON E.position_nbr = TE.reports_to
        WHERE E.emplid = @emplid
        GROUP BY E.position_nbr, E.emplid, E.[First Name], E.[Last Name]
    )
SELECT
    'SP Logic Analysis' as Section,
    CASE WHEN EXISTS (SELECT 1
    FROM Positions_With_Terminated_Reports)
         THEN 'This position qualifies for Manager Flag = T due to terminated reports'
         ELSE 'This position does not qualify for Manager Flag = T based on SP logic'
    END as SP_Logic_Result,
    P.*
FROM Positions_With_Terminated_Reports P;

-- 6. Summary explanation
SELECT
    'Summary Explanation' as Section,
    CASE
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE reports_to = (SELECT position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE emplid = @emplid)
        AND hr_status = 'I'
        AND emplid != @emplid
        ) THEN 'Manager Flag = T because this position has terminated employees who historically reported to it. The SP preserves manager status for historical reporting relationships.'
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE reports_to = (SELECT position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE emplid = @emplid)
        AND hr_status = 'A'
        AND emplid != @emplid
        ) THEN 'Manager Flag = T because this position has active employees reporting to it.'
        ELSE 'Manager Flag should be F - no active or terminated reports found. This may indicate the flag was set by different logic.'
    END as Explanation;
