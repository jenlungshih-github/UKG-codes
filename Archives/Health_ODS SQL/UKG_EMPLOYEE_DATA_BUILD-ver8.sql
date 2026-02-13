USE [Health_ODS]
GO

/****** Object:  StoredProcedure [stage].[UKG_EMPLOYEE_DATA_BUILD]    Script Date: 5/13/2025 6:59:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/***************************************
* Created By: May Xu	
* Table: This SP creates table [STAGE].[UKG_EMPLOYEE_DATA]	to upload the employee data file to UKG
* EXEC 	[STAGE].UKG_EMPLOYEE_DATA_BUILD	
* -- 04/04/2025 May Xu: Created
* -- 04/21/2025 May Xu:Added default value 'Blank' for required fields
* -- 04/23 2025 May Xu:Vacant manager level only go up to level 5
* -- 05/02/2025 May Xu: added Custom Field 14	and Custom Field 15
* -- 05/05/2025 May Xu: Changed to only add the non-ukg manager's primary job ; 
* -- 06/09/2025 Jim Shih: Replace the following,
		--ISNULL(EMPL.HR_STATUS, '') AS 'Employment Status', 
		ISNULL(EMPL.empl_Status, '') AS 'Employment Status', -- Replace EMPL.HR_STATUS with EMPL.empl_Status
        --CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.EMPL_STATUS END AS 'Custom Field 5',
		ISNULL(EMPL.HR_STATUS, '') AS 'Custom Field 5',
		--''  AS 'Custom Date 4',
		ISNULL(CAST(EMPL.EFFDT AS VARCHAR), '') AS 'Custom Date 4',
*-- 06/09/2025 Jim Shih: Change the logic of Employee Classification
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     WHEN EMPL.FLSA_STATUS = 'V' THEN 'N' 		     
			 ELSE EMPL.FLSA_STATUS END  AS 'Employee Classification',
			 
*-- 06/09/2025 Jim Shih: Update [Custom Field 17] in [stage].[UKG_EMPLOYEE_DATA]
UPDATE [stage].[UKG_EMPLOYEE_DATA]
SET [Custom Field 17] = B.differncds
FROM [stage].[UKG_EMPLOYEE_DATA] T
INNER JOIN [stage].[UKG_tsr_differncds_V] B
ON T.emplid = B.emplid AND T.jobcode = B.jobcode;	
*-- 06/10/2025 Jim Shih: 		 
        ISNULL(CAST(UKG_ES.EFFDT AS VARCHAR), '')  AS 'Employment Status Effective Date',   -- Replace EMPL.EFFDT with UKG_ES.EFFDT  
*-- 06/18/2025 Jim Shih:
Per JK, change the heading for the Fund Group from Home Business Structure Level 5 - TSG to Home Business Structure Level 5 - Fund Group	
*-- 07/07/2025 Jim Shih:	
Custom Date Field 1 is the Probation Date and if the probation date is not found it should be filled with the hire date
	
		
 UCSDH will keep full archival of files with date attached on our side for 6 months and keep table for 1 month
 ******************************************/	 	 

CREATE OR ALTER  PROCEDURE [stage].[UKG_EMPLOYEE_DATA_BUILD]
AS  

BEGIN 

-- UKG Employee population (Primary Job only):
DROP TABLE IF EXISTS STAGE.UKG_EMPL_E_T;

SELECT  DISTINCT 'F' AS 'NON_UKG_MANAGER_FLAG', 	EMPL.* 
 INTO STAGE.UKG_EMPL_E_T	
 FROM RPT.CURRENT_EMPL_DATA	EMPL
