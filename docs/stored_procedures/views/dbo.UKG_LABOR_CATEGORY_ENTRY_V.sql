
                                                                                                                                                                                                                                                             
create   VIEW [dbo].[UKG_LABOR_CATEGORY_ENTRY_V]
                                                                                                                                                                                                             
AS
                                                                                                                                                                                                                                                           
SELECT [Labor Category Entry Name]
                                                                                                                                                                                                                           
      ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Description], ',', ''), '/', '-'),':',''),'(',''),')','') AS [Description]
                                                                                                                                   
      ,[InactiveFlag]
                                                                                                                                                                                                                                        
      ,[Labor Category Name]
                                                                                                                                                                                                                                 
FROM [dbo].[UKG_LABOR_CATEGORY_ENTRY]
                                                                                                                                                                                                                        

                                                                                                                                                                                                                                                             
