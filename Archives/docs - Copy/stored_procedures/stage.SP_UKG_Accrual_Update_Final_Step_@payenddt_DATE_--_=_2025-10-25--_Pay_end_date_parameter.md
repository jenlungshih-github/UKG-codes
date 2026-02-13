# stage.SP_UKG_Accrual_Update_Final_Step_@payenddt_DATE_--_=_2025-10-25--_Pay_end_date_parameter

Source: docs/stored_procedures/all_procedures.sql

Link to SQL: sql/stage.SP_UKG_Accrual_Update_Final_Step_@payenddt_DATE_--_=_2025-10-25--_Pay_end_date_parameter.sql

Detected features:
- uses_hashbytes: False
- uses_merge: False
- uses_select_into: False
- uses_temp_tables: False
- uses_dynamic_sql: False
- uses_transactions: False
- uses_drop_table_if_exists: False

---

```sql
/*=============================================================================Stored Procedure: stage.SP_UKG_Accrual_Update_Final_StepDescription: Final step in UKG accrual processing - updates records with              processed flag and pay end dateVersion: 1.0Created: 2025-11-04Created by: Jim ShihExec Method: exec stage.SP_UKG_Accrual_Update_Final_Step @payenddt='2025-10-25'=============================================================================*/CREATE   PROCEDURE [stage].[SP_UKG_Accrual_Update_Final_Step]    @payenddt DATE -- = '2025-10-25'-- Pay end date parameter with default valueASBEGIN    SET NOCOUNT ON;    BEGIN TRY        -- Logic: Update all unprocessed accrual records (where NOTE IS NULL)        -- Set NOTE to 'P' (Processed) and assign the pay end date        UPDATE [dbo].[UKG_UCPATH_ACCRUAL]           SET NOTE = 'P'                    -- Mark as Processed              ,payenddt = @payenddt          -- Set pay end date         WHERE NOTE IS NULL;                 -- Only update unprocessed records                -- Return number of records updated        PRINT 'Records updated: ' + CAST(@@ROWCOUNT AS VARCHAR(10));            END TRY    BEGIN CATCH        -- Error handling        PRINT 'Error occurred: ' + ERROR_MESSAGE();        THROW;    END CATCHEND
```
