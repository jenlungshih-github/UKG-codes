USE [HealthTime]
GO

/****** Object:  View [hts].[UKG_FundGroup_ChartString]    Script Date: 10/28/2025 12:24:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [hts].[UKG_FundGroup_ChartString]
AS
-- 10/26/2025  Jim Shih: join the table from linked server health_ODS.[Health_ODS].
SELECT [ComboCode]
	,[FundGroup]
	,[FundGroupTitle]
	,[ActionUser]
	,[ActionDate]
	,rtrim(p.operating_unit) + '|' + '010000' + '|' + rtrim(p.deptid_cf) + '|' + rtrim(Fund_code) + '|' + rtrim(Project_ID) + '|' + rtrim(Class_FLD) + '|' + 
	rtrim(Product) + '|' + rtrim(program_Code) + '|' + rtrim(Budget_Ref) + '|' + rtrim(chartfield1) + '|' + rtrim(chartfield2) + '|' + rtrim(chartfield3) + '|' +  'SDFIN' chartstring_I181
	,  'SDMED'+ '|' + rtrim(p.operating_unit) + '|' + '010000' + '|' + rtrim(p.deptid_cf) + '|' + rtrim(Fund_code) + '|' + rtrim(Project_ID) + '||' + rtrim(Class_FLD) + '|' + 
	rtrim(Product) + '|' + rtrim(program_Code) + '|' + rtrim(Budget_Ref) + '|' + rtrim(chartfield1) + '|' + rtrim(chartfield2) + '|' + rtrim(chartfield3)  chartstring_I618
	,p.operating_unit
	,'010000' Account
	,p.deptid_cf deptid
	,Fund_code
	,Project_ID
	,Class_FLD
	,Product
	,program_Code
	,Budget_Ref
	,chartfield1
	,chartfield2
	,chartfield3
	,'SDFIN' SETID
FROM hts.[UKG_ComboCodeFundGroup] f
LEFT OUTER JOIN (
	SELECT *
	FROM health_ODS.[Health_ODS].hcm_ods.ps_acct_cd_tbl
	WHERE isnumeric(acct_cd) = 1
	) p ON cast(p.ACCT_CD AS INT) = f.combocode
GO


