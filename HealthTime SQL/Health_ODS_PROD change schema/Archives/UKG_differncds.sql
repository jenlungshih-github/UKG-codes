USE [HealthTime]
GO

/****** Object:  View [hts].[UKG_differncds]    Script Date: 10/28/2025 12:23:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE OR ALTER VIEW [hts].[UKG_differncds]

AS
-- 10/26/2025  Jim Shih: join the table from linked server health_ODS.[Health_ODS].
SELECT setid
	,jobcode
	,replace(erncdstring, '|', '') differncds
FROM (
	SELECT e.setid
		,e.jobcode
		,STUFF((
				SELECT DISTINCT '| ' + e2.erncd
				FROM health_ods.hcm_ods.PS_UC_SHFT_ONC_ERN e2
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
	FROM health_ODS.[Health_ODS].hcm_ods.PS_UC_SHFT_ONC_ERN e
	INNER JOIN (
		SELECT setid
			,jobcode
			,erncd
			,max(effdt) effdt
		FROM health_ODS.[Health_ODS].hcm_ods.PS_UC_SHFT_ONC_ERN s
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


