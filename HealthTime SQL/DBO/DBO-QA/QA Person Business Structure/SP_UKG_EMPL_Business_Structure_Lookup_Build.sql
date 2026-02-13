Create or ALTER       PROCEDURE [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build]
AS
-- exec [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build]
BEGIN
    SET NOCOUNT ON;

    -- Drop the table if it exists
    IF OBJECT_ID('stage.UKG_EMPL_Business_Structure', 'U') IS NOT NULL
    BEGIN
        DROP TABLE stage.UKG_EMPL_Business_Structure;
    END

    -- Create the lookup table
    SELECT --top 10
        [Person Number]
          , [First Name]
          , [Last Name]
    	  , [Home Business Structure Level 5 - Fund Group] as FundGroup
          , [Home Business Structure Level 1 - Organization] + '/' +
          [Home Business Structure Level 2 - Entity] + '/' +
          [Home Business Structure Level 3 - Service Line] + '/' +
          [Home Business Structure Level 4 - Financial Unit] + '/' +
          [Home Business Structure Level 5 - Fund Group] AS [Parent Path]
    INTO stage.UKG_EMPL_Business_Structure

    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE [Home Business Structure Level 1 - Organization] != 'Non-Health';

    -- Add Loaded_DT column and update with current date
    ALTER TABLE stage.UKG_EMPL_Business_Structure ADD Loaded_DT DATETIME;
    UPDATE stage.UKG_EMPL_Business_Structure SET Loaded_DT = GETDATE();

    PRINT 'Table stage.UKG_EMPL_Business_Structure has been successfully created.';
END
GO