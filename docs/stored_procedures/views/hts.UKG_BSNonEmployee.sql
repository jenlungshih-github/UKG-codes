
                                                                                                                                                                                                                                                             
CREATE VIEW "hts"."UKG_BSNonEmployee"
                                                                                                                                                                                                                        
AS
                                                                                                                                                                                                                                                           
SELECT *
                                                                                                                                                                                                                                                     
FROM (
                                                                                                                                                                                                                                                       
	SELECT '1 - Header' Type
                                                                                                                                                                                                                                    
		,' ' "Location Type"
                                                                                                                                                                                                                                       
		,' ' "Parent Path"
                                                                                                                                                                                                                                         
		,' ' "Location Name"
                                                                                                                                                                                                                                       
		,' ' "Full Name"
                                                                                                                                                                                                                                           
		,' ' "Description"
                                                                                                                                                                                                                                         
		,'Location Type|Parent Path|Location Name|Full Name|Description|Effective Date|Expiration Date|Address|Cost Center|Direct Work Percent|Indirect Work Percent|Timezone|Transferable|External ID' Record
                                                     
	
                                                                                                                                                                                                                                                            
	UNION ALL
                                                                                                                                                                                                                                                   
	
                                                                                                                                                                                                                                                            
	-- Service Line
                                                                                                                                                                                                                                             
	SELECT DISTINCT '2a - Service Line' Type
                                                                                                                                                                                                                    
		,'Service Line' "Location Type"
                                                                                                                                                                                                                            
		,Organization + '/' + EntityTitle "Parent Path"
                                                                                                                                                                                                            
		,ServiceLineTitle "Location Name"
                                                                                                                                                                                                                          
		,ServiceLineTitle "Full Name"
                                                                                                                                                                                                                              
		,ServiceLineTitle "Description"
                                                                                                                                                                                                                            
		,'Service Line' + '|' + Organization + '/' + EntityTitle + '|' + ServiceLineTitle + '|' + ServiceLineTitle + '|' + ServiceLineTitle + '|1900-01-01|3000-01-01|||||||' Record
                                                                               
	FROM hts.UKG_BusinessStructureNoEmployees s
                                                                                                                                                                                                                 
	WHERE NOT EXISTS (
                                                                                                                                                                                                                                          
			SELECT 'x'
                                                                                                                                                                                                                                                
			FROM hts.personimport p
                                                                                                                                                                                                                                   
			WHERE p.[Home Business Structure Level 3 - Service Line] = s.servicelinetitle
                                                                                                                                                                             
			)
                                                                                                                                                                                                                                                         
	
                                                                                                                                                                                                                                                            
	UNION ALL
                                                                                                                                                                                                                                                   
	
                                                                                                                                                                                                                                                            
	-- Financial Unit
                                                                                                                                                                                                                                           
	SELECT DISTINCT '2b - Financial Unit' Type
                                                                                                                                                                                                                  
		,'Financial Unit' "Location Type"
                                                                                                                                                                                                                          
		,Organization + '/' + EntityTitle + '/' + ServiceLineTitle "Parent Path"
                                                                                                                                                                                   
		,FinancialUnit "Location Name"
                                                                                                                                                                                                                             
		,FinancialUnit "Full Name"
                                                                                                                                                                                                                                 
		,FinancialUnitTitle "Description"
                                                                                                                                                                                                                          
		,'Financial Unit' + '|' + Organization + '/' + EntityTitle + '/' + ServiceLineTitle + '|' + FinancialUnit + '|' + FinancialUnit + '|' + FinancialUnitTitle + '|1900-01-01|3000-01-01|||||||' Record
                                                        
	FROM hts.UKG_BusinessStructureNoEmployees s
                                                                                                                                                                                                                 
	WHERE NOT EXISTS (
                                                                                                                                                                                                                                          
			SELECT 'x'
                                                                                                                                                                                                                                                
			FROM hts.personimport p
                                                                                                                                                                                                                                   
			WHERE p.[Home Business Structure Level 4 - Financial Unit] = s.financialunit
                                                                                                                                                                              
			)
                                                                                                                                                                                                                                                         
	
                                                                                                                                                                                                                                                            
	UNION ALL
                                                                                                                                                                                                                                                   
	
                                                                                                                                                                                                                                                            
	-- Fund Group
                                                                                                                                                                                                                                               
	SELECT DISTINCT '2c - Fund Group' Type
                                                                                                                                                                                                                      
		,'Fund Group' "Location Type"
                                                                                                                                                                                                                              
		,Organization + '/' + EntityTitle + '/' + ServiceLineTitle + '/' + FinancialUnit "Parent Path"
                                                                                                                                                             
		,FundGroup "Location Name"
                                                                                                                                                                                                                                 
		,FundGroup "Full Name"
                                                                                                                                                                                                                                     
		,FundGroupTitle "Description"
                                                                                                                                                                                                                              
		,'Fund Group' + '|' + Organization + '/' + EntityTitle + '/' + ServiceLineTitle + '/' + FinancialUnit + '|' + FundGroup + '|' + FundGroup + '|' + FundGroupTitle + '|1900-01-01|3000-01-01|||||||' Record
                                                  
	FROM hts.UKG_BusinessStructureNoEmployees s
                                                                                                                                                                                                                 
	WHERE NOT EXISTS (
                                                                                                                                                                                                                                          
			SELECT 'x'
                                                                                                                                                                                                                                                
			FROM hts.personimport p
                                                                                                                                                                                                                                   
			WHERE p.[Home Business Structure Level 5 - Fund Group] = s.fundgroup
                                                                                                                                                                                      
			)
                                                                                                                                                                                                                                                         
	
                                                                                                                                                                                                                                                            
	UNION ALL
                                                                                                                                                                                                                                                   
	
                                                                                                                                                                                                                                                            
	-- Generic Jobs
                                                                                                                                                                                                                                             
	SELECT DISTINCT '2d - Job' Type
                                                                                                                                                                                                                             
		,'Job' "Location Type"
                                                                                                                                                                                                                                     
		,Organization + '/' + EntityTitle + '/' + ServiceLineTitle + '/' + FundGroup "Parent Path"
                                                                                                                                                                 
		,[Home Primary Job] "Location Name"
                                                                                                                                                                                                                        
		,[Home Primary Job] "Full Name"
                                                                                                                                                                                                                            
		,jg.JobGroupTitle "Description"
                                                                                                                                                                                                                            
		,'Job' + '|' + Organization + '/' + EntityTitle + '/' + ServiceLineTitle + '/' + FundGroup + '|' + [Home Primary Job] + '|' + [Home Primary Job] + '|' + jg.JobGroupTitle + '|1900-01-01|3000-01-01|||||||' Record
                                         
	FROM hts.UKG_BusinessStructureNoEmployees s
                                                                                                                                                                                                                 
	JOIN hts.UKG_JobGroups jg ON jg.JobGroup = s.[Home Primary Job]
                                                                                                                                                                                             
	WHERE NOT EXISTS (
                                                                                                                                                                                                                                          
			SELECT 'x'
                                                                                                                                                                                                                                                
			FROM hts.personimport p
                                                                                                                                                                                                                                   
			WHERE p.[Home Business Structure Level 5 - Fund Group] = s.fundgroup
                                                                                                                                                                                      
			)
                                                                                                                                                                                                                                                         
	) a
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