WHERE 	1=1 
  AND EMPL.JOB_INDICATOR = 'P'   
  AND (EMPL.VC_CODE = 'VCHSH'   	 --MED CENTER
       OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
       )
  AND ((EMPL.hr_status = 'A' 	) 	 -- active empl
       OR  (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE()))	 --terminated empl today
	   )
  AND PAY_FREQUENCY = 'B'	
  AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
  AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )	--exclude ARC MSP POPULATION

 -- update MANAGER_EMPLID to next higher level (up to level 5) if manager is not found 
 UPDATE STAGE.UKG_EMPL_E_T	
   SET 	 MANAGER_EMPLID	   =
  CASE    WHEN   HPOSN.LEVEL = 'LEVEL6' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL7' AND MANAGER6_EMPLID != ''  THEN MANAGER6_EMPLID
	      WHEN   HPOSN.LEVEL = 'LEVEL7' AND MANAGER6_EMPLID = '' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
	      WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID != ''THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID = '' AND  MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID = ''  AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID != '' THEN MANAGER8_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND  MANAGER7_EMPLID != '' THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = ''  AND MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = ''  AND MANAGER6_EMPLID = ''  AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID != '' THEN MANAGER9_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND  MANAGER8_EMPLID != '' THEN MANAGER8_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND  MANAGER7_EMPLID != '' THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = ''  AND MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = ''  AND MANAGER6_EMPLID = ''  AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID			  
 ELSE   COALESCE(EMPL.MANAGER_EMPLID, '') END	
FROM STAGE.UKG_EMPL_E_T	  EMPL
	INNER JOIN  RPT.ORG_HIERARCHY_POSN	  HPOSN
  ON HPOSN.EMPLID = EMPL.EMPLID
 AND HPOSN.EMPL_RCD	= EMPL.EMPL_RCD
 AND EMPL.MANAGER_EMPLID IS NULL 	   

 -- Manager outside of UKG
DROP TABLE IF EXISTS STAGE.UKG_EMPL_M_T; 

SELECT DISTINCT 'T' AS 'NON_UKG_MANAGER_FLAG', 	EMPL.* 
  INTO STAGE.UKG_EMPL_M_T
 FROM RPT.CURRENT_EMPL_DATA EMPL,
      STAGE.UKG_EMPL_E_T UKG
WHERE EMPL.EMPLID = UKG.MANAGER_EMPLID
  and EMPL.JOB_INDICATOR = 'P'
  AND EMPL.EMPLID NOT IN (SELECT DISTINCT EMPLID FROM  STAGE.UKG_EMPL_E_T)
  AND EMPL.HR_STATUS = 'A'

 -- combine UKG Empl and UKG Manager
DROP TABLE IF EXISTS STAGE.UKG_EMPL_T;

SELECT * 
 INTO STAGE.UKG_EMPL_T
 FROM (
       SELECT * FROM STAGE.UKG_EMPL_E_T
        UNION
       SELECT * FROM STAGE.UKG_EMPL_M_T ) TEMP


 CREATE INDEX UKG_EMPL_T_IDX_1 ON [HEALTH_ODS].STAGE.UKG_EMPL_T  (EMPLID);
 CREATE INDEX UKG_EMPL_T_IDX_2 ON [HEALTH_ODS].STAGE.UKG_EMPL_T  (POSITION_NBR);

 --	 Get combocode 
DROP TABLE IF EXISTS STAGE.UKG_COMBOCD_T;
SELECT   FIN.POSITION_NBR,	MIN(FIN.POSN_SEQ)  AS MIN_POSN_SEQ
  INTO STAGE.UKG_COMBOCD_T
  FROM    HEALTH_ODS.[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]  FIN ,
		[ECOTIME_RPT].[TEST].[TSR_BUSINESSSTRUCTURE_GET] ()  UKG_BS
 WHERE  UKG_BS.COMBOCODE =  FIN.FDM_COMBO_CD  --AND   FIN.POSITION_NBR = 	'40776608'
GROUP BY  FIN.POSITION_NBR

      

  -- UKG Empl FTE:  if employee's primary job is health, combine all active FTE, capped at 1.0 FTE. Note: if primary job is campus, then EE wont be in UKG. 
DROP TABLE IF EXISTS STAGE.UKG_EMPL_FTE_T;
 SELECT EMPL.EMPLID, 
        SUM(EMPL.FTE)	AS FTE_SUM
   INTO STAGE.UKG_EMPL_FTE_T	
   FROM STAGE.UKG_EMPL_T UKG_EMPL,
        RPT.CURRENT_EMPL_DATA	EMPL
  WHERE 1=1 
    AND EMPL.EMPLID = UKG_EMPL.EMPLID
    AND EMPL.HR_STATUS = 'A'
  GROUP BY EMPL.EMPLID

  -- Empl Hr rate effdt : Cycle thru previous job rows to determine when last pay rate change was; use efft date from that change
