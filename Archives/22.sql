SELECT
    emplid,
    acct_cd,
    -- Add employee name for reference
    CASE 
        WHEN emplid = '10400284' THEN 'Stacey Williams'
        WHEN emplid = '10404558' THEN 'Laura Yoshida'
        WHEN emplid = '10406748' THEN 'Nikki Adlaon'
        WHEN emplid = '10407166' THEN 'Celica Ramirez'
        WHEN emplid = '10414234' THEN 'Vivika Wax'
        WHEN emplid = '10416759' THEN 'Rosario Quismorio'
        WHEN emplid = '10421273' THEN 'Jennifer Lasher'
        WHEN emplid = '10455515' THEN 'Amanda Booker'
        WHEN emplid = '10467173' THEN 'Laura Kinney'
        WHEN emplid = '10545156' THEN 'Yaritza Alcazar'
        WHEN emplid = '10557432' THEN 'Martha Herrick'
        WHEN emplid = '10733777' THEN 'Daryl Soriano'
        WHEN emplid = '10755336' THEN 'Holly Haynes'
        WHEN emplid = '10800937' THEN 'Melanie Carrasco'
        ELSE 'Unknown'
    END AS Employee_Name
FROM health_ods.[health_ods].hcm_ods.PS_DEPT_BUDGET_ERN
WHERE 
    EMPLID IN (
        '10400284', -- Stacey Williams
        '10404558', -- Laura Yoshida
        '10406748', -- Nikki Adlaon
        '10407166', -- Celica Ramirez
        '10414234', -- Vivika Wax
        '10416759', -- Rosario Quismorio
        '10421273', -- Jennifer Lasher
        '10455515', -- Amanda Booker
        '10467173', -- Laura Kinney
        '10545156', -- Yaritza Alcazar
        '10557432', -- Martha Herrick
        '10733777', -- Daryl Soriano
        '10755336', -- Holly Haynes
        '10800937'  -- Melanie Carrasco
    )
ORDER BY emplid, acct_cd;