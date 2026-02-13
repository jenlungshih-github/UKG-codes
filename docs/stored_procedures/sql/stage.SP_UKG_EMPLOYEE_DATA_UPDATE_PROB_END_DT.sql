
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
Create     PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_UPDATE_PROB_END_DT]
                                                                                                                                                                                       
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
    BEGIN TRY
                                                                                                                                                                                                                                                
        BEGIN TRANSACTION;
                                                                                                                                                                                                                                   

                                                                                                                                                                                                                                                             
        -- Update the [Custom Date 1] 
                                                                                                                                                                                                                       
        UPDATE [dbo].[UKG_EMPLOYEE_DATA]
                                                                                                                                                                                                                     
        SET 
                                                                                                                                                                                                                                                 
            [Custom Date 1] = DATEADD(DAY, 1, lookup.uc_prob_end_dt)
                                                                                                                                                                                         
--            [NOTE] = CONCAT('U, Custom Date 1 has retained prob_end_dt and was updated on ', CONVERT(VARCHAR, GETDATE(), 120))
                                                                                                                             
        FROM [dbo].[UKG_EMPLOYEE_DATA] empl_data
                                                                                                                                                                                                             
        JOIN health_ods.[health_ods].stage.UKG_probation_dt_retain_lookup_V lookup
                                                                                                                                                                           
        ON empl_data.position_nbr = lookup.position_nbr
                                                                                                                                                                                                      
        WHERE empl_data.position_nbr IS NOT NULL
                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
        -- Commit the transaction
                                                                                                                                                                                                                            
        COMMIT TRANSACTION;
                                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
    END TRY
                                                                                                                                                                                                                                                  
    BEGIN CATCH
                                                                                                                                                                                                                                              
        -- Rollback the transaction in case of an error
                                                                                                                                                                                                      
        IF @@TRANCOUNT > 0
                                                                                                                                                                                                                                   
            ROLLBACK TRANSACTION;
                                                                                                                                                                                                                            

                                                                                                                                                                                                                                                             
        -- Raise the error
                                                                                                                                                                                                                                   
        THROW;
                                                                                                                                                                                                                                               
    END CATCH;
                                                                                                                                                                                                                                               
END;
                                                                                                                                                                                                                                                         
