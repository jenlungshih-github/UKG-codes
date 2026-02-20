/*
Procedure: [stage].[QA_SP_Blank_Acct_Code]
Created by: Jim Shih
Version: 1.0
EXEC [stage].[QA_SP_Blank_Acct_Code]
Purpose:
  Track rows where both FDM_COMBO_CD and COMBOCODE are NULL from dbo.UKG_EMPLOYEE_DATA.
  Writes delta rows into stage.QA_Blank_Acct_Code with NOTE:
    I = new key
    U = key exists but tracked attributes changed
    D = key no longer exists in source
*/
ALTER   PROCEDURE [stage].[QA_SP_Blank_Acct_Code]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('stage.QA_Blank_Acct_Code', 'U') IS NULL
        BEGIN
            SELECT TOP (0)
                src.[position_nbr],
                src.[EMPLID],
                src.[DEPTID],
                src.[VC_CODE],
                src.[REPORTS_TO],
                src.[MANAGER_EMPLID],
                src.[NON_UKG_MANAGER_FLAG],
                src.[jobcode],
                src.[POSITION_DESCR],
                src.[FTE_SUM],
                src.[empl_Status],
                src.[FundGroup],
                src.[Home Business Structure Level 1 - Organization],
                CONVERT(char(1), NULL) AS [NOTE],
                CONVERT(varbinary(32), NULL) AS [hash_value],
                CONVERT(datetime, NULL) AS [snapshot_DT]
            INTO stage.QA_Blank_Acct_Code
            FROM dbo.UKG_EMPLOYEE_DATA src;

            CREATE INDEX IX_QA_Blank_Acct_Code_Key_Snapshot
                ON stage.QA_Blank_Acct_Code ([position_nbr], [EMPLID], [snapshot_DT]);
        END;
        ELSE
        BEGIN
            IF COL_LENGTH('stage.QA_Blank_Acct_Code', 'NOTE') IS NULL
                ALTER TABLE stage.QA_Blank_Acct_Code ADD [NOTE] char(1) NULL;

            IF COL_LENGTH('stage.QA_Blank_Acct_Code', 'hash_value') IS NULL
                ALTER TABLE stage.QA_Blank_Acct_Code ADD [hash_value] varbinary(32) NULL;

            IF COL_LENGTH('stage.QA_Blank_Acct_Code', 'snapshot_DT') IS NULL
                ALTER TABLE stage.QA_Blank_Acct_Code ADD [snapshot_DT] datetime NULL;
        END;

        IF OBJECT_ID('tempdb..#SourceData') IS NOT NULL
            DROP TABLE #SourceData;

        IF OBJECT_ID('tempdb..#ActiveTarget') IS NOT NULL
            DROP TABLE #ActiveTarget;

        SELECT
            src.[position_nbr],
            src.[EMPLID],
            src.[DEPTID],
            src.[VC_CODE],
            src.[REPORTS_TO],
            src.[MANAGER_EMPLID],
            src.[NON_UKG_MANAGER_FLAG],
            src.[jobcode],
            src.[POSITION_DESCR],
            src.[FTE_SUM],
            src.[empl_Status],
            src.[FundGroup],
            src.[Home Business Structure Level 1 - Organization],
            HASHBYTES(
                'SHA2_256',
                CONCAT(
                    ISNULL(CONVERT(varchar(100), src.[position_nbr]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[EMPLID]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[DEPTID]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[VC_CODE]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[REPORTS_TO]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[MANAGER_EMPLID]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[NON_UKG_MANAGER_FLAG]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[jobcode]), ''),
                    '|', ISNULL(CONVERT(varchar(4000), src.[POSITION_DESCR]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[FTE_SUM]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[empl_Status]), ''),
                    '|', ISNULL(CONVERT(varchar(100), src.[FundGroup]), ''),
                    '|', ISNULL(CONVERT(varchar(4000), src.[Home Business Structure Level 1 - Organization]), '')
                )
            ) AS [hash_value]
        INTO #SourceData
        FROM dbo.UKG_EMPLOYEE_DATA src
        WHERE src.[FDM_COMBO_CD] IS NULL
          AND src.[COMBOCODE] IS NULL;

        SELECT
            t.[position_nbr],
            t.[EMPLID],
            t.[DEPTID],
            t.[VC_CODE],
            t.[REPORTS_TO],
            t.[MANAGER_EMPLID],
            t.[NON_UKG_MANAGER_FLAG],
            t.[jobcode],
            t.[POSITION_DESCR],
            t.[FTE_SUM],
            t.[empl_Status],
            t.[FundGroup],
            t.[Home Business Structure Level 1 - Organization],
            t.[hash_value]
        INTO #ActiveTarget
        FROM
        (
            SELECT
                q.*,
                ROW_NUMBER() OVER (
                    PARTITION BY q.[position_nbr], q.[EMPLID]
                    ORDER BY q.[snapshot_DT] DESC
                ) AS rn
            FROM stage.QA_Blank_Acct_Code q
        ) t
        WHERE t.rn = 1
          AND ISNULL(t.[NOTE], '') <> 'D';

        INSERT INTO stage.QA_Blank_Acct_Code
        (
            [position_nbr],
            [EMPLID],
            [DEPTID],
            [VC_CODE],
            [REPORTS_TO],
            [MANAGER_EMPLID],
            [NON_UKG_MANAGER_FLAG],
            [jobcode],
            [POSITION_DESCR],
            [FTE_SUM],
            [empl_Status],
            [FundGroup],
            [Home Business Structure Level 1 - Organization],
            [NOTE],
            [hash_value],
            [snapshot_DT]
        )
        SELECT
            s.[position_nbr],
            s.[EMPLID],
            s.[DEPTID],
            s.[VC_CODE],
            s.[REPORTS_TO],
            s.[MANAGER_EMPLID],
            s.[NON_UKG_MANAGER_FLAG],
            s.[jobcode],
            s.[POSITION_DESCR],
            s.[FTE_SUM],
            s.[empl_Status],
            s.[FundGroup],
            s.[Home Business Structure Level 1 - Organization],
            CASE
                WHEN a.[position_nbr] IS NULL THEN 'I'
                WHEN a.[hash_value] <> s.[hash_value] THEN 'U'
            END AS [NOTE],
            s.[hash_value],
            GETDATE() AS [snapshot_DT]
        FROM #SourceData s
        LEFT JOIN #ActiveTarget a
            ON a.[position_nbr] = s.[position_nbr]
           AND a.[EMPLID] = s.[EMPLID]
        WHERE a.[position_nbr] IS NULL
           OR a.[hash_value] <> s.[hash_value];

        INSERT INTO stage.QA_Blank_Acct_Code
        (
            [position_nbr],
            [EMPLID],
            [DEPTID],
            [VC_CODE],
            [REPORTS_TO],
            [MANAGER_EMPLID],
            [NON_UKG_MANAGER_FLAG],
            [jobcode],
            [POSITION_DESCR],
            [FTE_SUM],
            [empl_Status],
            [FundGroup],
            [Home Business Structure Level 1 - Organization],
            [NOTE],
            [hash_value],
            [snapshot_DT]
        )
        SELECT
            a.[position_nbr],
            a.[EMPLID],
            a.[DEPTID],
            a.[VC_CODE],
            a.[REPORTS_TO],
            a.[MANAGER_EMPLID],
            a.[NON_UKG_MANAGER_FLAG],
            a.[jobcode],
            a.[POSITION_DESCR],
            a.[FTE_SUM],
            a.[empl_Status],
            a.[FundGroup],
            a.[Home Business Structure Level 1 - Organization],
            'D' AS [NOTE],
            a.[hash_value],
            GETDATE() AS [snapshot_DT]
        FROM #ActiveTarget a
        LEFT JOIN #SourceData s
            ON s.[position_nbr] = a.[position_nbr]
           AND s.[EMPLID] = a.[EMPLID]
        WHERE s.[position_nbr] IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