DROP TABLE IF EXISTS STAGE.UKG_EMPL_HRATE_EFFDT_T;	
SELECT H.EMPLID,
       H.HOURLY_RT,	      
	   H.EFFDT , 
	   H.UPD_BT_DTM ,
	   ROW_NUMBER() OVER (
            PARTITION BY H.EMPLID 
            ORDER BY H.EFFDT ASC, UPD_BT_DTM DESC ) AS RN	 
 INTO  STAGE.UKG_EMPL_HRATE_EFFDT_T
 FROM STABLE.PS_JOB H,  STAGE.UKG_EMPL_T  L    
WHERE H.EMPLID = L.EMPLID				
  AND H.EMPL_RCD = L.EMPL_RCD
  AND H.HOURLY_RT = L.HOURLY_RT
  AND H.JOB_INDICATOR = 'P'
  AND H.DML_IND <> 'D'
  --AND H.HR_STATUS = 'A'		 -- HOW ABOUT INACTIVE ???

 -- Final table with UKG Business Structure 
 DROP TABLE IF EXISTS   [STAGE].[UKG_EMPLOYEE_DATA]
	 --UKG_JC.JobGroup, ukg_bs.FundGroup needed 
 SELECT	distinct  
        EMPL.DEPTID,	
	    empl.VC_CODE,	 
        fin.FDM_COMBO_CD ,
	    UKG_BS.COMBOCODE,	
	    empl.REPORTS_TO,   
		empl.MANAGER_EMPLID,	
		[NON_UKG_MANAGER_FLAG],  -- need this one accural
	    empl.position_nbr,
	    EMPL.EMPLID , 
		empl.EMPL_RCD,
		empl.jobcode,
		empl.POSITION_DESCR,
	    empl.hr_status,	
	    UKG_FTE.FTE_SUM, 
	    empl.fte,	
	    empl.empl_Status, 	-- all the above columns for testing only	
	    UKG_JC.JobGroup, ukg_bs.FundGroup ,  -- added for the Location BS file
        ISNULL(EMPL.EMPLID, '')  AS 'Person Number',         
        EMPL.LIVED_FIRST_NAME  AS 'First Name',
        ISNULL(CAST(EMPL.LAST_NAME AS VARCHAR), '') AS 'Last Name',
        LEFT(EMPL.LIVED_MIDDLE_NAME,1)  AS 'Middle Initial/Name',
        ''  AS 'Short Name',				
        ''  AS 'Badge Number',
        ISNULL(CAST(EMPL.HIRE_DT AS VARCHAR), '')  AS 'Hire Date',
        ''  AS 'Birth Date',
        ''  AS 'Seniority Date',	  
        CASE WHEN M.MANAGER_EMPLID IS NOT NULL THEN 'T' ELSE 'F' END  AS 'Manager Flag',	
        COALESCE(REPLACE(PH1.phone, '/', '-'), '')   AS 'Phone 1',
        COALESCE(REPLACE(PH2.phone, '/', '-'), '')   AS  'Phone 2',  		
        CASE WHEN VC_CODE IN ('VCHSH', 'VCHSS') THEN REPLACE(EMPL.BUSN_EMAIL_ADDR, '@ucsd.edu', '@health.ucsd.edu') 
		     ELSE EMPL.BUSN_EMAIL_ADDR END AS 'Email',	
        ''  AS 'Address',
        ''  AS 'City',
        ''  AS 'State',
        ''  AS 'Postal Code',
        ''  AS 'Country',
        'Pacific'  AS 'Time Zone',
