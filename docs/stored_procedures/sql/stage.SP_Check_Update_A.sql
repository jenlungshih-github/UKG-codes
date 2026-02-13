
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
/*
                                                                                                                                                                                                                                                           
=============================================================================
                                                                                                                                                                                
Stored Procedure: SP_Check_Update_A
                                                                                                                                                                                                                          
Description: Checks if Check_Disabled=0 for MONITOR_A before executing date updates
                                                                                                                                                                          
Version: 1.0
                                                                                                                                                                                                                                                 
Created: 2025-12-16
                                                                                                                                                                                                                                          
Created by: Jim Shih
                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
Logic Explanation:
                                                                                                                                                                                                                                           
1. Checks if MONITOR_A exists in [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                      
2. Retrieves Check_Disabled value for MONITOR_A (0=enabled, 1=disabled)
                                                                                                                                                                                      
3. If Check_Disabled=1, executes sequential updates:
                                                                                                                                                                                                         
   - Update 1: Advances payenddt by 28 days
                                                                                                                                                                                                                  
   - Update 2: Sets payenddt_NEXT (+28 days) and Next_Monitor_Start_DT (+29 days)
                                                                                                                                                                            
   - Update 3: Sets Monitor_Start_DT (+1 day) and Monitor_End_DT (+25 days)
                                                                                                                                                                                  
   - Update 4: Sets MONITOR_A Check_Disabled=0 
                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
5. Provides comprehensive logging and error handling throughout process
                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
Execution: EXEC [stage].[SP_Check_Update_A];
                                                                                                                                                                                                                 

                                                                                                                                                                                                                                                             
Version History:
                                                                                                                                                                                                                                             
v1.0 (2025-12-16) - Initial creation with Check_Disabled logic and cross-monitor coordination
                                                                                                                                                                
=============================================================================
                                                                                                                                                                                
*/
                                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                             
