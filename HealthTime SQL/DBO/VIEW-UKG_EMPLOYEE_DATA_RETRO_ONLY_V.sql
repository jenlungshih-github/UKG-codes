USE [HealthTime]
GO

/****** Object:  View [dbo].[UKG_EMPLOYEE_DATA_RETRO_ONLY_V]    Script Date: 7/15/2025 6:51:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--SELECT * 
--FROM [dbo].[UKG_EMPLOYEE_DATA_RETRO_ONLY_V]





/***************************************
* Created By: May Xu	
* This view is used to create the employee data file to UKG	 	
* -- 05/02/2025 May Xu: Created
* -- 06/09/2025 Jim Shih: 
-- re-order after [Custom Field 10]
--Add more columns [Custom Field 16] to [Custom Field 30]
*-- 06/18/2025 Jim Shih:
Per JK, change the heading for the Fund Group from Home Business Structure Level 5 - TSG to Home Business Structure Level 5 - Fund Group
*-- 07/03/2025 Jim Shih
In the meeting, make email blank until ready for testing
*-- 7/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- changed FROM [Health_ODS].[dbo].[UKG_EMPLOYEE_DATA] to dbo.[UKG_EMPLOYEE_DATA]
*******************************************/

Create or ALTER       VIEW [dbo].[UKG_EMPLOYEE_DATA_RETRO_ONLY_V]
AS

    SELECT Distinct
        [Person Number]
      , [First Name]
      , [Last Name]
      , [Middle Initial/Name]
      , [Short Name]
      , [Badge Number]
      , [Hire Date]
      , [Birth Date]
      , [Seniority Date]
      , [Manager Flag]
      , [Phone 1]
      , [Phone 2]
      , '' as [Email]  --make email blank until ready for testing
      , [Address]
      , [City]
      , [State]
      , [Postal Code]
      , [Country]
      , [Time Zone]
      , [Employment Status]
      , [Employment Status Effective Date]
      , [Reports to Manager]
      , [Union Code]
      , [Employee Type]
      , [Employee Classification]
      , [Pay Frequency]
      , [Worker Type]
      , [FTE %]
      , [FTE Standard Hours]
      , [FTE Full Time Hours]
      , [Standard Hours - Daily]
      , [Standard Hours - Weekly]
      , [Standard Hours - Pay Period]
      , [Base Wage Rate]
      , [Base Wage Rate Effective Date]
      , [User Account Name]
      , [User Account Status]
      , [User Password]
      , [Home Business Structure Level 1 - Organization]
      , [Home Business Structure Level 2 - Entity]
      , [Home Business Structure Level 3 - Service Line]
      , [Home Business Structure Level 4 - Financial Unit]
      , [Home Business Structure Level 5 - Fund Group]
      , [Home Business Structure Level 6]
      , [Home Business Structure Level 7]
      , [Home Business Structure Level 8]
      , [Home Business Structure Level 9]
      , [Home/Primary Job]
      , [Home Labor Category Level 1]
      , [Home Labor Category Level 2]
      , [Home Labor Category Level 3]
      , [Home Labor Category Level 4]
      , [Home Labor Category Level 5]
      , [Home Labor Category Level 6]
      , [Home Job and Labor Category Effective Date]
      , [Custom Field 1]
      , [Custom Field 2]
      , [Custom Field 3]
      , [Custom Field 4]
      , [Custom Field 5]
      , [Custom Field 6]
      , [Custom Field 7]
      , [Custom Field 8]
      , [Custom Field 9]
      , [Custom Field 10]
      , [Custom Date 1] -- re-order after [Custom Field 10]
      , [Custom Date 2]
      , [Custom Date 3]
      , [Custom Date 4]
      , [Custom Date 5]
      , [Custom Field 11]
      , [Custom Field 12]
      , [Custom Field 13]
	  , [Custom Field 14]
	  , [Custom Field 15]
      , [Custom Field 16]
      , [Custom Field 17]
      , [Custom Field 18]
	  , [Custom Field 19]
	  , [Custom Field 20]
	  , [Custom Field 21]
	  , [Custom Field 22]
	  , [Custom Field 23]
	  , [Custom Field 24]
	  , [Custom Field 25]
	  , [Custom Field 26]
	  , [Custom Field 27]
	  , [Custom Field 28]
	  , [Custom Field 29]
	  , [Custom Field 30]
      , [Additional Fields for CRT lookups]
    --    FROM dbo.[UKG_EMPLOYEE_DATA] 
    FROM BCK.[UKG_EMPLOYEE_DATA_V_SNAPSHOT_2025-10-21] A
        JOIN [stage].[UKG_EMPL_STATUS_LOOKUP_RETRO_ONLY] B
        ON A.[Person Number]=B.emplid
    WHERE [Person Number]= '10664090'
GO


