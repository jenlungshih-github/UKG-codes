# stage.SP_UKG_EMPLOYEE_DATA_UPDATE_PROB_END_DTASBEGIN_SET_NOCOUNT_ON;_BEGIN_TRY_BEGIN_TRANSACTION;_--_Update_the_Custom_Date_1_UPDATE_dbo.UKG_EMPLOYEE_DATA_SET_Custom_Date_1_=_DATEADD

Source: docs/stored_procedures/all_procedures.sql

Link to SQL: sql/stage.SP_UKG_EMPLOYEE_DATA_UPDATE_PROB_END_DTASBEGIN_SET_NOCOUNT_ON;_BEGIN_TRY_BEGIN_TRANSACTION;_--_Update_the_Custom_Date_1_UPDATE_dbo.UKG_EMPLOYEE_DATA_SET_Custom_Date_1_=_DATEADD.sql

Detected features:
- uses_hashbytes: False
- uses_merge: False
- uses_select_into: False
- uses_temp_tables: False
- uses_dynamic_sql: False
- uses_transactions: True
- uses_drop_table_if_exists: False

---

```sql
Create     PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_UPDATE_PROB_END_DT]ASBEGIN    SET NOCOUNT ON;    BEGIN TRY        BEGIN TRANSACTION;        -- Update the [Custom Date 1]         UPDATE [dbo].[UKG_EMPLOYEE_DATA]        SET             [Custom Date 1] = DATEADD(DAY, 1, lookup.uc_prob_end_dt)--            [NOTE] = CONCAT('U, Custom Date 1 has retained prob_end_dt and was updated on ', CONVERT(VARCHAR, GETDATE(), 120))        FROM [dbo].[UKG_EMPLOYEE_DATA] empl_data        JOIN health_ods.[health_ods].stage.UKG_probation_dt_retain_lookup_V lookup        ON empl_data.position_nbr = lookup.position_nbr        WHERE empl_data.position_nbr IS NOT NULL        -- Commit the transaction        COMMIT TRANSACTION;    END TRY    BEGIN CATCH        -- Rollback the transaction in case of an error        IF @@TRANCOUNT > 0            ROLLBACK TRANSACTION;        -- Raise the error        THROW;    END CATCH;END;
```
