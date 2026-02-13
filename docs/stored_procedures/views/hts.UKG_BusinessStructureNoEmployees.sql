
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_BusinessStructureNoEmployees"
                                                                                                                                                                                                         
AS
                                                                                                                                                                                                                                                           
-- Health Science
                                                                                                                                                                                                                                            
SELECT DISTINCT c.[combocode]
                                                                                                                                                                                                                                
	,c.[Organization]
                                                                                                                                                                                                                                           
	,c.[Entity]
                                                                                                                                                                                                                                                 
	,c.[EntityTitle]
                                                                                                                                                                                                                                            
	,c.[ServiceLine]
                                                                                                                                                                                                                                            
	,c.[ServiceLineTitle]
                                                                                                                                                                                                                                       
	,c.[FinancialUnit]
                                                                                                                                                                                                                                          
	,c.[FinancialUnitTitle]
                                                                                                                                                                                                                                     
	,c.[FundGroup]
                                                                                                                                                                                                                                              
	,c.[FundGroupTitle]
                                                                                                                                                                                                                                         
	,p1.[Home Primary Job]
                                                                                                                                                                                                                                      
	,j.JobGroupTitle
                                                                                                                                                                                                                                            
FROM [hts].[UKG_BusinessStructure] c
                                                                                                                                                                                                                         
JOIN hts.PersonImport p1 ON p1.[Home Business Structure Level 4 - Financial Unit] = c.[FinancialUnit]
                                                                                                                                                        
join hts.UKG_JobGroups j on j.jobgroup = p1.[Home Primary Job]
                                                                                                                                                                                               
WHERE NOT EXISTS (
                                                                                                                                                                                                                                           
		SELECT *
                                                                                                                                                                                                                                                   
		FROM hts.PersonImport p
                                                                                                                                                                                                                                    
		WHERE p.[Home Business Structure Level 5 - Fund Group] = c.FundGroup
                                                                                                                                                                                       
		)
                                                                                                                                                                                                                                                          
	AND c.[Organization] = 'UCSDH'
                                                                                                                                                                                                                              
	AND c.entity = '16130'
                                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
UNION ALL
                                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
-- PHSO
                                                                                                                                                                                                                                                      
SELECT DISTINCT c.[combocode]
                                                                                                                                                                                                                                
	,c.[Organization]
                                                                                                                                                                                                                                           
	,c.[Entity]
                                                                                                                                                                                                                                                 
	,c.[EntityTitle]
                                                                                                                                                                                                                                            
	,c.[ServiceLine]
                                                                                                                                                                                                                                            
	,c.[ServiceLineTitle]
                                                                                                                                                                                                                                       
	,c.[FinancialUnit]
                                                                                                                                                                                                                                          
	,c.[FinancialUnitTitle]
                                                                                                                                                                                                                                     
	,c.[FundGroup]
                                                                                                                                                                                                                                              
	,c.[FundGroupTitle]
                                                                                                                                                                                                                                         
	,p1.[Home Primary Job]
                                                                                                                                                                                                                                      
	,j.JobGroupTitle
                                                                                                                                                                                                                                            
FROM [hts].[UKG_BusinessStructure] c
                                                                                                                                                                                                                         
JOIN hts.PersonImport p1 ON p1.[Home Business Structure Level 3 - Service Line] = c.[ServiceLineTitle]
                                                                                                                                                       
join hts.UKG_JobGroups j on j.jobgroup = p1.[Home Primary Job]
                                                                                                                                                                                               
WHERE NOT EXISTS (
                                                                                                                                                                                                                                           
		SELECT *
                                                                                                                                                                                                                                                   
		FROM hts.PersonImport p
                                                                                                                                                                                                                                    
		WHERE p.[Home Business Structure Level 5 - Fund Group] = c.FundGroup
                                                                                                                                                                                       
		)
                                                                                                                                                                                                                                                          
	AND c.[Organization] = 'UCSDH'
                                                                                                                                                                                                                              
	AND c.entity = '16144'
                                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
UNION ALL
                                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
-- HPG
                                                                                                                                                                                                                                                       
SELECT DISTINCT c.[combocode]
                                                                                                                                                                                                                                
	,c.[Organization]
                                                                                                                                                                                                                                           
	,c.[Entity]
                                                                                                                                                                                                                                                 
	,c.[EntityTitle]
                                                                                                                                                                                                                                            
	,c.[ServiceLine]
                                                                                                                                                                                                                                            
	,c.[ServiceLineTitle]
                                                                                                                                                                                                                                       
	,c.[FinancialUnit]
                                                                                                                                                                                                                                          
	,c.[FinancialUnitTitle]
                                                                                                                                                                                                                                     
	,c.[FundGroup]
                                                                                                                                                                                                                                              
	,c.[FundGroupTitle]
                                                                                                                                                                                                                                         
	,p1.[Home Primary Job]
                                                                                                                                                                                                                                      
	,j.JobGroupTitle
                                                                                                                                                                                                                                            
