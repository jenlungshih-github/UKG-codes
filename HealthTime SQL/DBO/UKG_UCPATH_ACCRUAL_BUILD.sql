USE [HealthTime]
GO

/****** Object:  StoredProcedure [dbo].[UKG_UCPATH_ACCRUAL_BUILD]    Script Date: 9/6/2025 4:04:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************
* Created By: May Xu	
* Table: This SP creates table [dbo].UKG_UCPATH_ACCRUAL	to create file accrual_import.csv
  --Extract data from the PS_UC_AM_SS_TBL for the new accruals based upon when the quadriweekly accruals are posted. 	  
  --Accruals are posted to the ODS 8-10 days after the period end date and then posted to the local ODS a day later.
  -- Should extract for all UKG employees who were active in the period that matches the asofdate or are active on the posting date.		
* @param @payenddt DATE: The end date of the pay period for which accruals are being processed.
*                        The ASOFDATE for accruals will be determined relative to this pay period.
* EXEC 	[dbo].[UKG_UCPATH_ACCRUAL_BUILD] @payenddt = '2025-07-05' -- Example date
* -- 05/09/2025 May Xu: Created
* -- 05/22/2025 Jim Shih: UNION stage.UKG_INACTIVE_EMPLID_BY_PAYPERIOD, and change to AM.ASOFDATE BETWEEN DATEADD(day, -13, @payenddt) AND @payenddt   
*-- 7/16/2025 Jim Shih
*-- migrate from hs-ssisp-v
******************************************/	 	 

CREATE OR ALTER        PROCEDURE [dbo].[UKG_UCPATH_ACCRUAL_BUILD]
    @payenddt DATE
AS  

BEGIN

SET NOCOUNT ON;

DROP TABLE IF EXISTS [dbo].UKG_UCPATH_ACCRUAL;
 -- as of date:  The date on which the accrual amount is effective (Today, Current Pay Period Start or Source File Effective Date)

WITH CombinedEmplids AS (
    -- Select active UKG-managed employees
    SELECT DISTINCT EMPLID
    FROM dbo.UKG_EMPLOYEE_DATA
    WHERE NON_UKG_MANAGER_FLAG != 'T'
    
    UNION
    
    -- Select employees identified as inactive or not managed under UKG for the period
    SELECT DISTINCT EMPLID
    FROM stage.UKG_INACTIVE_EMPLID_BY_PAYPERIOD
    -- Assumes UKG_INACTIVE_EMPLID_BY_PAYPERIOD is populated correctly for the @payenddt period
)
SELECT  DISTINCT 
AM.EMPLID AS [Person Number],
AM.PIN_NUM AS [Accrual Code Name],
AM.UC_CURR_BAL AS [Accrual Amount],
AM.ASOFDATE AS [Effective Date]
  INTO [dbo].UKG_UCPATH_ACCRUAL	
  FROM health_ods.[HEALTH_ODS].STABLE.PS_UC_AM_SS_TBL AM
  JOIN CombinedEmplids CE ON AM.EMPLID = CE.EMPLID
  WHERE 	
  1=1 
	AND  AM.PIN_NUM in (262287,260269,260259,260125,260086 ,262342)
	AND  AM.ASOFDATE BETWEEN DATEADD(day, -13, @payenddt) AND @payenddt
;
END


GO


