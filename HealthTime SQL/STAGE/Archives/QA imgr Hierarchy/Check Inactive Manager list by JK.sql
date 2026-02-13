/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
--[Inactive_EMPLID]
      [Inactive_EMPLID_POSITION_NBR] as POSITION_NBR
	  ,1 as Level_UP
      ,T.[MANAGER_EMPLID]
      ,T.[MANAGER_NAME]
      ,[MANAGER_POSITION_NBR]
	  ,M.POSN_LEVEL
  FROM [HealthTime].[stage].[UKG_ManagerHierarchy_TEMP] T
  LEFT JOIN [stage].[UKG_ManagerHierarchy] M
  ON
  T.[MANAGER_POSITION_NBR]=M.POSITION_NBR

  where
[Inactive_EMPLID_POSITION_NBR]
IN (
    '40688126', '40695802', '40697146', '40699053', '40700950', '40702349',
    '40703703', '40704589', '40709698', '40709834', '40887613', '41042579'
)

ORDER BY M.POSN_LEVEL asc
GO


--SELECT * 
--FROM [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]
--WHERE 
--[POSITION_NBR]='41156004'



/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
--[Inactive_EMPLID]
      [Inactive_EMPLID_POSITION_NBR] as POSITION_NBR
	  ,2 as Level_UP
      ,T.[MANAGER_EMPLID]
      ,T.[MANAGER_NAME]
      ,[MANAGER_POSITION_NBR]
	  ,M.POSN_LEVEL
  FROM [HealthTime].[stage].[UKG_ManagerHierarchy_TEMP] T
  LEFT JOIN [stage].[UKG_ManagerHierarchy] M
  ON
  T.[MANAGER_POSITION_NBR]=M.POSITION_NBR

  where
[Inactive_EMPLID_POSITION_NBR]
IN (
'40707643'
)

ORDER BY M.POSN_LEVEL asc
GO