
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
/*
                                                                                                                                                                                                                                                           
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                                                                                                                                                                                                                             
--  Procedure Name: [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD]
                                                                                                                                                                                        
--  Author:         Jim Shih
                                                                                                                                                                                                                                 
--  Create date:    05/19/2025 -- Please update with the original creation date
                                                                                                                                                                              
--  Description:    This stored procedure identifies employees from health_ods.[health_ods].].stable.PS_JOB who are considered inactive
                                                                                                                      
--                  or not managed under UKG for a specified pay period.
                                                                                                                                                                                     
--                  It achieves this by selecting employees who are:
                                                                                                                                                                                         
--                      1. Not present in [dbo].[UKG_EMPLOYEE_DATA] (specifically, those not having NON_UKG_MANAGER_FLAG != 'T',
                                                                                                                             
--                         meaning it excludes employees considered managed by UKG)._
                                                                                                                                                                        
--                      2. Meet specific departmental criteria (for some datasets):
                                                                                                                                                                          
--                         - Belong to 'VCHSH' (MED CENTER) via health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY].
                                                                                                                                          
--                         - Or, belong to PHSO departments (DEPTID range '002000'-'002999' with specific exclusions).
                                                                                                                                       
--                      3. Are not part of the ARC MSP POPULATION (specific DEPTID and JOBCODE exclusions for some datasets).
                                                                                                                                
--                      4. Have JOB_INDICATOR = 'P' (for some datasets), DML_IND <> 'D', GP_PAYGROUP = 'BIWEEKLY', and EMPL_TYPE = 'H' (Hourly).
                                                                                                             
--                      5. Meet one of the following EFFDT criteria:
                                                                                                                                                                                         
--                         a. (Dataset1) EFFDT is within the provided @paybeginddt AND @payenddt, using FilteredJobData.
                                                                                                                                     
--                         b. (Dataset2) EFFDT is on or before @paybeginddt and is the latest effective-dated record for active employees (using FilteredJobData),
                                                                                           
--                            EXCLUDING any EMPLID found in Dataset1 AND EXCLUDING any EMPLID found in Dataset3.
                                                                                                                                             
--                         c. (Dataset3) Identifies MAX effective-dated records within the pay period (using NonUKGjobInPayperiod, which itself excludes EMPLIDs from Dataset1)
                                                                              
--                            are used to filter Dataset2. The NOTE in Dataset3 clarifies its role.
                                                                                                                                                          
--                  The target table [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD] is dropped and recreated with each execution.
                                                                                                                                
--                  Additionally, intermediate tables for Dataset1, Dataset2, and Dataset3 are created for validation.
                                                                                                                                       
--                  The results (EMPLID, HR_STATUS, JOB_INDICATOR, TERMINATION_DT, deptid, VC_CODE, EFFDT, EFFSEQ, EMPL_RCD, UPD_BT_DTM, NOTE, LOAD_DTTM)
                                                                                                    
--                  are inserted into the newly created table, with the NOTE column indicating the reason for inclusion.
                                                                                                                                     
--
                                                                                                                                                                                                                                                           
--  Execution Example:
                                                                                                                                                                                                                                       
--  EXEC [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD] @payenddt = '2025-07-5';
                                                                                                                                                                          
--  obsolete EXEC [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD] @paybeginddt = '2025-04-27', @payenddt = '2025-05-10';
                                                                                                                                   

                                                                                                                                                                                                                                                             
--
                                                                                                                                                                                                                                                           
--  Version History:
                                                                                                                                                                                                                                         
--  Date        Author               Description
                                                                                                                                                                                                             
--  ----------- -------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-
                                                                                                                                                                                                                                                            
--  05/19/2025 Jim Shih             Initial procedure creation.
                                                                                                                                                                                              
--  05/20/2025 Jim Shih             Modified to union records with EFFDT <= @paybeginddt, using a CTE for clarity and adding a NOTE for each dataset._
                                                                                                       
--  05/21/2025 Jim Shih             Restructured the UNION ALL into separate CTEs (Dataset1, Dataset2, Dataset3) for better data manipulation capability,
                                                                                                    
--                                  Dataset2 excludes EMPLIDs from Dataset1 and Dataset3
                                                                                                                                                                     
*-- 7/16/2025 Jim Shih
                                                                                                                                                                                                                                       
*-- migrate from hs-ssisp-v
                                                                                                                                                                                                                                  
*-- @paybeginddt=DATEADD(day, -13, @payenddt)
                                                                                                                                                                                                                
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                                                                                                                                                                                                                             
*/
                                                                                                                                                                                                                                                           
