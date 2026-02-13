# stage.SP_PRE_Check_Update_BASBEGIN_SET_NOCOUNT_ON;_DECLARE_@Today_VARCHAR

Source: docs/stored_procedures/all_procedures.sql

Link to SQL: sql/stage.SP_PRE_Check_Update_BASBEGIN_SET_NOCOUNT_ON;_DECLARE_@Today_VARCHAR.sql

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
/*=============================================================================Stored Procedure: SP_PRE_Check_Update_BDescription: Date-based auto-management for MONITOR_B - enables/disables based on scheduleVersion: 1.0Created: 2025-12-25Created by: Jim ShihLogic Explanation:0. Date-based Auto-Management for MONITOR_B:   - If today = Monitor_Start_DT AND Check_Disabled=1 → Set Check_Disabled=0 (auto-enable)   - If today = Monitor_End_DT → Set Check_Disabled=1 (auto-disable)1. Provides logging for all date-based status changes2. Updates Update_DT timestamp for audit trailPurpose: Pre-execution step to automatically manage MONITOR_B availability based on configured datesExecution: EXEC [stage].[SP_PRE_Check_Update_B];Version History:v1.0 (2025-12-25) - Initial creation with date-based auto-enable/disable logic for MONITOR_B=============================================================================*/CREATE   PROCEDURE [stage].[SP_PRE_Check_Update_B]ASBEGIN    SET NOCOUNT ON;    DECLARE @Today VARCHAR(10) = FORMAT(GETDATE(), 'yyyy-MM-dd');    DECLARE @UpdatesCount INT = 0;    BEGIN TRY        PRINT 'SP_PRE_Check_Update_B starting - Today: ' + @Today;                -- Check if today is Monitor_Start_DT and Check_Disabled is 1, then set to 0 (enable)        UPDATE [stage].[UKG_Accrual_Monitor_Schedule]           SET [Check_Disabled] = 0,               [Update_DT] = GETDATE()         WHERE [Monitor] = 'MONITOR_B'        AND [Monitor_Start_DT] = @Today        AND [Check_Disabled] = 1;                IF @@ROWCOUNT > 0        BEGIN        SET @UpdatesCount = @UpdatesCount + @@ROWCOUNT;        PRINT 'Date Logic: Check_Disabled set to 0 for MONITOR_B (today matches Monitor_Start_DT)';    END        -- Check if today is Monitor_End_DT, then set Check_Disabled to 1 (disable)        UPDATE [stage].[UKG_Accrual_Monitor_Schedule]           SET [Check_Disabled] = 1,               [Update_DT] = GETDATE()         WHERE [Monitor] = 'MONITOR_B'        AND [Monitor_End_DT] = @Today;                IF @@ROWCOUNT > 0        BEGIN        SET @UpdatesCount = @UpdatesCount + @@ROWCOUNT;        PRINT 'Date Logic: Check_Disabled set to 1 for MONITOR_B (today matches Monitor_End_DT)';    END        -- Summary        IF @UpdatesCount = 0            PRINT 'No date-based updates required for MONITOR_B today.';        ELSE            PRINT 'Date-based updates completed for MONITOR_B. Total updates: ' + CAST(@UpdatesCount AS VARCHAR(10));                    PRINT 'SP_PRE_Check_Update_B completed successfully.';            END TRY    BEGIN CATCH        -- Error handling        PRINT 'Error occurred in SP_PRE_Check_Update_B: ' + ERROR_MESSAGE();        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));        THROW;    END CATCHEND
```
