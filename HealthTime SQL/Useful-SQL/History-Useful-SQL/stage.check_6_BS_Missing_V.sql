USE [HealthTime]
GO

CREATE VIEW [stage].[check_6_BS_Missing_V]
AS
    SELECT
        [Person Number]
          , [First Name]
          , [Last Name]
		  , [Home Business Structure Level 1 - Organization]
		  , [Home Business Structure Level 2 - Entity]
		  , [Home Business Structure Level 3 - Service Line]
		  , [Home Business Structure Level 4 - Financial Unit]
    	  , [Home Business Structure Level 5 - Fund Group]
          , [Home Business Structure Level 1 - Organization] + '/' +
          [Home Business Structure Level 2 - Entity] + '/' +
          [Home Business Structure Level 3 - Service Line] + '/' +
          [Home Business Structure Level 4 - Financial Unit] + '/' +
          [Home Business Structure Level 5 - Fund Group] AS [Parent Path]
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE [Home Business Structure Level 1 - Organization] != 'Non-Health'
        AND emplid IN (
    '10420386', '10467173', '10703043', '10703234', '10403560', '10406748'
)
GO