CREATE   PROCEDURE [stage].[SP_Check_Update_A]
                                                                                                                                                                                                               
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
    DECLARE @Check_Disabled INT;
                                                                                                                                                                                                                             
    DECLARE @MonitorExists BIT = 0;
                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
    BEGIN TRY
                                                                                                                                                                                                                                                
        -- Check if MONITOR_A exists in the table
                                                                                                                                                                                                            
        IF EXISTS (SELECT 1
                                                                                                                                                                                                                                  
    FROM [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                              
    WHERE [Monitor] = 'MONITOR_A')
                                                                                                                                                                                                                           
        BEGIN
                                                                                                                                                                                                                                                
        SET @MonitorExists = 1;
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
        -- Get Check_Disabled for MONITOR_A (assuming Check_Disabled is a column in the table)
                                                                                                                                                               
        SELECT @Check_Disabled = ISNULL([Check_Disabled], -1)
                                                                                                                                                                                                
        FROM [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                          
        WHERE [Monitor] = 'MONITOR_A';
                                                                                                                                                                                                                       

                                                                                                                                                                                                                                                             
        PRINT 'MONITOR_A found. Check_Disabled = ' + CAST(@Check_Disabled AS VARCHAR(10));
                                                                                                                                                                   

                                                                                                                                                                                                                                                             
        -- Check if Check_Disabled = 0
                                                                                                                                                                                                                       
        IF @Check_Disabled = 1
                                                                                                                                                                                                                               
            BEGIN
                                                                                                                                                                                                                                            
            PRINT 'Condition met (Check_Disabled=1). Executing updates for MONITOR_A...';
                                                                                                                                                                    

                                                                                                                                                                                                                                                             
            -- Update 1: Update payenddt (add 28 days)
                                                                                                                                                                                                       
            UPDATE [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                    
                   SET [payenddt] = FORMAT(DATEADD(DAY, 28, CAST([payenddt] AS DATE)), 'yyyy-MM-dd'),
                                                                                                                                                        
                       [Update_DT] = GETDATE()
                                                                                                                                                                                                               
                 WHERE [Monitor] = 'MONITOR_A'
                                                                                                                                                                                                               
                AND [payenddt] IS NOT NULL;
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
            PRINT 'Update 1 completed: payenddt updated (added 28 days)';
                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
            -- Update 2: Update payenddt_NEXT and Next_Monitor_Start_DT
                                                                                                                                                                                      
            UPDATE [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                    
                   SET [payenddt_NEXT] = FORMAT(DATEADD(DAY, 28, CAST([payenddt] AS DATE)), 'yyyy-MM-dd'),
                                                                                                                                                   
                       [Next_Monitor_Start_DT] = FORMAT(DATEADD(DAY, 29, CAST([payenddt] AS DATE)), 'yyyy-MM-dd'),
                                                                                                                                           
                       [Update_DT] = GETDATE()
                                                                                                                                                                                                               
                 WHERE [Monitor] = 'MONITOR_A'
                                                                                                                                                                                                               
                AND [payenddt] IS NOT NULL;
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
            PRINT 'Update 2 completed: payenddt_NEXT (added 28 days) and Next_Monitor_Start_DT (added 29 days) updated';
                                                                                                                                     

                                                                                                                                                                                                                                                             
            -- Update 3: Update Monitor_Start_DT and Monitor_End_DT
                                                                                                                                                                                          
            UPDATE [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                    
                   SET [Monitor_Start_DT] = FORMAT(DATEADD(DAY, 1, CAST([payenddt] AS DATE)), 'yyyy-MM-dd'),
                                                                                                                                                 
                       [Monitor_End_DT] = FORMAT(DATEADD(DAY, 23, CAST([payenddt] AS DATE)), 'yyyy-MM-dd'),
                                                                                                                                                  
                       [Update_DT] = GETDATE()
                                                                                                                                                                                                               
                 WHERE [Monitor] = 'MONITOR_A'
                                                                                                                                                                                                               
                AND [payenddt] IS NOT NULL;
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
            PRINT 'Update 3 completed: Monitor_Start_DT (added 1 day) and Monitor_End_DT (added 25 days) updated';
                                                                                                                                           

                                                                                                                                                                                                                                                             
            -- Update 4: Set Check_Disabled to 0 for MONITOR_A after all updates are completed
                                                                                                                                                               
            UPDATE [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                    
                   SET [Check_Disabled] = 0,
                                                                                                                                                                                                                 
                       [Update_DT] = GETDATE()
                                                                                                                                                                                                               
                 WHERE [Monitor] = 'MONITOR_A';
                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
            PRINT 'Update 4 completed: Check_Disabled set to 1 for MONITOR_A';
                                                                                                                                                                               

                                                                                                                                                                                                                                                             
            ---- Update 5: Set Check_Disabled to 0 for MONITOR_B (change from 1 to 0)
                                                                                                                                                                        
            --UPDATE [stage].[UKG_Accrual_Monitor_Schedule]
                                                                                                                                                                                                  
            --       SET [Check_Disabled] = 0,
                                                                                                                                                                                                               
            --           [Update_DT] = GETDATE()
                                                                                                                                                                                                             
            --     WHERE [Monitor] = 'MONITOR_B'
                                                                                                                                                                                                             
            --    AND [Check_Disabled] = 1;
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
            --IF @@ROWCOUNT > 0
                                                                                                                                                                                                                              
            --    PRINT 'Update 5 completed: Check_Disabled set to 0 for MONITOR_B (was 1)'
                                                                                                                                                                  
            --ELSE
                                                                                                                                                                                                                                           
            --    PRINT 'Update 5 skipped: MONITOR_B not found or Check_Disabled was not 1';
                                                                                                                                                                 
            --PRINT 'All updates for MONITOR_A completed successfully.';
                                                                                                                                                                                     
        END
                                                                                                                                                                                                                                                  
            ELSE
                                                                                                                                                                                                                                             
            BEGIN
                                                                                                                                                                                                                                            
            PRINT 'Condition not met. Check_Disabled = ' + CAST(@Check_Disabled AS VARCHAR(10)) + ' (expected 0). No updates performed.';
                                                                                                                    
        END
                                                                                                                                                                                                                                                  
    END
                                                                                                                                                                                                                                                      
        ELSE
                                                                                                                                                                                                                                                 
        BEGIN
                                                                                                                                                                                                                                                
        PRINT 'MONITOR_A not found in [stage].[UKG_Accrual_Monitor_Schedule]. No updates performed.';
                                                                                                                                                        
    END
                                                                                                                                                                                                                                                      
        
                                                                                                                                                                                                                                                     
    END TRY
                                                                                                                                                                                                                                                  
    BEGIN CATCH
                                                                                                                                                                                                                                              
        -- Error handling
                                                                                                                                                                                                                                    
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
                                                                                                                                                                                                          
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
                                                                                                                                                                                            
        THROW;
                                                                                                                                                                                                                                               
    END CATCH
                                                                                                                                                                                                                                                
END
                                                                                                                                                                                                                                                          
