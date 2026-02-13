
                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
CREATE VIEW [hts].[UKG_ODSFinancialUnits]
                                                                                                                                                                                                                    
as
                                                                                                                                                                                                                                                           
-- 10/26/2025  Jim Shih: join the table from linked server health_ODS.[Health_ODS].
                                                                                                                                                                          
	SELECT d.deptid
                                                                                                                                                                                                                                             
		,d.descr DeptTitle
                                                                                                                                                                                                                                         
	FROM health_ODS.[Health_ODS].hcm_ods.PS_DEPT_TBL d
                                                                                                                                                                                                          
	INNER JOIN (
                                                                                                                                                                                                                                                
		SELECT deptid
                                                                                                                                                                                                                                              
			,max(effdt) effdt
                                                                                                                                                                                                                                         
		FROM health_ODS.[Health_ODS].hcm_ods.PS_DEPT_TBL
                                                                                                                                                                                                           
		WHERE setid = 'SDFIN'
                                                                                                                                                                                                                                      
		GROUP BY deptid
                                                                                                                                                                                                                                            
		) m ON m.deptid = d.deptid
                                                                                                                                                                                                                                 
		AND m.effdt = d.effdt
                                                                                                                                                                                                                                      
	WHERE setid = 'SDFIN'
                                                                                                                                                                                                                                       
