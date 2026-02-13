SELECT distinct
    UKG.emplid,
    UKG.position_nbr,
    FIN.FDM_COMBO_CD,
    -- Add employee name for reference
    CASE 
        WHEN UKG.emplid = '10400284' THEN 'Stacey Williams'
        WHEN UKG.emplid = '10404558' THEN 'Laura Yoshida'
        WHEN UKG.emplid = '10406748' THEN 'Nikki Adlaon'
        WHEN UKG.emplid = '10407166' THEN 'Celica Ramirez'
        WHEN UKG.emplid = '10414234' THEN 'Vivika Wax'
        WHEN UKG.emplid = '10416759' THEN 'Rosario Quismorio'
        WHEN UKG.emplid = '10421273' THEN 'Jennifer Lasher'
        WHEN UKG.emplid = '10455515' THEN 'Amanda Booker'
        WHEN UKG.emplid = '10467173' THEN 'Laura Kinney'
        WHEN UKG.emplid = '10545156' THEN 'Yaritza Alcazar'
        WHEN UKG.emplid = '10557432' THEN 'Martha Herrick'
        WHEN UKG.emplid = '10733777' THEN 'Daryl Soriano'
        WHEN UKG.emplid = '10755336' THEN 'Holly Haynes'
        WHEN UKG.emplid = '10800937' THEN 'Melanie Carrasco'
        ELSE 'Unknown'
    END AS Employee_Name
FROM [dbo].[UKG_EMPLOYEE_DATA] UKG
    LEFT JOIN (
        SELECT
        position_nbr,
        FDM_COMBO_CD,
        POSN_SEQ,
        ROW_NUMBER() OVER (PARTITION BY position_nbr ORDER BY POSN_SEQ ASC) as rn
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
    ) FIN
    ON UKG.position_nbr = FIN.position_nbr AND FIN.rn = 1
WHERE 
    UKG.emplid IN (
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
ORDER BY UKG.emplid;