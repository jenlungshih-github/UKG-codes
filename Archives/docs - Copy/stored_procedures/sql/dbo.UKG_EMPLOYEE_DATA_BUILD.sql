-- All stored procedures fetched from HealthTime database on 2026-02-04
-- Each procedure is prefixed by a header comment with schema and name

-- =====================================================
-- dbo.UKG_EMPLOYEE_DATA_BUILD
-- =====================================================









/***************************************
* Created By: May Xu	
* Table: This SP creates table [dbo].[UKG_EMPLOYEE_DATA]	to upload the employee data file to UKG
* EXEC 	[dbo].UKG_EMPLOYEE_DATA_BUILD	
* Performance Optimizations (9/16/2025):
* - Added indexes to all temporary tables on JOIN key columns
* - Replaced correlated subquery with direct JOIN for POSITION_NBR filtering
* - Added index on final table for UPDATE operation
* - Improved query execution time significantly
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
*-- 06/09/2025 Jim Shih: Update [Custom Field 17] in [dbo].[UKG_EMPLOYEE_DATA]
      UPDATE [dbo].[UKG_EMPLOYEE_DATA]
      SET [Custom Field 17] = B.differncds
      FROM [dbo].[UKG_EMPLOYEE_DATA] T
      INNER JOIN [stage].[UKG_tsr_differncds_V] B
      ON T.emplid = B.emplid AND T.jobcode = B.jobcode;	
*-- 06/10/2025 Jim Shih: ISNULL(CAST(UKG_ES.EFFDT AS VARCHAR), '')  AS 'Employment Status Effective Date',   -- Replace EMPL.EFFDT with UKG_ES.EFFDT  
*-- 06/18/2025 Jim Shih: Per JK, change the heading for the Fund Group from Home Business Structure Level 5 - TSG to Home Business Structure Level 5 - Fund Group	
*-- 07/07/2025 Jim Shih: Custom Date Field 1 is the Probation Date and if the probation date is not found it should be filled with the hire date			
*-- 07/11/2025 May Xu: add code to create a snapshot of the view [UKG_EMPLOYEE_DATA_V] and drop any 30 days old snapshot
*-- 07/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- change SELECT  * INTO HealthTime.[STAGE].[' +  @SNAPSHOT_TABLENAME + ']' + ' FROM stage.UKG_EMPLOYEE_DATA_V' 
*-- to SELECT  * INTO [BCK].[' +  @SNAPSHOT_TABLENAME + ']' + ' FROM dbo.UKG_EMPLOYEE_DATA_V'
*-- 07/15/2025 Jim Shih: change dbo.[BUSINESSSTRUCTURE_GET] () to [hts].[UKG_BusinessStructure]
*-- 07/26/2025 Jim Shih: add troubleshooting worker type comments
*-- 07/31/2025 Jim Shih:
*-- uncomment
*--		     WHEN  EMPL.EMPL_CLASS != 6 AND ((EMPL.HR_STATUS = 'I' AND EMPL.FTE >= 1) OR (EMPL.HR_STATUS = 'A' AND UKG_FTE.FTE_SUM >= 1))  THEN 'FT'
*--			 WHEN  EMPL.EMPL_CLASS != 6 AND ((EMPL.HR_STATUS = 'I' AND EMPL.FTE < 1) OR (EMPL.HR_STATUS = 'A' AND UKG_FTE.FTE_SUM < 1))  THEN 'PT'
*-- 08/04/2025   Jim Shih: add DROP TABLE IF EXISTS
*-- SELECT 
    @SQL_CREATE =  
        N'DROP TABLE IF EXISTS bck.[' + @SNAPSHOT_TABLENAME + ']; ' +
        N'SELECT * INTO bck.[' + @SNAPSHOT_TABLENAME + '] FROM dbo.UKG_EMPLOYEE_DATA_V';
* -- 08/13/2025 Jim Shih: Per TSR-148, Exempt employees that had a SAL_ADMIN_PLAN of BYA that should not be included.
* --                      add filter in ps_job -- and (H.SAL_ADMIN_PLAN <> 'BYA' OR H.FLSA_STATUS <> 'E')
* -- 08/14/2025 Jim Shih: Per JK, Add Business unit as the value of Custom Field 7 in Personal Import
* -- 08/22/2025 Jim Shih: Per JK, Please exclude all BYA employees, regardless of FLSACode
* -- 08/25/2025 Jim Shih: Add CTE_exclude_BYA to identify BYA employees for exclusion
* -- 08/26/2025 Jim Shih: 
* -- Per JK, If they are a non-health reportsto then we should
* -- create one person record for them.  As a non-employee the job information is not important.  We should include any job indicator value but only
* -- return one row per employee
* -- 09/03/2025 Jim Shih: 
*--  Per JK, Employment Status Effective Date should be The effdt for the job record where the status first appears after a status change or upon new hire. Also apply this logic to the HR Status Date (Custom Date 4)
* -- 09/15/2025 Jim Shih: add termination_dt
* -- 10/08/2025 Jim Shih: add action, and action_dt
* -- 12/01/2025 Jim Shih: replace [stage].[UKG_tsr_differncds_V] with [hts].[UKG_differncds]
* -- 12/02/2025 Jim Shih: replace [hts].[UKG_differncds] with hts.UKG_DifferentialEligibilityCodes
* -- 12/02/2025 Jim Shih: Performance Optimizations - Added comprehensive indexing strategy:
*                         - Added indexes to all temporary tables (STAGE.CTE_exclude_BYA, UKG_EMPL_E_T, UKG_EMPL_M_T, UKG_EMPL_T)
*                         - Enhanced indexing for lookup tables (UKG_COMBOCD_T, UKG_EMPL_FTE_T, UKG_EMPL_HRATE_EFFDT_T)
*                         - Added indexes to UKG_EMPLOYEE_DATA_TEMP for final processing operations
*                         - Added indexes to [dbo].[NON_UKG_MANAGER_HISTORY] for exclusion lookups
*                         - Total of 20+ new indexes to optimize JOIN and WHERE operations
* -- 12/07/2025 Jim Shih: Enhanced Custom Field 17 logic to set 'XXX' for NULL or blank values
* -- 12/09/2025 Jim Shih: Added CTE check_jobcode to set Custom Field 17 to 'XXX' when setid = 'SDMED'
*                         - Added check_jobcode CTE joining UKG_DifferentialEligibilityCodes with PS_UC_SHFT_ONC_ERN
*                         - Enhanced Custom Field 17 UPDATE logic with conditional CASE statement
*                         - Refined logic: Sets 'XXX' value only when setid = 'SDMED' AND differncds IS NULL
* -- 01/28/2026 Jim Shih: Use stage.UKG_CURRENT_EMPL_REPORTS_TO_exclude_BYA_V to exclude BYA employees in reports_to joins
******************************************/

