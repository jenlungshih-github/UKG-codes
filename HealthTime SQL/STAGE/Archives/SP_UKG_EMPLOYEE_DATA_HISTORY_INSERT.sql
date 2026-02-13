USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]    Script Date: 10/8/2025 1:42:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
    Stored Procedure: [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
    Version: 2025-10-08

    Description:
    This stored procedure incrementally inserts records from [dbo].[UKG_EMPLOYEE_DATA] into [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].
    - For each record, a hash value is calculated using HASHBYTES('md5', ...) on key columns to detect changes.
    - Only records with a new hash value (i.e., not already present in the history table) are inserted.
    - The current date is recorded as snapshot_date for each inserted record.
    - This enables tracking of historical changes to employee data over time.

    Usage:
    EXEC [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
*/

CREATE or ALTER   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    SELECT *,
        HASHBYTES('md5', CONCAT(
            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
        )) AS hash_value,
        NULL AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE NOT EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
    WHERE hist.EMPLID = src.EMPLID
        AND hist.hash_value = HASHBYTES('md5', CONCAT(
                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt
            ))
    );
END
GO


