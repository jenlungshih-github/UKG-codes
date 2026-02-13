
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_ServiceLines_MedicalCenter"
                                                                                                                                                                                                           
as
                                                                                                                                                                                                                                                           
select distinct Code FinancialUnit, DepartmentRollup2ID ServiceLine
                                                                                                                                                                                          
from hts.UKG_StrataData s where entity = '16242'
                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
