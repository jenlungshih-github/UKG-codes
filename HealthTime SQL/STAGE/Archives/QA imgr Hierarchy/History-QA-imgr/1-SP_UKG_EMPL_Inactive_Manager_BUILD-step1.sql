
CREATE OR ALTER PROCEDURE [stage].[SP_UKG_EMPL_Inactive_Manager_BUILD-step1]
AS
-- Example execution:
-- EXEC [stage].[SP_UKG_EMPL_Inactive_Manager_BUILD-step1]
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsInserted INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        PRINT 'Starting build of [stage].[UKG_EMPL_Inactive_Manager] table...';
        
        -- Drop the table if it exists
        IF OBJECT_ID('[stage].[UKG_EMPL_Inactive_Manager]', 'U') IS NOT NULL
        BEGIN
        DROP TABLE [stage].[UKG_EMPL_Inactive_Manager];
        PRINT 'Existing table [stage].[UKG_EMPL_Inactive_Manager] dropped.';
    END;
        
        -- Create the lookup table using CTE for ranking
        WITH
        RankedJobs
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                --                empl.[Last Name] + ', ' + empl.[First Name] AS empl_NAME,
                --                J.HR_STATUS,
                J.EFFDT,
                J.EMPL_RCD,
                J.DEPTID,
                J.BUSINESS_UNIT,
                J.LOCATION,
                J.JOB_INDICATOR,
                J.FTE,
                J.UNION_CD,
                J.JOBCODE,
                ROW_NUMBER() OVER(
                        PARTITION BY J.EMPLID 
                        ORDER BY (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                                 J.FTE DESC 
                    ) AS ROW_NO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
                JOIN [dbo].[UKG_EMPLOYEE_DATA] empl -- [dbo].[UKG_EMPLOYEE_DATA] empl
                ON J.POSITION_NBR = empl.REPORTS_TO
            WHERE J.DML_IND <> 'D'
                AND J.HR_STATUS = 'I' -- [dbo].[UKG_EMPLOYEE_DATA] empl has reports-to BUT HR_STATUS = 'I'
                AND J.EFFDT = (
                        SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                    )
                AND J.EFFSEQ = (
                        SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                    )
        ),
        dd
        AS
        (
            SELECT
                POSITION_NBR as POSITION_NBR_To_Check,
                EMPLID as Inactive_EMPLID_To_Check,
                --        empl_NAME as UKG_EMPLOYEE_DATA,
                --        HR_STATUS,
                EFFDT,
                EMPL_RCD,
                DEPTID,
                BUSINESS_UNIT,
                LOCATION,
                JOB_INDICATOR,
                FTE,
                UNION_CD,
                JOBCODE,
                ROW_NO,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY EFFDT DESC) as position_rank
            FROM RankedJobs
            WHERE ROW_NO = 1
        )
    SELECT
        POSITION_NBR_To_Check,
        Inactive_EMPLID_To_Check,
        EFFDT,
        EMPL_RCD,
        DEPTID,
        BUSINESS_UNIT,
        LOCATION,
        JOB_INDICATOR,
        FTE,
        UNION_CD,
        JOBCODE,
        ROW_NO,
        GETDATE() AS UPDATED_DT
    INTO [stage].[UKG_EMPL_Inactive_Manager]
    -- [dbo].[UKG_EMPLOYEE_DATA] empl has reports-to BUT HR_STATUS = 'I'.  Create a table [stage].[UKG_EMPL_Inactive_Manager].
    FROM dd
    WHERE position_rank = 1;
        --        AND JOB_INDICATOR IN ('P', 'N');

        SET @RowsInserted = @@ROWCOUNT;
        
        PRINT 'Table [stage].[UKG_EMPL_Inactive_Manager] has been successfully created.';
        PRINT 'Records inserted: ' + CAST(@RowsInserted AS VARCHAR(10));
        
        COMMIT TRANSACTION;
        
        PRINT 'Build operation completed successfully.';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error occurred during table build: ' + @ErrorMessage;
        PRINT 'Transaction has been rolled back.';
        
        -- Re-throw the error
        THROW;
    END CATCH
END
GO