FROM [hts].[UKG_BusinessStructure] c
                                                                                                                                                                                                                         
JOIN hts.PersonImport p1 ON p1.[Home Business Structure Level 4 - Financial Unit] = c.[FinancialUnit]
                                                                                                                                                        
join hts.UKG_JobGroups j on j.jobgroup = p1.[Home Primary Job]
                                                                                                                                                                                               
WHERE NOT EXISTS (
                                                                                                                                                                                                                                           
		SELECT *
                                                                                                                                                                                                                                                   
		FROM hts.PersonImport p
                                                                                                                                                                                                                                    
		WHERE p.[Home Business Structure Level 5 - Fund Group] = c.FundGroup
                                                                                                                                                                                       
		)
                                                                                                                                                                                                                                                          
	AND c.[Organization] = 'UCSDH'
                                                                                                                                                                                                                              
	AND c.entity = '16143'
                                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
UNION ALL
                                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
-- Medical Center
                                                                                                                                                                                                                                            
SELECT DISTINCT c.[combocode]
                                                                                                                                                                                                                                
	,c.[Organization]
                                                                                                                                                                                                                                           
	,c.[Entity]
                                                                                                                                                                                                                                                 
	,c.[EntityTitle]
                                                                                                                                                                                                                                            
	,c.[ServiceLine]
                                                                                                                                                                                                                                            
	,c.[ServiceLineTitle]
                                                                                                                                                                                                                                       
	,c.[FinancialUnit]
                                                                                                                                                                                                                                          
	,c.[FinancialUnitTitle]
                                                                                                                                                                                                                                     
	,c.[FundGroup]
                                                                                                                                                                                                                                              
	,c.[FundGroupTitle]
                                                                                                                                                                                                                                         
	,p1.[Home Primary Job]
                                                                                                                                                                                                                                      
	,j.JobGroupTitle
                                                                                                                                                                                                                                            
FROM [hts].[UKG_BusinessStructure] c
                                                                                                                                                                                                                         
JOIN hts.PersonImport p1 ON p1.[Home Business Structure Level 3 - Service Line] = c.[ServiceLineTitle]
                                                                                                                                                       
join hts.UKG_JobGroups j on j.jobgroup = p1.[Home Primary Job]
                                                                                                                                                                                               
WHERE NOT EXISTS (
                                                                                                                                                                                                                                           
		SELECT *
                                                                                                                                                                                                                                                   
		FROM hts.PersonImport p
                                                                                                                                                                                                                                    
		WHERE p.[Home Business Structure Level 5 - Fund Group] = c.FundGroup
                                                                                                                                                                                       
		)
                                                                                                                                                                                                                                                          
	AND c.[Organization] = 'UCSDH'
                                                                                                                                                                                                                              
	AND c.entity = '16242'
                                                                                                                                                                                                                                      

                                                                                                                                                                                                                                                             
UNION ALL
                                                                                                                                                                                                                                                    

                                                                                                                                                                                                                                                             
-- Non-Health
                                                                                                                                                                                                                                                
SELECT DISTINCT c.[combocode]
                                                                                                                                                                                                                                
	,c.[Organization]
                                                                                                                                                                                                                                           
	,c.[Entity]
                                                                                                                                                                                                                                                 
	,c.[EntityTitle]
                                                                                                                                                                                                                                            
	,c.[ServiceLine]
                                                                                                                                                                                                                                            
	,c.[ServiceLineTitle]
                                                                                                                                                                                                                                       
	,c.[FinancialUnit]
                                                                                                                                                                                                                                          
	,c.[FinancialUnitTitle]
                                                                                                                                                                                                                                     
	,c.[FundGroup]
                                                                                                                                                                                                                                              
	,c.[FundGroupTitle]
                                                                                                                                                                                                                                         
	,'Staff' [Home Primary Job]
                                                                                                                                                                                                                                 
	,'Staff'
                                                                                                                                                                                                                                                    
FROM [hts].[UKG_BusinessStructure] c
                                                                                                                                                                                                                         
WHERE NOT EXISTS (
                                                                                                                                                                                                                                           
		SELECT *
                                                                                                                                                                                                                                                   
		FROM hts.PersonImport p
                                                                                                                                                                                                                                    
		WHERE p.[Home Business Structure Level 5 - Fund Group] = c.FundGroup
                                                                                                                                                                                       
		)
                                                                                                                                                                                                                                                          
	AND c.[Organization] = 'Non-Health'
                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
