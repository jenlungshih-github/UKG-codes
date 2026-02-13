
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_ServiceLines_PHSO"
                                                                                                                                                                                                                    
as
                                                                                                                                                                                                                                                           
select distinct Code FinancialUnit, DepartmentRollup1ID ServiceLine
                                                                                                                                                                                          
from hts.UKG_StrataData s where entity = '16144'
                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
