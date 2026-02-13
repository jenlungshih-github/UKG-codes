
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_PayrollExport_618_ChartStringCRT"
                                                                                                                                                                                                     
as
                                                                                                                                                                                                                                                           
SELECT  FundGroup, [FundGroup] +','+ [chartstring_I618]  CRTRecord
                                                                                                                                                                                           
  FROM [hts].[UKG_FundGroup_ChartString]
                                                                                                                                                                                                                     
  where  [chartstring_I618]  is not null
                                                                                                                                                                                                                     
