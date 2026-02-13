USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_Person_Import_LOOKUP_BUILD]    Script Date: 8/22/2025 7:44:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER       PROCEDURE [stage].[SP_Person_Import_LOOKUP_BUILD]
AS
-- exec [stage].[SP_Person_Import_LOOKUP_BUILD]
BEGIN
    SET NOCOUNT ON;

    -- Drop the table if it exists
    IF OBJECT_ID('BCK.Person_Import_LOOKUP', 'U') IS NOT NULL
    BEGIN
        DROP TABLE BCK.Person_Import_LOOKUP;
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
    INTO BCK.Person_Import_LOOKUP

    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE [Home Business Structure Level 1 - Organization] != 'Non-Health';

    -- Add Loaded_DT column and update with current date
    ALTER TABLE BCK.Person_Import_LOOKUP ADD Loaded_DT DATETIME;
    UPDATE BCK.Person_Import_LOOKUP SET Loaded_DT = GETDATE();

    PRINT 'Table BCK.Person_Import_LOOKUP has been successfully created.';
END
GO


