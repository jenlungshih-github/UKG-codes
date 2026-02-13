
                                                                                                                                                                                                                                                             
CREATE   PROCEDURE [stage].[SP_Check_Person_Business_Structure]
                                                                                                                                                                                              
    @emplid VARCHAR(11)
                                                                                                                                                                                                                                      
AS
                                                                                                                                                                                                                                                           
-- exec [stage].[SP_Check_Person_Business_Structure] @emplid = '10401420'
                                                                                                                                                                                    
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
--SELECT p.[Person Number]
                                                                                                                                                                                                                                   
--      , p.[First Name]
                                                                                                                                                                                                                                     
--      , p.[Last Name]
                                                                                                                                                                                                                                      
--      , p.[Parent Path]
                                                                                                                                                                                                                                    
--         , bs.[Parent Path] as UKG_BusinessStructure
                                                                                                                                                                                                       
--FROM [BCK].[Person_Import_LOOKUP] p                    -- source from [dbo].[UKG_EMPLOYEE_DATA]
                                                                                                                                                            
--    LEFT JOIN [BCK].[UKG_BusinessStructure_lookup] bs  -- source from [HealthTime].[hts].[UKG_BusinessStructure]
                                                                                                                                           
--    ON p.[Parent Path] = bs.[Parent Path]
                                                                                                                                                                                                                  
--WHERE p.[Person Number] IN (
                                                                                                                                                                                                                               
--    '10401420', '10405360', '10406848', '10409321', '10413689',
                                                                                                                                                                                            
--    '10415110', '10420612', '10422674', '10438746', '10467173',
                                                                                                                                                                                            
--    '10491749', '10578994', '10624479', '10649385', '10705785',
                                                                                                                                                                                            
--    '10715715', '10730925', '10744203', '10822439'
                                                                                                                                                                                                         
--)
                                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
    SELECT
                                                                                                                                                                                                                                                   
        empl.EMPLID,
                                                                                                                                                                                                                                         
        empl.[First Name],
                                                                                                                                                                                                                                   
        empl.[Last Name],
                                                                                                                                                                                                                                    
        empl.[Employment Status],
                                                                                                                                                                                                                            
        empl.[Home/Primary Job],
                                                                                                                                                                                                                             
        empl.DEPTID,
                                                                                                                                                                                                                                         
        empl.[Reports to Manager],
                                                                                                                                                                                                                           
        B.[Person Number],
                                                                                                                                                                                                                                   
        B.FundGroup,
                                                                                                                                                                                                                                         
        B.[Parent Path],
                                                                                                                                                                                                                                     
        B.Loaded_DT,
                                                                                                                                                                                                                                         
        CASE 
                                                                                                                                                                                                                                                
            WHEN UBS.combocode IS NOT NULL THEN 'MATCH FOUND'
                                                                                                                                                                                                
            ELSE 'NO MATCH'
                                                                                                                                                                                                                                  
        END AS BusinessStructure_Match_Status,
                                                                                                                                                                                                               
        UBS.combocode AS Matched_BusinessStructure_ComboCode
                                                                                                                                                                                                 
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
                                                                                                                                                                                                                      
        INNER JOIN stage.UKG_EMPL_Business_Structure B
                                                                                                                                                                                                       
        ON empl.EMPLID = B.[Person Number]
                                                                                                                                                                                                                   
        LEFT JOIN [hts].[UKG_BusinessStructure] UBS
                                                                                                                                                                                                          
        ON B.FundGroup = UBS.FundGroup
                                                                                                                                                                                                                       
    WHERE empl.EMPLID = @emplid;
                                                                                                                                                                                                                             
    -- Return row count for verification
                                                                                                                                                                                                                     
    IF @@ROWCOUNT = 0
                                                                                                                                                                                                                                        
    BEGIN
                                                                                                                                                                                                                                                    
        PRINT 'No employee found with EMPLID: ' + @emplid;
                                                                                                                                                                                                   
    END
                                                                                                                                                                                                                                                      
    ELSE
                                                                                                                                                                                                                                                     
    BEGIN
                                                                                                                                                                                                                                                    
        PRINT 'Employee data retrieved for EMPLID: ' + @emplid;
                                                                                                                                                                                              
    END
                                                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
END
                                                                                                                                                                                                                                                          
