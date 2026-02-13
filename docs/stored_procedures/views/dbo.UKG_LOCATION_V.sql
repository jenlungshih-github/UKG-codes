
                                                                                                                                                                                                                                                             
CREATE VIEW "dbo"."UKG_LOCATION_V"
                                                                                                                                                                                                                           
AS
                                                                                                                                                                                                                                                           
SELECT 
                                                                                                                                                                                                                                                      
    REPLACE([Location Type], '/', '-') AS [Location Type],
                                                                                                                                                                                                   
--    REPLACE([Parent Path], '/', '-') AS [Parent Path],
                                                                                                                                                                                                     
 [Parent Path],
                                                                                                                                                                                                                                              
    REPLACE([Location Name], '/', '-') AS [Location Name],
                                                                                                                                                                                                   
    REPLACE([Full Name], '/', '-') AS [Full Name],
                                                                                                                                                                                                           
    REPLACE([Description], '/', '-') AS [Description],
                                                                                                                                                                                                       
    REPLACE([Effective Date], '/', '-') AS [Effective Date],
                                                                                                                                                                                                 
    REPLACE([Expiration Date], '/', '-') AS [Expiration Date],
                                                                                                                                                                                               
    REPLACE([Address], '/', '-') AS [Address],
                                                                                                                                                                                                               
    REPLACE([Cost Center], '/', '-') AS [Cost Center],
                                                                                                                                                                                                       
    REPLACE([Direct Work Percent], '/', '-') AS [Direct Work Percent],
                                                                                                                                                                                       
    REPLACE([Indirect Work Percent], '/', '-') AS [Indirect Work Percent],
                                                                                                                                                                                   
    REPLACE([Timezone], '/', '-') AS [Timezone],
                                                                                                                                                                                                             
    REPLACE([Transferable], '/', '-') AS [Transferable],
                                                                                                                                                                                                     
    REPLACE([External ID], '/', '-') AS [External ID]
                                                                                                                                                                                                        
FROM [dbo].[UKG_LOCATION]
                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
