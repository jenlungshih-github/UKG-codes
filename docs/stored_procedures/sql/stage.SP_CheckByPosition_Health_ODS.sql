
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
----------------------------------------------------------------------------------------------------
                                                                                                                                                         
-- Stored Procedure: [stage].[SP_CheckByPosition_Health_ODS]
                                                                                                                                                                                                 
-- Description: This stored procedure performs comprehensive checks on a position number
                                                                                                                                                                     
--              across multiple Health ODS tables to validate position data integrity and
                                                                                                                                                                    
--              business structure mappings used in UKG employee data processing.
                                                                                                                                                                            
--
                                                                                                                                                                                                                                                           
-- Purpose: Used for troubleshooting and validating position data when employees are
                                                                                                                                                                         
--          filtered out of UKG_EMPLOYEE_DATA_BUILD due to missing or invalid position
                                                                                                                                                                       
--          information.
                                                                                                                                                                                                                                     
--
                                                                                                                                                                                                                                                           
-- Checks Performed:
                                                                                                                                                                                                                                         
-- 1. Position status and department in PS_POSITION_DATA
                                                                                                                                                                                                     
-- 2. Department budget information in PS_DEPT_BUDGET_ERN
                                                                                                                                                                                                    
-- 3. Financial unit information in CURRENT_POSITION_PRI_FIN_UNIT
                                                                                                                                                                                            
-- 4. Business structure mapping between UCPath and UKG systems
                                                                                                                                                                                              
--
                                                                                                                                                                                                                                                           
-- Version Control:
                                                                                                                                                                                                                                          
-- Date Modified  |  Author      |   Description
                                                                                                                                                                                                             
-- ---------------|--------------|----------------------------------------------------
                                                                                                                                                                       
-- 2025-09-06     | Jim Shih     | Initial creation for position data validation
                                                                                                                                                                             
----------------------------------------------------------------------------------------------------
                                                                                                                                                         

                                                                                                                                                                                                                                                             
CREATE     PROCEDURE [stage].[SP_CheckByPosition_Health_ODS]
                                                                                                                                                                                                 
    @POSITION_NBR NVARCHAR(10)
                                                                                                                                                                                                                               
AS
                                                                                                                                                                                                                                                           
-- Example usage:
                                                                                                                                                                                                                                            
-- EXEC [stage].[SP_CheckByPosition_Health_ODS] @POSITION_NBR = '40686393';
                                                                                                                                                                                  
--
                                                                                                                                                                                                                                                           
-- Parameters:
                                                                                                                                                                                                                                               
