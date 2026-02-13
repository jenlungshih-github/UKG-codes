SELECT
    S.[Person Number]
      , S.[First Name]
      , S.[Last Name]
      , S.[Middle Initial/Name]
      , S.[Short Name]
      , S.[Badge Number]
      , S.[Hire Date]
      , S.[Birth Date]
      , S.[Seniority Date]
      , S.[Manager Flag]
      , S.[Phone 1]
      , S.[Phone 2]
      , '' as [Email]  --make email blank until ready for testing
      , S.[Address]
      , S.[City]
      , S.[State]
      , S.[Postal Code]
      , S.[Country]
      , S.[Time Zone]
      , 'T' as [Employment Status]
      , S.[snapshot_date] as [Employment Status Effective Date]
      , S.[Reports to Manager]
      , S.[Union Code]
      , S.[Employee Type]
      , S.[Employee Classification]
      , S.[Pay Frequency]
      , S.[Worker Type]
      , S.[FTE %]
      , S.[FTE Standard Hours]
      , S.[FTE Full Time Hours]
      , S.[Standard Hours - Daily]
      , S.[Standard Hours - Weekly]
      , S.[Standard Hours - Pay Period]
      , S.[Base Wage Rate]
      , S.[Base Wage Rate Effective Date]
      , S.[User Account Name]
      , S.[User Account Status]
      , S.[User Password]
      , S.[Home Business Structure Level 1 - Organization]
      , S.[Home Business Structure Level 2 - Entity]
      , S.[Home Business Structure Level 3 - Service Line]
      , S.[Home Business Structure Level 4 - Financial Unit]
      , S.[Home Business Structure Level 5 - Fund Group]
      , S.[Home Business Structure Level 6]
      , S.[Home Business Structure Level 7]
      , S.[Home Business Structure Level 8]
      , S.[Home Business Structure Level 9]
      , S.[Home/Primary Job]
      , S.[Home Labor Category Level 1]
      , S.[Home Labor Category Level 2]
      , S.[Home Labor Category Level 3]
      , S.[Home Labor Category Level 4]
      , S.[Home Labor Category Level 5]
      , S.[Home Labor Category Level 6]
      , S.[Home Job and Labor Category Effective Date]
      , S.[Custom Field 1]
      , S.[Custom Field 2]
      , S.[Custom Field 3]
      , S.[Custom Field 4]
      , S.[Custom Field 5]
      , S.[Custom Field 6]
      , S.[Custom Field 7]
      , S.[Custom Field 8]
      , S.[Custom Field 9]
      , S.[Custom Field 10]
      , S.[Custom Date 1] -- re-order after [Custom Field 10]
      , S.[Custom Date 2]
      , S.[Custom Date 3]
      , S.[Custom Date 4]
      , S.[Custom Date 5]
      , S.[Custom Field 11]
      , S.[Custom Field 12]
      , S.[Custom Field 13]
	  , S.[Custom Field 14]
	  , S.[Custom Field 15]
      , S.[Custom Field 16]
      , S.[Custom Field 17]
      , S.[Custom Field 18]
	  , S.[Custom Field 19]
	  , S.[Custom Field 20]
	  , S.[Custom Field 21]
	  , S.[Custom Field 22]
	  , S.[Custom Field 23]
	  , S.[Custom Field 24]
	  , S.[Custom Field 25]
	  , S.[Custom Field 26]
	  , S.[Custom Field 27]
	  , S.[Custom Field 28]
	  , S.[Custom Field 29]
	  , S.[Custom Field 30]
      , S.[Additional Fields for CRT lookups]
FROM [stage].[EMPL_DEPT_TRANSFER] T
    JOIN [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] S
    ON T.EMPLID=S.EMPLID
WHERE 
S.NOTE='D'
    and
    T.NOTE='New';

-- Update S.NOTE from 'D' to 'T' and T.NOTE from 'New' to 'Processed'
UPDATE S
SET S.NOTE = 'T'
FROM [stage].[EMPL_DEPT_TRANSFER] T
    JOIN [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] S
    ON T.EMPLID = S.EMPLID
WHERE S.NOTE = 'D' AND T.NOTE = 'New';

UPDATE T
SET T.NOTE = 'Processed'
FROM [stage].[EMPL_DEPT_TRANSFER] T
    JOIN [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] S
    ON T.EMPLID = S.EMPLID
WHERE S.NOTE = 'T' AND T.NOTE = 'New';