--	    ISNULL(EMPL.HR_STATUS, '') AS 'Employment Status', 
		ISNULL(UKG_ES.empl_Status, '') AS 'Employment Status', -- Replace EMPL.HR_STATUS with EMPL.empl_Status
        ISNULL(CAST(UKG_ES.EFFDT AS VARCHAR), '')  AS 'Employment Status Effective Date',   -- Replace EMPL.EFFDT with UKG_ES.EFFDT     
		CASE  WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		      ELSE   COALESCE(EMPL.MANAGER_EMPLID, '') END	 AS 'Reports to Manager', 

		CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE EMPL.UNION_CD  END AS 'Union Code',	
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE EMPL.EMPL_TYPE END AS 'Employee Type',	  
-- New Logic of Employee Classification		
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN 'C'  -- OLD logic WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     WHEN EMPL.FLSA_STATUS = 'V' THEN 'N' 		     
			 ELSE EMPL.FLSA_STATUS END  AS 'Employee Classification',	
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE EMPL.PAY_FREQUENCY END  AS 'Pay Frequency',       
		CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     WHEN  EMPL.EMPL_CLASS = 6 THEN 'PD'	   
		     --WHEN  EMPL.EMPL_CLASS != 6 AND ((EMPL.HR_STATUS = 'I' AND EMPL.FTE >= 1) OR (EMPL.HR_STATUS = 'A' AND UKG_FTE.FTE_SUM >= 1))  THEN 'FT'
			-- WHEN  EMPL.EMPL_CLASS != 6 AND ((EMPL.HR_STATUS = 'I' AND EMPL.FTE < 1) OR (EMPL.HR_STATUS = 'A' AND UKG_FTE.FTE_SUM < 1))  THEN 'PT'
			WHEN  EMPL.EMPL_CLASS != 6 AND UKG_FTE.FTE_SUM >= 1  THEN 'FT'
			WHEN  EMPL.EMPL_CLASS != 6 AND  UKG_FTE.FTE_SUM < 1  THEN 'PT'
		     ELSE EMPL.EMPL_CLASS  END AS 'Worker Type', 		
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     WHEN EMPL.HR_STATUS = 'I' THEN  CAST(CAST(EMPL.FTE * 100 AS NUMERIC(8,0))  AS VARCHAR)
		     WHEN UKG_FTE.FTE_SUM >1  THEN '100' 		--  EMPL.HR_STATUS = 'A' AND  ??? 	 test  			 
			 ELSE CAST(CAST(UKG_FTE.FTE_SUM * 100 AS NUMERIC(8,0))  AS VARCHAR)     END AS 'FTE %',	 
        ''   AS 'FTE Standard Hours',
        ''   AS 'FTE Full Time Hours',
        ''   AS 'Standard Hours - Daily',
        ''   AS 'Standard Hours - Weekly',
        ''   AS 'Standard Hours - Pay Period',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE CAST( CAST(EMPL.HOURLY_RT AS NUMERIC(8,2)) AS VARCHAR) END AS 'Base Wage Rate',		
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE ISNULL(CAST( HEFFDT.EFFDT AS VARCHAR), '') END AS 'Base Wage Rate Effective Date',	   
        EMPL.EMPLID  AS 'User Account Name',        
		CASE WHEN EMPL.EMPL_STATUS  in ('P', 'A')  THEN 'A'	            
		     ELSE 'I' END AS 'User Account Status',		
        ''   AS 'User Password',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T'  THEN 'Non-Health' 		     
			 ELSE ISNULL(UKG_BS.Organization, '') END AS 'Home Business Structure Level 1 - Organization',	 
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T'  THEN '-' 		     
		     ELSE ISNULL(UKG_BS.EntityTitle, '')  END  AS 'Home Business Structure Level 2 - Entity',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T'  THEN '-'		    
		     ELSE  ISNULL(UKG_BS.ServiceLineTitle, '')  END  AS 'Home Business Structure Level 3 - Service Line',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '-' 
		     ELSE  ISNULL(UKG_BS.FinancialUnit, '')  END  AS 'Home Business Structure Level 4 - Financial Unit',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T'  THEN '-' 
		     ELSE  ISNULL(UKG_BS.FundGroup, '')  END  AS 'Home Business Structure Level 5 - Fund Group',
        ''  AS 'Home Business Structure Level 6',
        ''  AS 'Home Business Structure Level 7',
        ''  AS 'Home Business Structure Level 8',
        ''  AS 'Home Business Structure Level 9',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN 'NHRPT' ELSE ISNULL(UKG_JC.Jobgroup, '')   END AS 'Home/Primary Job',	  
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE ISNULL(EMPL.POSITION_NBR +  '_' + CONVERT(VARCHAR, EMPL.EMPL_RCD), '') END AS 'Home Labor Category Level 1',		   
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE ISNULL(EMPL.JOBCODE, '')  END AS 'Home Labor Category Level 2',	-- primary jobcode
        ''  AS 'Home Labor Category Level 3',
        ''  AS 'Home Labor Category Level 4',
        ''  AS 'Home Labor Category Level 5',
        ''  AS 'Home Labor Category Level 6',
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE ISNULL(CAST(EMPL.EFFDT AS VARCHAR), '') END  AS 'Home Job and Labor Category Effective Date',	   --Job EFFDT current date, or current pay period start date?
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.GP_ELIG_GRP END  AS 'Custom Field 1',	   --	empl.GP_ELIG_GRP?
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.empl_class END   AS 'Custom Field 2',
        ''  AS 'Custom Field 3',
        --CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.PAYGROUP  END AS 'Custom Field 4',
		ISNULL(CAST(EMPL.EFFDT AS VARCHAR), '')  AS 'Custom Field 4',
        --CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.EMPL_STATUS END AS 'Custom Field 5',
		ISNULL(EMPL.HR_STATUS, '') AS 'Custom Field 5',
        ''  AS 'Custom Field 6',	
        ''  AS 'Custom Field 7',	
        ''  AS 'Custom Field 8',	
        ''  AS 'Custom Field 9',   --	 ?
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN '' ELSE empl.UNION_CD  END AS 'Custom Field 10',  -- done
-- Re-order Custom date
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
        		     WHEN NON_UKG_MANAGER_FLAG = 'F' AND PROBATION_CODE = 'P' THEN ISNULL(CAST(EMPL.PROB_END_DT AS VARCHAR), CAST(EMPL.HIRE_DT AS VARCHAR))
        			 ELSE ISNULL(CAST(EMPL.HIRE_DT AS VARCHAR), '') END AS 'Custom Date 1', --Custom Date Field 1 is the Probation Date and if the probation date is not found it should be filled with the hire date
        CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     ELSE ISNULL(CAST(EMPL.LAST_HIRE_DT AS VARCHAR), '')  END AS 'Custom Date 2',
        ''  AS 'Custom Date 3',
		--''  AS 'Custom Date 4',
		ISNULL(CAST(EMPL.EFFDT AS VARCHAR), '') AS 'Custom Date 4',
        ''  AS 'Custom Date 5',		
		''  AS 'Custom Field 11',   --   person type phase 1 blank, phase2 use per_org
		''  AS 'Custom Field 12',         
		''  AS 'Custom Field 13',	 -- done	 -- import date	 later
		CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''		     		 
			 ELSE CAST(CAST(EMPL.FTE * 100 AS NUMERIC(8,0))  AS VARCHAR)     END AS 'Custom Field 14',	
	   CASE WHEN NON_UKG_MANAGER_FLAG = 'T' THEN ''
		     WHEN EMPL.HR_STATUS = 'I' THEN  CAST(CAST(EMPL.FTE * 100 AS NUMERIC(8,0))  AS VARCHAR)
		     WHEN UKG_FTE.FTE_SUM >1  THEN '100' 		 
			 ELSE CAST(CAST(UKG_FTE.FTE_SUM * 100 AS NUMERIC(8,0))  AS VARCHAR)     END AS 'Custom Field 15',	 
		''  AS 'Custom Field 16', 
		''  AS 'Custom Field 17', 
		''  AS 'Custom Field 18', 
		''  AS 'Custom Field 19', 
		''  AS 'Custom Field 20', 
		''  AS 'Custom Field 21', 
		''  AS 'Custom Field 22', 
		''  AS 'Custom Field 23', 
		''  AS 'Custom Field 24', 
		''  AS 'Custom Field 25', 
		''  AS 'Custom Field 26', 
		''  AS 'Custom Field 27', 
		''  AS 'Custom Field 28',
		''  AS 'Custom Field 29',
		''  AS 'Custom Field 30',
        ''  AS 'Additional Fields for CRT lookups' 