-- @POSITION_NBR: The position number to check across all related tables
                                                                                                                                                                                     
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
    -- Create a table variable to store informational messages
                                                                                                                                                                                               
    DECLARE @messages TABLE (
                                                                                                                                                                                                                                
        message_id INT IDENTITY(1,1),
                                                                                                                                                                                                                        
        message_text VARCHAR(MAX)
                                                                                                                                                                                                                            
    );
                                                                                                                                                                                                                                                       

                                                                                                                                                                                                                                                             
    -- ============================================================================================
                                                                                                                                                          
    -- 1. POSITION STATUS AND DEPARTMENT VALIDATION
                                                                                                                                                                                                          
    -- ============================================================================================
                                                                                                                                                          
    -- Check POSN_STATUS (should be 'A' for Active) and deptid in STABLE.PS_POSITION_DATA
                                                                                                                                                                    
    -- This validates that the position exists and is currently active
                                                                                                                                                                                       
    INSERT INTO @messages
                                                                                                                                                                                                                                    
        (message_text)
                                                                                                                                                                                                                                       
    VALUES
                                                                                                                                                                                                                                                   
        ('1. Checking POSN_STATUS (should be A for Active) and deptid in STABLE.PS_POSITION_DATA');
                                                                                                                                                          

                                                                                                                                                                                                                                                             
    -- Display the current check message
                                                                                                                                                                                                                     
    SELECT message_id, message_text
                                                                                                                                                                                                                          
    FROM @messages
                                                                                                                                                                                                                                           
    WHERE message_id = 1;
                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
    -- Query position data, showing most recent records first
                                                                                                                                                                                                
    SELECT
                                                                                                                                                                                                                                                   
        POSN_STATUS,
                                                                                                                                                                                                                                         
        deptid,
                                                                                                                                                                                                                                              
        POSITION_NBR,
                                                                                                                                                                                                                                        
        EFFDT,
                                                                                                                                                                                                                                               
        DML_IND
                                                                                                                                                                                                                                              
    FROM health_ods.[health_ods].stable.PS_POSITION_DATA
                                                                                                                                                                                                     
    WHERE POSITION_NBR = @POSITION_NBR
                                                                                                                                                                                                                       
        AND dml_ind <> 'D'
                                                                                                                                                                                                                                   
    -- Exclude deleted records
                                                                                                                                                                                                                               
    ORDER BY effdt DESC;
                                                                                                                                                                                                                                     

                                                                                                                                                                                                                                                             
    -- ============================================================================================
                                                                                                                                                          
    -- 2. DEPARTMENT BUDGET VALIDATION
                                                                                                                                                                                                                       
    -- ============================================================================================
                                                                                                                                                          
    -- Check deptid and budget information in PS_DEPT_BUDGET_ERN
                                                                                                                                                                                             
    -- This ensures the position has proper budget allocation
                                                                                                                                                                                                
    INSERT INTO @messages
                                                                                                                                                                                                                                    
        (message_text)
                                                                                                                                                                                                                                       
    VALUES
                                                                                                                                                                                                                                                   
        ('2. Checking deptid and budget information in health_ods.[health_ods].stable.PS_DEPT_BUDGET_ERN');
                                                                                                                                                  

                                                                                                                                                                                                                                                             
    SELECT message_id, message_text
                                                                                                                                                                                                                          
    FROM @messages
                                                                                                                                                                                                                                           
    WHERE message_id = 2;
                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
    -- Query budget data, ordered by fiscal year and effective date
                                                                                                                                                                                          
    SELECT
                                                                                                                                                                                                                                                   
        deptid,
                                                                                                                                                                                                                                              
        POSITION_NBR,
                                                                                                                                                                                                                                        
        FISCAL_YEAR,
                                                                                                                                                                                                                                         
        EFFDT,
                                                                                                                                                                                                                                               
        EFFSEQ,
                                                                                                                                                                                                                                              
        BUDGET_SEQ,
                                                                                                                                                                                                                                          
        DML_IND
                                                                                                                                                                                                                                              
    FROM health_ods.[health_ods].stable.PS_DEPT_BUDGET_ERN
                                                                                                                                                                                                   
    WHERE POSITION_NBR = @POSITION_NBR
                                                                                                                                                                                                                       
        AND dml_ind <> 'D'
                                                                                                                                                                                                                                   
    -- Exclude deleted records
                                                                                                                                                                                                                               
    ORDER BY fiscal_year DESC, effdt DESC, effseq DESC, BUDGET_SEQ DESC;
                                                                                                                                                                                     

                                                                                                                                                                                                                                                             
    -- ============================================================================================
                                                                                                                                                          
    -- 3. FINANCIAL UNIT VALIDATION
                                                                                                                                                                                                                          
    -- ============================================================================================
                                                                                                                                                          
    -- Check FDM_COMBO_CD (UCPath combination code) and FUND_CODE in CURRENT_POSITION_PRI_FIN_UNIT
                                                                                                                                                           
    -- This validates the financial structure mapping for the position
                                                                                                                                                                                       
    INSERT INTO @messages
                                                                                                                                                                                                                                    
        (message_text)
                                                                                                                                                                                                                                       
    VALUES
                                                                                                                                                                                                                                                   
        ('3. Checking FDM_COMBO_CD (UCPath combo code) and FUND_CODE in [RPT].[CURRENT_POSITION_PRI_FIN_UNIT]');
                                                                                                                                             

                                                                                                                                                                                                                                                             
    SELECT message_id, message_text
                                                                                                                                                                                                                          
    FROM @messages
                                                                                                                                                                                                                                           
    WHERE message_id = 3;
                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
    -- Query financial unit data
                                                                                                                                                                                                                             
    SELECT
                                                                                                                                                                                                                                                   
        POSITION_NBR,
                                                                                                                                                                                                                                        
        FDM_COMBO_CD,
                                                                                                                                                                                                                                        
        FISCAL_YEAR,
                                                                                                                                                                                                                                         
		dist_Pct,
                                                                                                                                                                                                                                                  
		FUND_CODE,
                                                                                                                                                                                                                                                 
        deptid,
                                                                                                                                                                                                                                              
        DEPTID_CF,
                                                                                                                                                                                                                                           
        DEPTID_CF_DESCR
                                                                                                                                                                                                                                      
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
                                                                                                                                                                                       
    WHERE POSITION_NBR = @POSITION_NBR;
                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
    -- ============================================================================================
                                                                                                                                                          
    -- 4. BUSINESS STRUCTURE MAPPING VALIDATION
                                                                                                                                                                                                              
    -- ============================================================================================
                                                                                                                                                          
    -- Check if UCPath COMBOCODE maps correctly to UKG Business Structure
                                                                                                                                                                                    
    -- This is critical for UKG employee data processing - missing mappings will cause employees to be filtered out
                                                                                                                                          
    INSERT INTO @messages
                                                                                                                                                                                                                                    
        (message_text)
                                                                                                                                                                                                                                       
    VALUES
                                                                                                                                                                                                                                                   
        ('4. Checking UKG Business Structure mapping: UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD');
                                                                                                                                                                 

                                                                                                                                                                                                                                                             
    SELECT message_id, message_text
                                                                                                                                                                                                                          
    FROM @messages
                                                                                                                                                                                                                                           
    WHERE message_id = 4;
                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
    -- Query the business structure mapping
                                                                                                                                                                                                                  
    SELECT
                                                                                                                                                                                                                                                   
        FIN.POSITION_NBR,
                                                                                                                                                                                                                                    
        FIN.FDM_COMBO_CD as UCPath_COMBOCODE,
                                                                                                                                                                                                                
        UKG_BS.COMBOCODE as UKG_BusinessStructure_COMBOCODE,
                                                                                                                                                                                                 
        UKG_BS.Organization,
                                                                                                                                                                                                                                 
        UKG_BS.EntityTitle,
                                                                                                                                                                                                                                  
        UKG_BS.ServiceLineTitle,
                                                                                                                                                                                                                             
        UKG_BS.FinancialUnit,
                                                                                                                                                                                                                                
        UKG_BS.FundGroup
                                                                                                                                                                                                                                     
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
                                                                                                                                                                                   
        LEFT JOIN [hts].[UKG_BusinessStructure] UKG_BS
                                                                                                                                                                                                       
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
                                                                                                                                                                                                               
    WHERE FIN.POSITION_NBR = @POSITION_NBR;
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
    -- ============================================================================================
                                                                                                                                                          
    -- SUMMARY
                                                                                                                                                                                                                                               
    -- ============================================================================================
                                                                                                                                                          
    -- Return all informational messages for reference
                                                                                                                                                                                                       
    SELECT
                                                                                                                                                                                                                                                   
        message_id,
                                                                                                                                                                                                                                          
        message_text
                                                                                                                                                                                                                                         
    FROM @messages
                                                                                                                                                                                                                                           
    ORDER BY message_id;
                                                                                                                                                                                                                                     

                                                                                                                                                                                                                                                             
END;
                                                                                                                                                                                                                                                         
