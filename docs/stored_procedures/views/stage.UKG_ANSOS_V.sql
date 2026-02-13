
                                                                                                                                                                                                                                                             
CREATE         VIEW [stage].[UKG_ANSOS_V]
                                                                                                                                                                                                                    
AS
                                                                                                                                                                                                                                                           
SELECT CONVERT(VARCHAR,CONVERT(DATE,SUBSTRING([Effective_Date],5,4) + '-' + SUBSTRING([Effective_Date],1,2) + '-' + SUBSTRING([Effective_Date],3,2)),23) AS [Effective_Date]
                                                                                 
      ,[Person_Number] as Person_Number
                                                                                                                                                                                                                      
      ,[Start_Time]
                                                                                                                                                                                                                                          
      ,[Pay_Code_Name]
                                                                                                                                                                                                                                       
      ,FORMAT(CAST([Amount] AS INT) / 60.0, 'N2') AS [Amount]
                                                                                                                                                                                                
  FROM [dbo].[ANSOS_Imported]
                                                                                                                                                                                                                                
  WHERE
                                                                                                                                                                                                                                                      
  [Person_Number] NOT IN ('NV','no EMPLID')
                                                                                                                                                                                                                  
  ;
                                                                                                                                                                                                                                                          
