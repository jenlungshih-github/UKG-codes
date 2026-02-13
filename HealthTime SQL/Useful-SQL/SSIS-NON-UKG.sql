select * 
from dbo.UKG_EMPLOYEE_DATA_v T
JOIN [dbo].[UKG_EMPLOYEE_DATA] S
ON S.[EMPLID]=T.[Person Number]
where
S.[NON_UKG_MANAGER_FLAG]='T'