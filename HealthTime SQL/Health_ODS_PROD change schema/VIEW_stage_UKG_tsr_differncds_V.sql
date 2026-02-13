USE [HealthTime]
GO

/****** Object:  View [stage].[UKG_tsr_differncds_V]    Script Date: 11/2/2025 5:40:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--SELECT * 
--FROM [stage].[UKG_tsr_differncds_V]
--WHERE 
--1=1
--AND


/***************************************
* Created By: May Xu	
*-- 7/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- changed to FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN e
*******************************************/
ALTER     VIEW [stage].[UKG_tsr_differncds_V]
AS
SELECT setid
	,jobcode
	,replace(erncdstring, '|', '') differncds
FROM (
	SELECT e.setid
		,e.jobcode
		,STUFF((
				SELECT DISTINCT '| ' + e2.erncd
				FROM health_ods.[health_ODS].hcm_ods.PS_UC_SHFT_ONC_ERN e2
				WHERE e.jobcode = e2.jobcode
					AND e.setid = e2.setid
					AND e.effdt = e2.effdt
					AND e2.erncd IN (
						'ESD'
						,'NSD'
						,'WDD'
						,'CND'
						)
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS erncdstring
	FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN e
	INNER JOIN (
		SELECT setid
			,jobcode
			,erncd
			,max(effdt) effdt
		FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN s
		WHERE s.setid LIKE 'sd%'
		GROUP BY setid
			,erncd
			,jobcode
		) s ON s.jobcode = e.jobcode
		AND s.erncd = e.erncd
		AND s.effdt = e.effdt
		AND s.setid = e.setid
	WHERE e.setid LIKE 'sd%'
		AND e.erncd IN (
			'ESD'
			,'NSD'
			,'WDD'
			,'CND'
			)
	GROUP BY e.setid
		,e.jobcode
		,e.effdt
	) a
GO


