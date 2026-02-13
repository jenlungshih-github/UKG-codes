USE [HealthTime]
GO

UPDATE [stage].[NON_UKG_MANAGER_LOG]
   SET 
      [Employment Status] = 'T'
      ,[Employment Status Effective Date] = FORMAT(getdate(), 'yyyy-MM-dd')
      ,[Update_DT] = getdate()
      ,[NOTE] = 'P'
 WHERE 
[Manager Flag]='F'
GO