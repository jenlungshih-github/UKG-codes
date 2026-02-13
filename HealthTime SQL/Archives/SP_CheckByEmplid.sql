USE [Health_ODS_SSN]
GO

/****** Object:  StoredProcedure [stage].[SP_CheckByEmplid]    Script Date: 7/21/2025 4:41:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored procedure to check data by emplid
-- To execute this stored procedure, use the following command:
-- Replace <your_emplid> with the actual emplid you want to check.
-- EXEC stage.SP_CheckByEmplid @emplid = 10015489


ALTER   PROCEDURE [stage].[SP_CheckByEmplid] (
    @emplid INT
)
AS
BEGIN
    -- Set @emplid to a default value if it's NULL
    IF @emplid IS NULL
    BEGIN
        SET @emplid = 10015489;  -- You can change the default value here
    END

-- Section 1: PS_JOB - Retrieves current job information for the given emplid
    SELECT J.EMPLID, j.EMPL_RCD, J.DEPTID, BUSINESS_UNIT, LOCATION, 
           JOB_INDICATOR, FTE,UNION_CD, JOBCODE,J.POSITION_NBR, 
           ROW_NUMBER() OVER(Partition by emplid ORDER BY (CASE WHEN JOB_INDICATOR = 'N' THEN 'Z' ELSE JOB_INDICATOR END ), FTE DESC ) AS ROW_NO
      FROM [HEALTH_ODS].[STABLE].PS_JOB J
     WHERE 
    J.emplid=@emplid and
    J.DML_IND <> 'D'                          
      AND J.HR_STATUS = 'A'   
      AND J.EFFDT =                                                                                                                 
     (SELECT MAX(J1.EFFDT)                                                                                                                           
        FROM [HEALTH_ODS].[STABLE].PS_JOB J1                                                                                                                            
       WHERE J1.EMPLID = J.EMPLID                                                                                                                
         AND J1.EMPL_RCD = J.EMPL_RCD                                                                                                                     
         AND J1.EFFDT  <=  GETDATE()
         AND J1.DML_IND <> 'D'    )                                                                                                                         
     AND J.EFFSEQ =                                                                                                               
     (SELECT MAX(J2.EFFSEQ)                                                                                                                         
        FROM [HEALTH_ODS].[STABLE].PS_JOB J2                                                                                                                            
       WHERE J2.EMPLID = J.EMPLID                                                                                                                
         AND J2.EMPL_RCD = J.EMPL_RCD                                                                                                                        
         AND J2.EFFDT    = J.EFFDT AND J2.DML_IND <> 'D'  )

    PRINT 'Section 1: PS_JOB - Retrieved current job information for the given emplid.';

-- Section 2: PS_JOB - Retrieves distinct job information, ordered by last hire date
    SELECT distinct --TOP 5
    J.EMPLID,  J.DEPTID, BUSINESS_UNIT, JOB_INDICATOR, J.TERMINATION_DT, J.HIRE_DT, J.LAST_HIRE_DT, J.HR_STATUS, J.ACTION, J.ACTION_DT, J.LOCATION, J.DML_IND, J.LASTUPDDTTM, J.UPD_BT_DTM ,ROW_NUMBER() OVER(Partition by emplid ORDER BY last_hire_dt desc, hire_dt desc, TERMINATION_DT desc, (CASE WHEN JOB_INDICATOR = 'N' THEN 'Z' ELSE JOB_INDICATOR END )) AS ROW_NO
    FROM [HEALTH_ODS].[STABLE].PS_JOB J
    WHERE 
    J.DML_IND <> 'D'     
    and 
    J.emplid=@emplid
    order by LAST_HIRE_DT desc

    PRINT 'Section 2: PS_JOB - Retrieved distinct job information, ordered by last hire date.';

---- Section 3: CURRENT_EMPL_DATA_V - Retrieves employee data from the CURRENT_EMPL_DATA_V view
--    SELECT emplid, effdt, EMPL_RCD, ROW_NUMBER() OVER(Partition by emplid ORDER BY effdt desc, empl_rcd desc) as rown,*
--    FROM health_ods.[RPT].[CURRENT_EMPL_DATA_V] D1
--    WHERE 
--    emplid=@emplid
--    -- and
--    -- D1.effdt='2022-10-01'
--    -- and
--    -- D1.EMPL_RCD='3'
--    --and D1.EFFDT= (select MAX(effdt) from Health_ODS.[RPT].[CURRENT_EMPL_DATA_V] D2 where D1.EMPLID=D2.EMPLID)
--    --and D1.EMPL_RCD = (select MAX(EMPL_RCD) from Health_ODS.[RPT].[CURRENT_EMPL_DATA_V] D3 where D1.EMPLID=D3.EMPLID)

--    PRINT 'Section 3: CURRENT_EMPL_DATA_V - Retrieved employee data from the CURRENT_EMPL_DATA_V view.';

-- Section 4: CURRENT_EMPL_DATA_V - Retrieves employee data with HR_STATUS
    SELECT emplid, effdt, EMPL_RCD, HR_STATUS,ROW_NUMBER() OVER(Partition by emplid ORDER BY effdt desc, empl_rcd desc) as rown
    FROM health_ods.[RPT].[CURRENT_EMPL_DATA_V]
    where 
    --HR_STATUS='A'
    --and 
    emplid=@emplid

    PRINT 'Section 4: CURRENT_EMPL_DATA_V - Retrieved employee data with HR_STATUS.';

-- Section 5: Current_VIP_CODE - Retrieves data from the Current_VIP_CODE table
    SELECT * 
    FROM dbo.[Current_VIP_CODE]
    WHERE 
    emplid=@emplid

    PRINT 'Section 5: Current_VIP_CODE - Retrieved data from the Current_VIP_CODE table.';

-- Section 6: Current_SDE - Retrieves data from the Current_SDE table
    SELECT * 
    FROM dbo.[Current_SDE]
    WHERE 
    emplid=@emplid
    --AND

    PRINT 'Section 6: Current_SDE - Retrieved data from the Current_SDE table.';

-- Section 7: datamart_CP_V - Retrieves data from the datamart_CP_V table
    SELECT * 
    FROM dbo.[datamart_CP_V]
    WHERE 
    emplid=@emplid
    --AND

    PRINT 'Section 7: datamart_CP_V - Retrieved data from the datamart_CP_V table.';

-- Section 8: datamart_CP_CURRENT - Retrieves data from the datamart_CP_CURRENT table
    --SELECT * 
    --FROM dbo.[datamart_CP_CURRENT]
    --WHERE 
    --emplid=@emplid
    --AND

    --PRINT 'Section 8: datamart_CP_CURRENT - Retrieved data from the datamart_CP_CURRENT table.';

---- Section 9: current_empl_data_V - Retrieves data from the current_empl_data_V view
--    SELECT * 
--    FROM health_ods.rpt.current_empl_data_V
--    WHERE 
--    emplid=@EMPLID
--    --AND

--    PRINT 'Section 9: current_empl_data_V - Retrieved data from the current_empl_data_V view.';

-- Section 10: EMPLOYEE_ORGANIZATION_V - Retrieves data from the EMPLOYEE_ORGANIZATION_V view
    SELECT * 
    FROM health_ods.rpt.EMPLOYEE_ORGANIZATION_V
    WHERE 
    emplid=@EMPLID
    --AND
    --AND

    PRINT 'Section 10: EMPLOYEE_ORGANIZATION_V - Retrieved data from the EMPLOYEE_ORGANIZATION_V view.';

-- Section 11: COEM_SNAPSHOT_ALL - Retrieves data from the COEM_SNAPSHOT_ALL table
    SELECT * 
    FROM COEM_SNAPSHOT_ALL
    WHERE 
    emplid=@emplid

    PRINT 'Section 11: COEM_SNAPSHOT_ALL - Retrieved data from the COEM_SNAPSHOT_ALL table.';

---- Section 12: COEM_SNAPSHOT - Retrieves data from the COEM_SNAPSHOT table
--    SELECT * 
--    FROM COEM_SNAPSHOT
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 12: COEM_SNAPSHOT - Retrieved data from the COEM_SNAPSHOT table.';

---- Section 13: CTE - Retrieves data from the stage.CTE table
--    SELECT * 
--    FROM stage.CTE
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 13: CTE - Retrieved data from the stage.CTE table.';

-- Section 14: COEM_V - Retrieves data from the [stable].[COEM_V] table
    SELECT * 
    FROM [stable].[COEM_V]
    WHERE 
    emplid=@emplid

    PRINT 'Section 14: COEM_V - Retrieved data from the [stable].[COEM_V] table.';

---- Section 15: EMPLOYEE_ORGANIZATION - Retrieves data from the health_ods.RPT.EMPLOYEE_ORGANIZATION table
--    SELECT * 
--    FROM health_ods.RPT.EMPLOYEE_ORGANIZATION
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 15: EMPLOYEE_ORGANIZATION - Retrieved data from the health_ods.RPT.EMPLOYEE_ORGANIZATION table.';

---- Section 16: COEM_V - Retrieves emplid and a hash value from the [stable].[COEM_V] table
--    SELECT emplid, HASHBYTES('md5', concat(emplid, VIP_CODE, HR_STATUS)) as new_hash_value
--    FROM [stable].[COEM_V]
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 16: COEM_V - Retrieved emplid and a hash value from the [stable].[COEM_V] table.';

---- Section 17: coem_delta - Retrieves data from the coem_delta table
--    SELECT emplid, new_hash_value,*
--    FROM coem_delta
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 17: coem_delta - Retrieved data from the coem_delta table.';

-- Section 18: COEM_SNAPSHOT - Retrieves data from the COEM_SNAPSHOT table
    SELECT emplid, new_hash_value,*
    FROM COEM_SNAPSHOT
    WHERE 
    emplid=@emplid

    PRINT 'Section 18: COEM_SNAPSHOT - Retrieved data from the COEM_SNAPSHOT table.';

---- Section 19: COEM_SNAPSHOT_ALL - Retrieves data from the COEM_SNAPSHOT_ALL table
--    SELECT emplid, new_hash_value,* 
--    FROM COEM_SNAPSHOT_ALL
--    WHERE 
--    emplid=@emplid

--    PRINT 'Section 19: COEM_SNAPSHOT_ALL - Retrieved data from the COEM_SNAPSHOT_ALL table.';

---- Section 20: current_empl_data_V - Retrieves employee data and HR status from the Health_ODS.rpt.current_empl_data_V view
--    SELECT emplid, hr_status,* 
--    FROM Health_ODS.rpt.current_empl_data_V
--    WHERE 
--    emplid=@emplid
--    --AND

--    PRINT 'Section 20: current_empl_data_V - Retrieved employee data and HR status from the Health_ODS.rpt.current_empl_data_V view.';
END
GO