INTO [STAGE].[UKG_EMPLOYEE_DATA]		
FROM HEALTH_ODS.STAGE.UKG_EMPL_T EMPL 
LEFT OUTER JOIN STAGE.UKG_EMPL_HRATE_EFFDT_T HEFFDT	  -- If change to INNER JOIN  , it will remove the dup
  ON  EMPL.EMPLID = HEFFDT.EMPLID
  AND HEFFDT.RN = 1
  AND HEFFDT.HOURLY_RT = EMPL.HOURLY_RT
LEFT OUTER JOIN RPT.CURRENT_EMPL_REPORTS_TO M
  ON M.MANAGER_HR_STATUS  = 'A'
 AND M.MANAGER_EMPLID = EMPL.EMPLID
 AND M.MANAGER_POSITION_NBR = EMPL.POSITION_NBR
LEFT OUTER JOIN  RPT.ORG_HIERARCHY_POSN	  HPOSN
  ON HPOSN.EMPLID = EMPL.EMPLID
 AND HPOSN.EMPL_RCD	= EMPL.EMPL_RCD
 AND EMPL.MANAGER_EMPLID IS NULL 
LEFT OUTER JOIN STABLE.PS_PERSONAL_PHONE	PH1
  ON PH1.EMPLID = EMPL.EMPLID
  AND PH1.DML_IND <> 'D'
  AND PH1.PHONE_TYPE IN ('CEL2')
