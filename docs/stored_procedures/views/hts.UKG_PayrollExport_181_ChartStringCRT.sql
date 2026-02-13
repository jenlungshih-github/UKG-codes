
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_PayrollExport_181_ChartStringCRT"
                                                                                                                                                                                                     
as
                                                                                                                                                                                                                                                           
SELECT   FundGroup, [FundGroup] +','+ [chartstring_I181]+','  CRTRecord
                                                                                                                                                                                      
  FROM [hts].[UKG_FundGroup_ChartString]
                                                                                                                                                                                                                     
  where  [chartstring_I181]  is not null
                                                                                                                                                                                                                     
