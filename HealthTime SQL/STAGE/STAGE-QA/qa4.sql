SELECT
    [position_nbr]
      , [EMPLID]
, [DEPTID]
      , [VC_CODE]
      , [REPORTS_TO]
      , [MANAGER_EMPLID]
      , [NON_UKG_MANAGER_FLAG]

      , [jobcode]
      , [POSITION_DESCR]
      , [FTE_SUM]
      , [empl_Status]
      , [FundGroup]
	  , [Home Business Structure Level 1 - Organization]
, getdate() as snapshot_DT
INTO stage.QA_Blank_Acct_Code
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE 
[FDM_COMBO_CD] is null
    and
    [COMBOCODE] is null