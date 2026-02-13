WITH
    duplicate_employees
    AS
    (
        SELECT emplid, count(emplid) as emp_count
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        GROUP BY emplid
        HAVING count(emplid) > 1
    )
SELECT
    empl.emplid,
    empl.position_nbr,
    empl.FTE
FROM duplicate_employees cte
    JOIN [dbo].[UKG_EMPLOYEE_DATA] empl
    ON empl.emplid = cte.emplid
WHERE empl.FTE = 0
ORDER BY empl.emplid, empl.position_nbr