CREATE             PROCEDURE [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD]
                                                                                                                                                                               
--    @paybeginddt DATE,
                                                                                                                                                                                                                                     
    @payenddt DATE
                                                                                                                                                                                                                                           
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          
DECLARE @paybeginddt DATE; -- Declare the variable	
                                                                                                                                                                                                          
SET @paybeginddt = DATEADD(day, -13, @payenddt);
                                                                                                                                                                                                             
    -- Drop the main table if it already exists
                                                                                                                                                                                                              
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD]', 'U') IS NOT NULL
                                                                                                                                                                              
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD];
                                                                                                                                                                                               

                                                                                                                                                                                                                                                             
    -- Drop validation tables if they already exist
                                                                                                                                                                                                          
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1]', 'U') IS NOT NULL
                                                                                                                                                                     
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1];
                                                                                                                                                                                      
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2]', 'U') IS NOT NULL
                                                                                                                                                                     
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2];
                                                                                                                                                                                      
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3]', 'U') IS NOT NULL
                                                                                                                                                                     
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3];
                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
    -- Create Dataset1 validation table
                                                                                                                                                                                                                      
    -- Define CTEs required for Dataset1
                                                                                                                                                                                                                     
    WITH FilteredJobData AS (
                                                                                                                                                                                                                                
        SELECT
                                                                                                                                                                                                                                               
            H.EMPLID,
                                                                                                                                                                                                                                        
            H.HR_STATUS,
                                                                                                                                                                                                                                     
            H.JOB_INDICATOR,
                                                                                                                                                                                                                                 
            H.TERMINATION_DT,
                                                                                                                                                                                                                                
            H.deptid,
                                                                                                                                                                                                                                        
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[health_ods].].stable.PS_DEPT_TBL
                                                                                                                                                        
			DT.DESCR AS DEPT_DESCR_FULL,
                                                                                                                                                                                                                              
            V.VC_CODE,
                                                                                                                                                                                                                                       
            H.EFFDT,
                                                                                                                                                                                                                                         
            H.EFFSEQ,
                                                                                                                                                                                                                                        
            H.EMPL_RCD,
                                                                                                                                                                                                                                      
            H.UPD_BT_DTM
                                                                                                                                                                                                                                     
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
                                                                                                                                                                                                         
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
                                                                                                                                                                                            
            ON H.DEPTID = V.DEPTID
                                                                                                                                                                                                                           
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
                                                                                                                                                                                              
            ON H.SETID_DEPT = DT.SETID
                                                                                                                                                                                                                       
            AND H.DEPTID = DT.DEPTID
                                                                                                                                                                                                                         
            AND DT.DML_IND <> 'D' -- Ensure we don't pick up deleted department rows
                                                                                                                                                                         
            AND DT.EFFDT = (
                                                                                                                                                                                                                                 
                SELECT MAX(DT_SUB.EFFDT)
                                                                                                                                                                                                                     
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                                                                                                                                                                                       
                WHERE DT_SUB.SETID = DT.SETID
                                                                                                                                                                                                                
                  AND DT_SUB.DEPTID = DT.DEPTID
                                                                                                                                                                                                              
                  AND DT_SUB.EFFDT <= H.EFFDT -- Effective as of the job record's effective date
                                                                                                                                                             
                  AND DT_SUB.DML_IND <> 'D'
                                                                                                                                                                                                                  
            )
                                                                                                                                                                                                                                                
        WHERE
                                                                                                                                                                                                                                                
            NOT EXISTS (
                                                                                                                                                                                                                                     
                SELECT 1
                                                                                                                                                                                                                                     
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                                                                                                                                                                                                           
                WHERE UED.EMPLID = H.EMPLID
                                                                                                                                                                                                                  
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
                                                                                                                             
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
                                                                                                                                                                                           
            -- Filter for UKG
                                                                                                                                                                                                                                
            AND (V.VC_CODE = 'VCHSH'   	 --MED CENTER
                                                                                                                                                                                                        
                OR (H.DEPTID BETWEEN '002000' AND '002999' AND H.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
                                                                                                                                       
                )
                                                                                                                                                                                                                                            
            AND NOT (H.DEPTID IN ('002053','002056','003919') AND H.JOBCODE IN ('000770','000771','000772','000775','000776'))	--exclude ARC MSP POPULATION
                                                                                                  
            AND H.JOB_INDICATOR = 'P'
                                                                                                                                                                                                                        
            AND H.DML_IND <> 'D'
                                                                                                                                                                                                                             
            AND H.GP_PAYGROUP = 'BIWEEKLY'
                                                                                                                                                                                                                   
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                                                                                                                                                                                           
    ),
                                                                                                                                                                                                                                                       
    Dataset1 AS (
                                                                                                                                                                                                                                            
        SELECT
                                                                                                                                                                                                                                               
            FJD.EMPLID,
                                                                                                                                                                                                                                      
            FJD.HR_STATUS,
                                                                                                                                                                                                                                   
            FJD.JOB_INDICATOR,
                                                                                                                                                                                                                               
            FJD.TERMINATION_DT,
                                                                                                                                                                                                                              
            FJD.deptid,
                                                                                                                                                                                                                                      
            FJD.DEPT_DESCR,
                                                                                                                                                                                                                                  
            FJD.DEPT_DESCR_FULL,
                                                                                                                                                                                                                             
            FJD.VC_CODE,
                                                                                                                                                                                                                                     
            FJD.EFFDT,
                                                                                                                                                                                                                                       
            FJD.EFFSEQ,
                                                                                                                                                                                                                                      
            FJD.EMPL_RCD,
                                                                                                                                                                                                                                    
            FJD.UPD_BT_DTM,
                                                                                                                                                                                                                                  
            'UKG EFFDT is in Pay Period' AS NOTE,
                                                                                                                                                                                                            
            GETDATE() AS LOAD_DTTM
                                                                                                                                                                                                                           
        FROM FilteredJobData FJD
                                                                                                                                                                                                                             
        WHERE FJD.EFFDT BETWEEN @paybeginddt AND @payenddt
                                                                                                                                                                                                   
    )
                                                                                                                                                                                                                                                        
    SELECT *
                                                                                                                                                                                                                                                 
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1]
                                                                                                                                                                                                 
    FROM Dataset1;
                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                             
    -- Create Dataset2 validation table
                                                                                                                                                                                                                      
    -- Define CTEs required for Dataset2
                                                                                                                                                                                                                     
    WITH FilteredJobData AS (
                                                                                                                                                                                                                                
        SELECT
                                                                                                                                                                                                                                               
            H.EMPLID,
                                                                                                                                                                                                                                        
            H.HR_STATUS,
                                                                                                                                                                                                                                     
            H.JOB_INDICATOR,
                                                                                                                                                                                                                                 
            H.TERMINATION_DT,
                                                                                                                                                                                                                                
            H.deptid,
                                                                                                                                                                                                                                        
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL
                                                                                                                                                          
			DT.DESCR AS DEPT_DESCR_FULL,
                                                                                                                                                                                                                              
            V.VC_CODE,
                                                                                                                                                                                                                                       
            H.EFFDT,
                                                                                                                                                                                                                                         
            H.EFFSEQ,
                                                                                                                                                                                                                                        
            H.EMPL_RCD,
                                                                                                                                                                                                                                      
            H.UPD_BT_DTM
                                                                                                                                                                                                                                     
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
                                                                                                                                                                                                         
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
                                                                                                                                                                                            
            ON H.DEPTID = V.DEPTID
                                                                                                                                                                                                                           
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
                                                                                                                                                                                              
            ON H.SETID_DEPT = DT.SETID
                                                                                                                                                                                                                       
            AND H.DEPTID = DT.DEPTID
                                                                                                                                                                                                                         
            AND DT.DML_IND <> 'D'
                                                                                                                                                                                                                            
            AND DT.EFFDT = (
                                                                                                                                                                                                                                 
                SELECT MAX(DT_SUB.EFFDT)
                                                                                                                                                                                                                     
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                                                                                                                                                                                       
                WHERE DT_SUB.SETID = DT.SETID
                                                                                                                                                                                                                
                  AND DT_SUB.DEPTID = DT.DEPTID
                                                                                                                                                                                                              
                  AND DT_SUB.EFFDT <= H.EFFDT
                                                                                                                                                                                                                
                  AND DT_SUB.DML_IND <> 'D'
                                                                                                                                                                                                                  
            )
                                                                                                                                                                                                                                                
        WHERE
                                                                                                                                                                                                                                                
            NOT EXISTS (
                                                                                                                                                                                                                                     
                SELECT 1
                                                                                                                                                                                                                                     
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                                                                                                                                                                                                           
                WHERE UED.EMPLID = H.EMPLID
                                                                                                                                                                                                                  
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
                                                                                                                             
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
                                                                                                                                                                                           
            -- Filter for UKG
                                                                                                                                                                                                                                
            AND (V.VC_CODE = 'VCHSH'   	 --MED CENTER
                                                                                                                                                                                                        
                OR (H.DEPTID BETWEEN '002000' AND '002999' AND H.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
                                                                                                                                       
                )
                                                                                                                                                                                                                                            
            AND NOT (H.DEPTID IN ('002053','002056','003919') AND H.JOBCODE IN ('000770','000771','000772','000775','000776'))	--exclude ARC MSP POPULATION
                                                                                                  
            AND H.JOB_INDICATOR = 'P'
                                                                                                                                                                                                                        
            AND H.DML_IND <> 'D'
                                                                                                                                                                                                                             
            AND H.GP_PAYGROUP = 'BIWEEKLY'
                                                                                                                                                                                                                   
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                                                                                                                                                                                           
    ),
                                                                                                                                                                                                                                                       
    Dataset2 AS (
                                                                                                                                                                                                                                            
        SELECT
                                                                                                                                                                                                                                               
            FJD.EMPLID,
                                                                                                                                                                                                                                      
            FJD.HR_STATUS,
                                                                                                                                                                                                                                   
            FJD.JOB_INDICATOR,
                                                                                                                                                                                                                               
            FJD.TERMINATION_DT,
                                                                                                                                                                                                                              
            FJD.deptid,
                                                                                                                                                                                                                                      
            FJD.DEPT_DESCR,
                                                                                                                                                                                                                                  
            FJD.DEPT_DESCR_FULL,
                                                                                                                                                                                                                             
            FJD.VC_CODE,
                                                                                                                                                                                                                                     
            FJD.EFFDT,
                                                                                                                                                                                                                                       
            FJD.EFFSEQ,
                                                                                                                                                                                                                                      
            FJD.EMPL_RCD,
                                                                                                                                                                                                                                    
            FJD.UPD_BT_DTM,
                                                                                                                                                                                                                                  
            'UKG EFFDT is on or before Pay Period Begin' AS NOTE,
                                                                                                                                                                                            
            GETDATE() AS LOAD_DTTM
                                                                                                                                                                                                                           
        FROM FilteredJobData FJD
                                                                                                                                                                                                                             
        WHERE FJD.EFFDT <= @paybeginddt
                                                                                                                                                                                                                      
        AND FJD.HR_STATUS='A'
                                                                                                                                                                                                                                
        AND FJD.EFFDT =
                                                                                                                                                                                                                                      
            (SELECT MAX(D_ED.EFFDT) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ED
                                                                                                                                                                          
              WHERE FJD.EMPLID = D_ED.EMPLID
                                                                                                                                                                                                                 
                AND FJD.EMPL_RCD = D_ED.EMPL_RCD
                                                                                                                                                                                                             
                AND D_ED.EFFDT <= @paybeginddt
                                                                                                                                                                                                               
                AND D_ED.DML_IND <> 'D')
                                                                                                                                                                                                                     
        AND FJD.EFFSEQ =
                                                                                                                                                                                                                                     
            (SELECT MAX(D_ES.EFFSEQ) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ES
                                                                                                                                                                         
              WHERE FJD.EMPLID = D_ES.EMPLID
                                                                                                                                                                                                                 
                AND FJD.EMPL_RCD = D_ES.EMPL_RCD
                                                                                                                                                                                                             
                AND FJD.EFFDT = D_ES.EFFDT
                                                                                                                                                                                                                   
                AND D_ES.DML_IND <> 'D')
                                                                                                                                                                                                                     
    )
                                                                                                                                                                                                                                                        
    SELECT *
                                                                                                                                                                                                                                                 
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2]
                                                                                                                                                                                                 
    FROM Dataset2;
                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                             
    -- Create Dataset3 validation table
                                                                                                                                                                                                                      
    -- Define CTEs required for Dataset3
                                                                                                                                                                                                                     
    WITH NonUKGjobInPayperiod AS (
                                                                                                                                                                                                                           
        SELECT
                                                                                                                                                                                                                                               
            H.EMPLID,
                                                                                                                                                                                                                                        
            H.HR_STATUS,
                                                                                                                                                                                                                                     
            H.JOB_INDICATOR,
                                                                                                                                                                                                                                 
            H.TERMINATION_DT,
                                                                                                                                                                                                                                
            H.deptid,
                                                                                                                                                                                                                                        
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL
                                                                                                                                                          
			DT.DESCR AS DEPT_DESCR_FULL,
                                                                                                                                                                                                                              
            V.VC_CODE,
                                                                                                                                                                                                                                       
            H.EFFDT,
                                                                                                                                                                                                                                         
            H.EFFSEQ,
                                                                                                                                                                                                                                        
      H.EMPL_RCD,
                                                                                                                                                                                                                                            
            H.UPD_BT_DTM
                                                                                                                                                                                                                                     
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
                                                                                                                                                                                                         
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
                                                                                                                                                                                            
            ON H.DEPTID = V.DEPTID
                                                                                                                                                                                                                           
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
                                                                                                                                                                                              
            ON H.SETID_DEPT = DT.SETID
                                                                                                                                                                                                                       
            AND H.DEPTID = DT.DEPTID
                                                                                                                                                                                                                         
            AND DT.DML_IND <> 'D'
                                                                                                                                                                                                                            
            AND DT.EFFDT = (
                                                                                                                                                                                                                                 
                SELECT MAX(DT_SUB.EFFDT)
                                                                                                                                                                                                                     
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                                                                                                                                                                                       
                WHERE DT_SUB.SETID = DT.SETID
                                                                                                                                                                                                                
                  AND DT_SUB.DEPTID = DT.DEPTID
                                                                                                                                                                                                              
                  AND DT_SUB.EFFDT <= H.EFFDT
                                                                                                                                                                                                                
                  AND DT_SUB.DML_IND <> 'D'
                                                                                                                                                                                                                  
            )
                                                                                                                                                                                                                                                
        WHERE
                                                                                                                                                                                                                                                
            NOT EXISTS (
                                                                                                                                                                                                                                     
                SELECT 1
                                                                                                                                                                                                                                     
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                                                                                                                                                                                                           
                WHERE UED.EMPLID = H.EMPLID
                                                                                                                                                                                                                  
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
                                                                                                                             
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
                                                                                                                                                                                           
            AND NOT EXISTS ( -- Exclude EMPLIDs that are in Dataset1
                                                                                                                                                                                         
                SELECT 1
                                                                                                                                                                                                                                     
                FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] D1_Table
                                                                                                                                                                            
                WHERE D1_Table.EMPLID = H.EMPLID
                                                                                                                                                                                                             
            )
                                                                                                                                                                                                                                                
            -- The following filters are intentionally broader than FilteredJobData
                                                                                                                                                                          
            AND H.DML_IND <> 'D'
                                                                                                                                                                                                                             
            AND H.GP_PAYGROUP = 'BIWEEKLY'
                                                                                                                                                                                                                   
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                                                                                                                                                                                           
            AND H.EFFDT BETWEEN @paybeginddt AND @payenddt -- Crucial filter for this CTE
                                                                                                                                                                    
    ),
                                                                                                                                                                                                                                                       
    Dataset3 AS (
                                                                                                                                                                                                                                            
        SELECT
                                                                                                                                                                                                                                               
            FJD.EMPLID,
                                                                                                                                                                                                                                      
            FJD.HR_STATUS,
                                                                                                                                                                                                                                   
            FJD.JOB_INDICATOR,
                                                                                                                                                                                                                               
            FJD.TERMINATION_DT,
                                                                                                                                                                                                                              
            FJD.deptid,
                                                                                                                                                                                                                                      
            FJD.DEPT_DESCR,
                                                                                                                                                                                                                                  
            FJD.DEPT_DESCR_FULL,
                                                                                                                                                                                                                             
            FJD.VC_CODE,
                                                                                                                                                                                                                                     
            FJD.EFFDT,
                                                                                                                                                                                                                                       
            FJD.EFFSEQ,
                                                                                                                                                                                                                                      
            FJD.EMPL_RCD,
                                                                                                                                                                                                                                    
            FJD.UPD_BT_DTM,
                                                                                                                                                                                                                                  
            'NON_UKG and MAX-EFFDT is in Pay Period, should be exculded from dataset2' AS NOTE,
                                                                                                                                                              
            GETDATE() AS LOAD_DTTM
                                                                                                                                                                                                                           
        FROM NonUKGjobInPayperiod FJD 
                                                                                                                                                                                                                       
        WHERE FJD.EFFDT BETWEEN @paybeginddt AND @payenddt 
                                                                                                                                                                                                  
 --       AND FJD.HR_STATUS='A' -- Kept commented 
                                                                                                                                                                                                           
        AND FJD.EFFDT =
                                                                                                                                                                                                                                      
            (SELECT MAX(D_ED.EFFDT) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ED
                                                                                                                                                                          
              WHERE FJD.EMPLID = D_ED.EMPLID
                                                                                                                                                                                                                 
                AND FJD.EMPL_RCD = D_ED.EMPL_RCD
                                                                                                                                                                                                             
                AND D_ED.EFFDT BETWEEN @paybeginddt AND @payenddt
                                                                                                                                                                                            
                AND D_ED.DML_IND <> 'D')
                                                                                                                                                                                                                     
        AND FJD.EFFSEQ =
                                                                                                                                                                                                                                     
            (SELECT MAX(D_ES.EFFSEQ) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ES
                                                                                                                                                                         
              WHERE FJD.EMPLID = D_ES.EMPLID
                                                                                                                                                                                                                 
                AND FJD.EMPL_RCD = D_ES.EMPL_RCD
                                                                                                                                                                                                             
                AND FJD.EFFDT = D_ES.EFFDT
                                                                                                                                                                                                                   
                AND D_ES.DML_IND <> 'D')
                                                                                                                                                                                                                     
    )
                                                                                                                                                                                                                                                        
    SELECT *
                                                                                                                                                                                                                                                 
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3]
                                                                                                                                                                                                 
    FROM Dataset3;
                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                             
    -- Populate the final target table
                                                                                                                                                                                                                       
    SELECT
                                                                                                                                                                                                                                                   
        EMPLID,
                                                                                                                                                                                                                                              
        HR_STATUS,
                                                                                                                                                                                                                                           
        JOB_INDICATOR,
                                                                                                                                                                                                                                       
        TERMINATION_DT,
                                                                                                                                                                                                                                      
        deptid,
                                                                                                                                                                                                                                              
        DEPT_DESCR,
                                                                                                                                                                                                                                          
        DEPT_DESCR_FULL,
                                                                                                                                                                                                                                     
        VC_CODE,
                                                                                                                                                                                                                                             
        EFFDT,
                                                                                                                                                                                                                                               
        EFFSEQ,
                                                                                                                                                                                                                                              
        EMPL_RCD,
                                                                                                                                                                                                                                            
        UPD_BT_DTM,
                                                                                                                                                                                                                                          
        NOTE,
                                                                                                                                                                                                                                                
        LOAD_DTTM
                                                                                                                                                                                                                                            
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD]
                                                                                                                                                                                                          
    FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] -- Use the created table
                                                                                                                                                                        

                                                                                                                                                                                                                                                             
    UNION ALL
                                                                                                                                                                                                                                                

                                                                                                                                                                                                                                                             
    SELECT
                                                                                                                                                                                                                                                   
        D2.EMPLID, 
                                                                                                                                                                                                                                          
        D2.HR_STATUS, 
                                                                                                                                                                                                                                       
        D2.JOB_INDICATOR,
                                                                                                                                                                                                                                    
        D2.TERMINATION_DT, 
                                                                                                                                                                                                                                  
        D2.deptid,
                                                                                                                                                                                                                                           
        D2.DEPT_DESCR,
                                                                                                                                                                                                                                       
        D2.DEPT_DESCR_FULL,
                                                                                                                                                                                                                                  
        D2.VC_CODE, 
                                                                                                                                                                                                                                         
        D2.EFFDT, 
                                                                                                                                                                                                                                           
        D2.EFFSEQ, 
                                                                                                                                                                                                                                          
        D2.EMPL_RCD, 
                                                                                                                                                                                                                                        
        D2.UPD_BT_DTM, 
                                                                                                                                                                                                                                      
        D2.NOTE, 
                                                                                                                                                                                                                                            
        D2.LOAD_DTTM
                                                                                                                                                                                                                                         
    FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2] D2 -- Use the created table
                                                                                                                                                                     
    WHERE NOT EXISTS ( 
                                                                                                                                                                                                                                      
        SELECT 1
                                                                                                                                                                                                                                             
FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3] D3 -- Use the created table
                                                                                                                                                                         
        WHERE D3.EMPLID = D2.EMPLID
                                                                                                                                                                                                                          
    )
                                                                                                                                                                                                                                                        
    AND NOT EXISTS ( 
                                                                                                                                                                                                                                        
        SELECT 1
                                                                                                                                                                                                                                             
        FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] D1 -- Use the created table
                                                                                                                                                                 
        WHERE D1.EMPLID = D2.EMPLID
                                                                                                                                                                                                                          
    )
                                                                                                                                                                                                                                                        
    ;
                                                                                                                                                                                                                                                        

                                                                                                                                                                                                                                                             
END
                                                                                                                                                                                                                                                          
