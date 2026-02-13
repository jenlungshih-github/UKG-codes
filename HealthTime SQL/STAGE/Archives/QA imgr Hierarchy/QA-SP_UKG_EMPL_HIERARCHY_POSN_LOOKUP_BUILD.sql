CREATE OR ALTER PROCEDURE [stage].[SP_UKG_EMPL_HIERARCHY_POSN_LOOKUP_BUILD]
AS
-- EXEC [stage].[SP_UKG_EMPL_HIERARCHY_POSN_LOOKUP_BUILD]
BEGIN
    SET NOCOUNT ON;

    -- Drop and recreate the table to ensure correct structure
    IF OBJECT_ID('[stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]', 'U') IS NOT NULL
    BEGIN
        DROP TABLE [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP];
    END

    CREATE TABLE [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]
    (
        emplid VARCHAR(11),
        POSITION_NBR VARCHAR(11),
        HR_STATUS VARCHAR(1),
        LEVEL VARCHAR(20),
        UPDATED_DT DATETIME
    );

    INSERT INTO [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]
        (
        emplid,
        POSITION_NBR,
        HR_STATUS,
        LEVEL,
        UPDATED_DT
        )
    SELECT
        empl.emplid,
        empl.POSITION_NBR,
        empl.HR_STATUS,
        HPOSN.LEVEL,
        GETDATE() AS UPDATED_DT
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        JOIN health_ods.[health_ods].[RPT].ORG_HIERARCHY_POSN HPOSN
        ON HPOSN.EMPLID = EMPL.EMPLID
            AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
    WHERE HPOSN.LEVEL IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9', 'LEVEL10');
END
GO