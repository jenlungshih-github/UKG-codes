
SELECT
    [Person Number]
          , [First Name]
          , [Last Name]
		  , [Home Business Structure Level 1 - Organization]
		  , [Home Business Structure Level 2 - Entity]
		  , [Home Business Structure Level 3 - Service Line]
		  , [Home Business Structure Level 4 - Financial Unit]
    	  , [Home Business Structure Level 5 - Fund Group]
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE [Home Business Structure Level 1 - Organization] = ''
    AND [Home Business Structure Level 2 - Entity] = ''
    AND [Home Business Structure Level 3 - Service Line] = ''
    AND [Home Business Structure Level 4 - Financial Unit] = ''
    AND [Home Business Structure Level 5 - Fund Group] = ''