
                                                                                                                                                                                                                                                             
CREATE   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT]
                                                                                                                                                                                             
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
    SET NOCOUNT ON;
                                                                                                                                                                                                                                          
    DECLARE @today DATE = CAST(GETDATE() AS DATE);
                                                                                                                                                                                                           

                                                                                                                                                                                                                                                             
    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY]
                                                                                                                                                                                                       
    SELECT *,
                                                                                                                                                                                                                                                
        HASHBYTES('md5', CONCAT(
                                                                                                                                                                                                                             
            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
                                                                                                                                                               
        )) AS hash_value,
                                                                                                                                                                                                                                    
        NULL AS NOTE,
                                                                                                                                                                                                                                        
        @today AS snapshot_date
                                                                                                                                                                                                                              
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
                                                                                                                                                                                                                       
    WHERE NOT EXISTS (
                                                                                                                                                                                                                                       
        SELECT 1
                                                                                                                                                                                                                                             
    FROM [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY] hist
                                                                                                                                                                                                         
    WHERE hist.EMPLID = src.EMPLID
                                                                                                                                                                                                                           
        AND hist.hash_value = HASHBYTES('md5', CONCAT(
                                                                                                                                                                                                       
                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt
                                                                                                                           
            ))
                                                                                                                                                                                                                                               
    );
                                                                                                                                                                                                                                                       
END
                                                                                                                                                                                                                                                          
