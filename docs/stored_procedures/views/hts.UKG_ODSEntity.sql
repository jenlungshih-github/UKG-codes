
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
CREATE   VIEW [hts].[UKG_ODSEntity] 
                                                                                                                                                                                                                         
as
                                                                                                                                                                                                                                                           
-- 10/26/2025  Jim Shih: join the table from linked server health_ODS.[Health_ODS].
                                                                                                                                                                          
SELECT o.operating_unit Entity
                                                                                                                                                                                                                               
		,o.DESCR EntityTitle
                                                                                                                                                                                                                                       
	FROM health_ODS.[Health_ODS].hcm_ods.PS_OPER_UNIT_TBL o
                                                                                                                                                                                                     
	INNER JOIN (
                                                                                                                                                                                                                                                
		SELECT operating_unit
                                                                                                                                                                                                                                      
			,max(effdt) effdt
                                                                                                                                                                                                                                         
		FROM health_ODS.[Health_ODS].hcm_ods.PS_OPER_UNIT_TBL
                                                                                                                                                                                                      
		WHERE setid = 'SDFIN'
                                                                                                                                                                                                                                      
		GROUP BY operating_unit
                                                                                                                                                                                                                                    
		) m ON m.operating_unit = o.operating_unit
                                                                                                                                                                                                                 
	WHERE setid = 'SDFIN'
                                                                                                                                                                                                                                       
