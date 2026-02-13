PRINT '2. Checking BYA exclusion (CTE_exclude_BYA) for provided EMPLIDs...';

DECLARE @EMPS TABLE (EMPLID VARCHAR(11));
INSERT INTO @EMPS
    (EMPLID)
VALUES
    ('10359068'),
    ('10402146'),
    ('10403533'),
    ('10404645'),
    ('10406712'),
    ('10407426'),
    ('10410053'),
    ('10414205'),
    ('10416477'),
    ('10417138'),
    ('10417845'),
    ('10418983'),
    ('10422981'),
    ('10423468'),
    ('10423688'),
    ('10425303'),
    ('10425387'),
    ('10427131'),
    ('10538231'),
    ('10541159'),
    ('10556893'),
    ('10575664'),
    ('10642177'),
    ('10652962'),
    ('10672825'),
    ('10859360');

SELECT
    e.EMPLID,
    CASE WHEN pj.EMPLID IS NOT NULL THEN 'EXCLUDED' ELSE 'NOT_EXCLUDED' END AS BYA_STATUS,
    pj.SAL_ADMIN_PLAN,
    pj.FLSA_STATUS,
    pj.JOB_INDICATOR,
    pj.DML_IND,
    pj.EFFDT
FROM @EMPS e
OUTER APPLY (
    SELECT TOP 1
        H.emplid, H.SAL_ADMIN_PLAN, H.FLSA_STATUS, H.JOB_INDICATOR, H.DML_IND, H.EFFDT
    FROM health_ods.[health_ods].[stable].PS_JOB H
    WHERE H.emplid = e.EMPLID
        AND H.JOB_INDICATOR = 'P'
        AND H.DML_IND <> 'D'
        AND H.SAL_ADMIN_PLAN = 'BYA'
    ORDER BY H.EFFDT DESC
) pj
ORDER BY e.EMPLID;