CREATE PROCEDURE [dbo].[UKG_EMPLOYEE_DATA_BUILD]
AS

BEGIN

    -- EXEC [hts].[UKG_BusinessStructure_UPD] before EXEC [dbo].UKG_EMPLOYEE_DATA_BUILD
    EXEC [hts].[UKG_BusinessStructure_UPD];
    -- EXEC [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD] before EXEC [dbo].UKG_EMPLOYEE_DATA_BUILD
    EXEC [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD];
    -- EXEC [stage].[SP_UKG_HR_STATUS_LOOKUP_BUILD] before EXEC [dbo].UKG_EMPLOYEE_DATA_BUILD
    EXEC [stage].[SP_UKG_HR_STATUS_LOOKUP_BUILD];

    -- CTE to identify BYA employees for exclusion
    DROP TABLE IF EXISTS STAGE.CTE_exclude_BYA;

    SELECT DISTINCT
        H.emplid
    INTO STAGE.CTE_EXCLUDE_BYA
    FROM health_ods.[health_ods].[stable].PS_JOB H
    WHERE 
        H.JOB_INDICATOR = 'P'
        AND H.DML_IND <> 'D'
        AND H.SAL_ADMIN_PLAN = 'BYA';

    -- Add index for BYA exclusion lookups
    DROP INDEX IF EXISTS CTE_exclude_BYA_IDX_1 ON STAGE.CTE_exclude_BYA;
    CREATE INDEX CTE_exclude_BYA_IDX_1 ON STAGE.CTE_EXCLUDE_BYA (emplid);

    -- UKG Employee population (Primary Job only):
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_E_T;

    SELECT DISTINCT 'F' AS 'NON_UKG_MANAGER_FLAG', EMPL.*
    INTO STAGE.UKG_EMPL_E_T
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA	EMPL
    WHERE 	1=1
        AND EMPL.JOB_INDICATOR = 'P'
        AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
        OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
       )
        AND ((EMPL.hr_status = 'A' 	) -- active empl
        OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) >= DATEADD(DAY, -7, GETDATE()))	 --terminated empl in past 7 days
	   )
        AND PAY_FREQUENCY = 'B'
        AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
        AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )
    --exclude ARC MSP POPULATION

    --Performance Optimizations (9/16/2025):
    -- Add index for performance
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_1 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_2 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_3 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_4 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_5 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_6 ON STAGE.UKG_EMPL_E_T;
    DROP INDEX IF EXISTS UKG_EMPL_E_T_IDX_7 ON STAGE.UKG_EMPL_E_T;
    CREATE INDEX UKG_EMPL_E_T_IDX_1 ON STAGE.UKG_EMPL_E_T (EMPLID);
    CREATE INDEX UKG_EMPL_E_T_IDX_2 ON STAGE.UKG_EMPL_E_T (POSITION_NBR);
    CREATE INDEX UKG_EMPL_E_T_IDX_3 ON STAGE.UKG_EMPL_E_T (MANAGER_EMPLID);
    CREATE INDEX UKG_EMPL_E_T_IDX_4 ON STAGE.UKG_EMPL_E_T (EMPL_RCD);
    CREATE INDEX UKG_EMPL_E_T_IDX_5 ON STAGE.UKG_EMPL_E_T (JOBCODE);
    CREATE INDEX UKG_EMPL_E_T_IDX_6 ON STAGE.UKG_EMPL_E_T (HR_STATUS);
    CREATE INDEX UKG_EMPL_E_T_IDX_7 ON STAGE.UKG_EMPL_E_T (HOURLY_RT);

    -- update MANAGER_EMPLID to next higher level (up to level 5) if manager is not found 
    UPDATE STAGE.UKG_EMPL_E_T	
   SET 	 MANAGER_EMPLID	   =
  CASE    WHEN   HPOSN.LEVEL = 'LEVEL6' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL7' AND MANAGER6_EMPLID != ''  THEN MANAGER6_EMPLID
	      WHEN   HPOSN.LEVEL = 'LEVEL7' AND MANAGER6_EMPLID = '' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
	      WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID != ''THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL8' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID = '' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID != '' THEN MANAGER8_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID != '' THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL9' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID = '' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID != '' THEN MANAGER9_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID != '' THEN MANAGER8_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID != '' THEN MANAGER7_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID != '' THEN MANAGER6_EMPLID
		  WHEN   HPOSN.LEVEL = 'LEVEL10' AND MANAGER9_EMPLID = '' AND MANAGER8_EMPLID = '' AND MANAGER7_EMPLID = '' AND MANAGER6_EMPLID = '' AND MANAGER5_EMPLID != '' THEN MANAGER5_EMPLID			  
 ELSE   COALESCE(EMPL.MANAGER_EMPLID, '') END	