LEFT OUTER JOIN STABLE.PS_PERSONAL_PHONE	PH2
  ON PH2.EMPLID = EMPL.EMPLID
  AND PH2.DML_IND <> 'D'
  AND PH2.PHONE_TYPE IN ('CELL')
LEFT OUTER JOIN STAGE.UKG_EMPL_FTE_T UKG_FTE
   ON EMPL.EMPLID = UKG_FTE.EMPLID
LEFT OUTER JOIN HEALTH_ODS.[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
    ON EMPL.POSITION_NBR = FIN.POSITION_NBR
	--AND FIN.POSN_SEQ  = 1
    AND FIN.POSN_SEQ = (SELECT MIN_POSN_SEQ FROM STAGE.UKG_COMBOCD_T	T  WHERE FIN.POSITION_NBR = T.POSITION_NBR) 
LEFT OUTER JOIN	  [ECOTIME_RPT].[TEST].[TSR_BUSINESSSTRUCTURE_GET] ()  UKG_BS
   ON UKG_BS.COMBOCODE =  FIN.FDM_COMBO_CD  
LEFT JOIN ECOTIME_RPT.TEST.TSR_JOBCODES UKG_JC 
   ON UKG_JC.JOBCODE = FIN.JOBCODE
LEFT JOIN ECOTIME_RPT.TEST.TSR_JOBGROUPS UKG_JG 
   ON UKG_JG.JOBGROUP = UKG_JC.JOBGROUP
LEFT JOIN [stage].[UKG_EMPL_STATUS_LOOKUP] UKG_ES
ON  EMPL.emplid= UKG_ES.emplid 
;

alter table [stage].[UKG_EMPLOYEE_DATA]
ALTER COLUMN [Custom Field 17] varchar(50) NULL
;

-- Update [Custom Field 17] in [stage].[UKG_EMPLOYEE_DATA]
UPDATE [stage].[UKG_EMPLOYEE_DATA]
SET [Custom Field 17] = B.differncds
FROM [stage].[UKG_EMPLOYEE_DATA] T
INNER JOIN [stage].[UKG_tsr_differncds_V] B
ON T.jobcode = B.jobcode;


--DROP TABLE IF EXISTS STAGE.UKG_COMBOCD_T;
--DROP TABLE IF EXISTS STAGE.UKG_EMPL_FTE_T;
--DROP TABLE IF EXISTS STAGE.UKG_EMPL_FTE_T;




END;



GO


