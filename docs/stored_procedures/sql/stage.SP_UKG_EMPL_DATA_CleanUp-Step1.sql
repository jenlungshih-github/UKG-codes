
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
/***************************************
                                                                                                                                                                                                                     
* Stored Procedure: [stage].[* EXEC [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]]
                                                                                                                                                                                
* Purpose: Clean up duplicate employee records in UKG_EMPLOYEE_DATA table
                                                                                                                                                                                    
* 
                                                                                                                                                                                                                                                           
* Logic:
                                                                                                                                                                                                                                                     
* 1. Identifies employees with duplicate records (same EMPLID appearing multiple times)
                                                                                                                                                                      
* 2. For duplicate employees, removes records where FTE = 0 (zero FTE positions)
                                                                                                                                                                             
* 3. Keeps records with non-zero FTE values as these represent active positions
                                                                                                                                                                              
* 4. Uses transaction control to ensure data integrity
                                                                                                                                                                                                       
* 5. Provides detailed logging of cleanup operations
                                                                                                                                                                                                         
* 
                                                                                                                                                                                                                                                           
* Example execution:
                                                                                                                                                                                                                                         
* EXEC [stage].[* EXEC [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]]
                                                                                                                                                                                             
* 
                                                                                                                                                                                                                                                           
* Created: 9/5/2025
                                                                                                                                                                                                                                          
* Modified: 9/5/2025 - Added comprehensive logging and error handling
                                                                                                                                                                                        
* Modified: 12/02/2025 Jim Shih - Replace [dbo].[UKG_EMPLOYEE_DATA] with [dbo].[UKG_EMPLOYEE_DATA_TEMP]
                                                                                                                                                      
******************************************/
                                                                                                                                                                                                                  

                                                                                                                                                                                                                                                             
CREATE       PROCEDURE [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]
                                                                                                                                                                                              
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
    DECLARE @RowsDeleted INT = 0;
                                                                                                                                                                                                                            
    DECLARE @ErrorMessage NVARCHAR(4000);
                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
    BEGIN TRY
                                                                                                                                                                                                                                                
        BEGIN TRANSACTION;
                                                                                                                                                                                                                                   
        
                                                                                                                                                                                                                                                     
        PRINT 'Starting cleanup of duplicate employee records with FTE = 0...';
                                                                                                                                                                              
        
                                                                                                                                                                                                                                                     
        WITH
                                                                                                                                                                                                                                                 
        duplicate_employees
                                                                                                                                                                                                                                  
        AS
                                                                                                                                                                                                                                                   
        (
                                                                                                                                                                                                                                                    
            SELECT emplid, count(emplid) as emp_count
                                                                                                                                                                                                        
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
                                                                                                                                                                                                              
            GROUP BY emplid
                                                                                                                                                                                                                                  
            HAVING count(emplid) > 1
                                                                                                                                                                                                                         
        ),
                                                                                                                                                                                                                                                   
        records_to_delete
                                                                                                                                                                                                                                    
        AS
                                                                                                                                                                                                                                                   
        (
                                                                                                                                                                                                                                                    
            SELECT
                                                                                                                                                                                                                                           
                empl.emplid,
                                                                                                                                                                                                                                 
                empl.position_nbr,
                                                                                                                                                                                                                           
                empl.FTE
                                                                                                                                                                                                                                     
            FROM duplicate_employees de
                                                                                                                                                                                                                      
                JOIN [dbo].[UKG_EMPLOYEE_DATA_TEMP] empl
                                                                                                                                                                                                     
                ON empl.emplid = de.emplid
                                                                                                                                                                                                                   
            WHERE empl.FTE = 0
                                                                                                                                                                                                                               
        )
                                                                                                                                                                                                                                                    
            DELETE ukg_empl
                                                                                                                                                                                                                                  
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] ukg_empl
                                                                                                                                                                                                     
        JOIN records_to_delete rtd
                                                                                                                                                                                                                           
        ON ukg_empl.emplid = rtd.emplid
                                                                                                                                                                                                                      
            AND ukg_empl.position_nbr = rtd.position_nbr;
                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
        SET @RowsDeleted = @@ROWCOUNT;
                                                                                                                                                                                                                       

                                                                                                                                                                                                                                                             
        PRINT 'Duplicate records with FTE = 0 deleted: ' + CAST(@RowsDeleted AS VARCHAR(10));
                                                                                                                                                                
        
                                                                                                                                                                                                                                                     
        COMMIT TRANSACTION;
                                                                                                                                                                                                                                  
        
                                                                                                                                                                                                                                                     
        PRINT 'Cleanup operations completed successfully.';
                                                                                                                                                                                                  
        PRINT 'Total records deleted: ' + CAST(@RowsDeleted AS VARCHAR(10));
                                                                                                                                                                                 
        
                                                                                                                                                                                                                                                     
    END TRY
                                                                                                                                                                                                                                                  
    BEGIN CATCH
                                                                                                                                                                                                                                              
        ROLLBACK TRANSACTION;
                                                                                                                                                                                                                                
        
                                                                                                                                                                                                                                                     
        SET @ErrorMessage = ERROR_MESSAGE();
                                                                                                                                                                                                                 
        PRINT 'Error occurred during cleanup operation: ' + @ErrorMessage;
                                                                                                                                                                                   
        PRINT 'Transaction has been rolled back.';
                                                                                                                                                                                                           
        
                                                                                                                                                                                                                                                     
        -- Re-throw the error
                                                                                                                                                                                                                                
        THROW;
                                                                                                                                                                                                                                               
    END CATCH
                                                                                                                                                                                                                                                
END
                                                                                                                                                                                                                                                          