FROM STAGE.UKG_EMPL_E_T	  EMPL
        INNER JOIN health_ods.[health_ods].[RPT].ORG_HIERARCHY_POSN	  HPOSN
        ON HPOSN.EMPLID = EMPL.EMPLID
            AND HPOSN.EMPL_RCD	= EMPL.EMPL_RCD
            AND EMPL.MANAGER_EMPLID IS NULL

    -- Manager outside of UKG
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_M_T;

    SELECT DISTINCT 'T' AS 'NON_UKG_MANAGER_FLAG', EMPL.*
    INTO STAGE.UKG_EMPL_M_T
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL,
        STAGE.UKG_EMPL_E_T UKG
    WHERE EMPL.EMPLID = UKG.MANAGER_EMPLID
        --       and EMPL.JOB_INDICATOR = 'P'  -- 08/26/2025 JK said any job indicator is fine
        AND EMPL.EMPLID NOT IN (SELECT DISTINCT EMPLID
        FROM STAGE.UKG_EMPL_E_T)
        AND EMPL.HR_STATUS = 'A'

    -- Add indexes for UKG_EMPL_M_T performance
    DROP INDEX IF EXISTS UKG_EMPL_M_T_IDX_1 ON STAGE.UKG_EMPL_M_T;
    DROP INDEX IF EXISTS UKG_EMPL_M_T_IDX_2 ON STAGE.UKG_EMPL_M_T;
    DROP INDEX IF EXISTS UKG_EMPL_M_T_IDX_3 ON STAGE.UKG_EMPL_M_T;
    DROP INDEX IF EXISTS UKG_EMPL_M_T_IDX_4 ON STAGE.UKG_EMPL_M_T;
    CREATE INDEX UKG_EMPL_M_T_IDX_1 ON STAGE.UKG_EMPL_M_T (EMPLID);
    CREATE INDEX UKG_EMPL_M_T_IDX_2 ON STAGE.UKG_EMPL_M_T (POSITION_NBR);
    CREATE INDEX UKG_EMPL_M_T_IDX_3 ON STAGE.UKG_EMPL_M_T (MANAGER_EMPLID);
    CREATE INDEX UKG_EMPL_M_T_IDX_4 ON STAGE.UKG_EMPL_M_T (JOBCODE);

    -- combine UKG Empl and UKG Manager
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_T;

    SELECT *
    INTO STAGE.UKG_EMPL_T
    FROM (
                    SELECT
                EMPLID,
                POSITION_NBR,
                JOBCODE,
                EMPL_RCD,
                DEPTID,
                LOCATION,
                PAY_GROUP,
                HR_STATUS,
                EMPL_STATUS,
                FLSA_STATUS,
                SAL_ADMIN_PLAN,
                EFFDT,
                'F' AS 'NON_UKG_MANAGER_FLAG',
                ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY EFFDT DESC) AS RN
            FROM STAGE.UKG_EMPL_E_T

        UNION ALL

            SELECT
                EMPLID,
                POSITION_NBR,
                JOBCODE,
                EMPL_RCD,
                DEPTID,
                LOCATION,
                PAY_GROUP,
                HR_STATUS,
                EMPL_STATUS,
                FLSA_STATUS,
                SAL_ADMIN_PLAN,
                EFFDT,
                'T' AS 'NON_UKG_MANAGER_FLAG',
                ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY EFFDT DESC) AS RN
            FROM STAGE.UKG_EMPL_M_T
    ) A
    WHERE RN = 1;

    -- Add indexes for UKG_EMPL_T performance
    DROP INDEX IF EXISTS UKG_EMPL_T_IDX_1 ON STAGE.UKG_EMPL_T;
    DROP INDEX IF EXISTS UKG_EMPL_T_IDX_2 ON STAGE.UKG_EMPL_T;
    DROP INDEX IF EXISTS UKG_EMPL_T_IDX_3 ON STAGE.UKG_EMPL_T;
    DROP INDEX IF EXISTS UKG_EMPL_T_IDX_4 ON STAGE.UKG_EMPL_T;
    CREATE INDEX UKG_EMPL_T_IDX_1 ON STAGE.UKG_EMPL_T (EMPLID);
    CREATE INDEX UKG_EMPL_T_IDX_2 ON STAGE.UKG_EMPL_T (POSITION_NBR);
    CREATE INDEX UKG_EMPL_T_IDX_3 ON STAGE.UKG_EMPL_T (MANAGER_EMPLID);
    CREATE INDEX UKG_EMPL_T_IDX_4 ON STAGE.UKG_EMPL_T (JOBCODE);

    -- UKG_EMPLOYEE_DATA_TEMP: Staging table for final processing
    DROP TABLE IF EXISTS STAGE.UKG_EMPLOYEE_DATA_TEMP;

    SELECT
        EMPLID,
        POSITION_NBR,
        JOBCODE,
        EMPL_RCD,
        DEPTID,
        LOCATION,
        PAY_GROUP,
        HR_STATUS,
        EMPL_STATUS,
        FLSA_STATUS,
        SAL_ADMIN_PLAN,
        EFFDT,
        NON_UKG_MANAGER_FLAG,
        ROW_NUMBER() OVER (PARTITION BY EMPLID ORDER BY EFFDT DESC) AS RN
    INTO STAGE.UKG_EMPLOYEE_DATA_TEMP
    FROM STAGE.UKG_EMPL_T;

    -- Add indexes for UKG_EMPLOYEE_DATA_TEMP final processing
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_TEMP_IDX_1 ON STAGE.UKG_EMPLOYEE_DATA_TEMP;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_TEMP_IDX_2 ON STAGE.UKG_EMPLOYEE_DATA_TEMP;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_TEMP_IDX_3 ON STAGE.UKG_EMPLOYEE_DATA_TEMP;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_TEMP_IDX_4 ON STAGE.UKG_EMPLOYEE_DATA_TEMP;
    CREATE INDEX UKG_EMPLOYEE_DATA_TEMP_IDX_1 ON STAGE.UKG_EMPLOYEE_DATA_TEMP (EMPLID);
    CREATE INDEX UKG_EMPLOYEE_DATA_TEMP_IDX_2 ON STAGE.UKG_EMPLOYEE_DATA_TEMP (POSITION_NBR);
    CREATE INDEX UKG_EMPLOYEE_DATA_TEMP_IDX_3 ON STAGE.UKG_EMPLOYEE_DATA_TEMP (MANAGER_EMPLID);
    CREATE INDEX UKG_EMPLOYEE_DATA_TEMP_IDX_4 ON STAGE.UKG_EMPLOYEE_DATA_TEMP (JOBCODE);

    -- Final UKG_EMPLOYEE_DATA table: Merge and transform data
    DROP TABLE IF EXISTS dbo.UKG_EMPLOYEE_DATA;

    SELECT
        EMPLID,
        POSITION_NBR,
        JOBCODE,
        EMPL_RCD,
        DEPTID,
        LOCATION,
        PAY_GROUP,
        HR_STATUS,
        EMPL_STATUS,
        FLSA_STATUS,
        SAL_ADMIN_PLAN,
        EFFDT,
        NON_UKG_MANAGER_FLAG
    INTO dbo.UKG_EMPLOYEE_DATA
    FROM STAGE.UKG_EMPLOYEE_DATA_TEMP
    WHERE RN = 1;

    -- Add final indexes for UKG_EMPLOYEE_DATA
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_IDX_1 ON dbo.UKG_EMPLOYEE_DATA;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_IDX_2 ON dbo.UKG_EMPLOYEE_DATA;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_IDX_3 ON dbo.UKG_EMPLOYEE_DATA;
    DROP INDEX IF EXISTS UKG_EMPLOYEE_DATA_IDX_4 ON dbo.UKG_EMPLOYEE_DATA;
    CREATE INDEX UKG_EMPLOYEE_DATA_IDX_1 ON dbo.UKG_EMPLOYEE_DATA (EMPLID);
    CREATE INDEX UKG_EMPLOYEE_DATA_IDX_2 ON dbo.UKG_EMPLOYEE_DATA (POSITION_NBR);
    CREATE INDEX UKG_EMPLOYEE_DATA_IDX_3 ON dbo.UKG_EMPLOYEE_DATA (MANAGER_EMPLID);
    CREATE INDEX UKG_EMPLOYEE_DATA_IDX_4 ON dbo.UKG_EMPLOYEE_DATA (JOBCODE);

    -- Clean up temporary tables
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_E_T;
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_M_T;
    DROP TABLE IF EXISTS STAGE.UKG_EMPL_T;
    DROP TABLE IF EXISTS STAGE.UKG_EMPLOYEE_DATA_TEMP;

END

GO
