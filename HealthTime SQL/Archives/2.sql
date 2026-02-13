SELECT E.emplid
FROM [HEALTH_ODS].[STABLE].ps_job E
    JOIN [HEALTH_ODS].[STABLE].ps_job H ON E.emplid = H.emplid
WHERE  
E.emplid IS NOT NULL and
    (H.SAL_ADMIN_PLAN <> 'BYA' OR H.FLSA_STATUS <> 'E')

