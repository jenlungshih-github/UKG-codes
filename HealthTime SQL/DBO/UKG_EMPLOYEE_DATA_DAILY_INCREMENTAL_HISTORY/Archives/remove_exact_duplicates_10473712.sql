-- Remove exact-duplicates for EMPLID = 10473712 by payload (exclude snapshot_date fields)
-- Build payload_hash and remove rows that have identical payload_hash and NOTE, keeping the oldest snapshot_date
SET NOCOUNT ON;

DECLARE @EMPLID VARCHAR(11) = '10473712';
PRINT 'Computing payload hashes and identifying exact duplicates for ' + @EMPLID;

IF OBJECT_ID('tempdb..#to_remove') IS NOT NULL DROP TABLE #to_remove;

;
WITH
    src
    AS
    (
        SELECT *,
            -- compute payload hash across key data columns (exclude snapshot_date and snapshot_date_TXT)
            HASHBYTES('MD5',
            CONCAT(
                ISNULL(CAST(position_nbr AS varchar(50)),'|'),'|',
                ISNULL(DEPTID,'|'),'|', ISNULL(VC_CODE,'|'),'|', ISNULL(FDM_COMBO_CD,'|'),'|', ISNULL(COMBOCODE,'|'),'|',
                ISNULL(REPORTS_TO,'|'),'|', ISNULL(MANAGER_EMPLID,'|'),'|', ISNULL(NON_UKG_MANAGER_FLAG,'|'),'|',
                ISNULL(CAST(EMPL_RCD AS varchar(10)),'|'),'|', ISNULL(jobcode,'|'),'|', ISNULL(POSITION_DESCR,'|'),'|',
                ISNULL(hr_status,'|'),'|', ISNULL(CAST(FTE_SUM AS varchar(50)),'|'),'|', ISNULL(CAST(fte AS varchar(50)),'|'),'|',
                ISNULL(empl_Status,'|'),'|', ISNULL(JobGroup,'|'),'|', ISNULL(FundGroup,'|'),'|',
                ISNULL([Person Number],'|'),'|', ISNULL([First Name],'|'),'|', ISNULL([Last Name],'|'),'|',
                ISNULL([Middle Initial/Name],'|'),'|', ISNULL([Short Name],'|'),'|', ISNULL([Badge Number],'|'),'|',
                ISNULL(CONVERT(varchar(30),[Hire Date],121),'|'),'|', ISNULL(CONVERT(varchar(30),[Birth Date],121),'|'),'|',
                ISNULL(CONVERT(varchar(30),[Seniority Date],121),'|'),'|', ISNULL([Manager Flag],'|'),'|',
                ISNULL([Home Business Structure Level 1 - Organization],'|'),'|', ISNULL([Home Business Structure Level 2 - Entity],'|'),'|',
                ISNULL([Home Business Structure Level 3 - Service Line],'|'),'|', ISNULL([Home Business Structure Level 4 - Financial Unit],'|'),'|',
                ISNULL([Home Business Structure Level 5 - Fund Group],'|'),'|', ISNULL([Home/Primary Job],'|'),'|',
                ISNULL(CONVERT(varchar(30),termination_dt,121),'|'),'|', ISNULL(action,'|'),'|', ISNULL(CONVERT(varchar(30),action_dt,121),'|')
            )
        ) AS payload_hash
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        WHERE EMPLID = @EMPLID
    )
SELECT *
INTO #to_remove
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY EMPLID, payload_hash, NOTE ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
    FROM src
) t
WHERE rn > 1;

DECLARE @cnt INT = (SELECT COUNT(*)
FROM #to_remove);
PRINT 'Exact duplicate rows identified: ' + CAST(@cnt AS varchar(10));

IF @cnt > 0
BEGIN
    BEGIN TRANSACTION;
    ;
    WITH
        del
        AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY EMPLID, payload_hash, NOTE ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
            FROM (
            SELECT *,
                    HASHBYTES('MD5',
                    CONCAT(
                        ISNULL(CAST(position_nbr AS varchar(50)),'|'),'|', ISNULL(DEPTID,'|'),'|', ISNULL(VC_CODE,'|'),'|', ISNULL(FDM_COMBO_CD,'|'),'|', ISNULL(COMBOCODE,'|'),'|',
                        ISNULL(REPORTS_TO,'|'),'|', ISNULL(MANAGER_EMPLID,'|'),'|', ISNULL(NON_UKG_MANAGER_FLAG,'|'),'|',
                        ISNULL(CAST(EMPL_RCD AS varchar(10)),'|'),'|', ISNULL(jobcode,'|'),'|', ISNULL(POSITION_DESCR,'|'),'|',
                        ISNULL(hr_status,'|'),'|', ISNULL(CAST(FTE_SUM AS varchar(50)),'|'),'|', ISNULL(CAST(fte AS varchar(50)),'|'),'|',
                        ISNULL(empl_Status,'|'),'|', ISNULL(JobGroup,'|'),'|', ISNULL(FundGroup,'|'),'|',
                        ISNULL([Person Number],'|'),'|', ISNULL([First Name],'|'),'|', ISNULL([Last Name],'|'),'|',
                        ISNULL([Middle Initial/Name],'|'),'|', ISNULL([Short Name],'|'),'|', ISNULL([Badge Number],'|'),'|',
                        ISNULL(CONVERT(varchar(30),[Hire Date],121),'|'),'|', ISNULL(CONVERT(varchar(30),[Birth Date],121),'|'),'|',
                        ISNULL(CONVERT(varchar(30),[Seniority Date],121),'|'),'|', ISNULL([Manager Flag],'|'),'|',
                        ISNULL([Home Business Structure Level 1 - Organization],'|'),'|', ISNULL([Home Business Structure Level 2 - Entity],'|'),'|',
                        ISNULL([Home Business Structure Level 3 - Service Line],'|'),'|', ISNULL([Home Business Structure Level 4 - Financial Unit],'|'),'|',
                        ISNULL([Home Business Structure Level 5 - Fund Group],'|'),'|', ISNULL([Home/Primary Job],'|'),'|',
                        ISNULL(CONVERT(varchar(30),termination_dt,121),'|'),'|', ISNULL(action,'|'),'|', ISNULL(CONVERT(varchar(30),action_dt,121),'|')
                    )
                ) AS payload_hash
                FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
                WHERE EMPLID = @EMPLID
        ) s
        )
    DELETE FROM del WHERE rn > 1;
    DECLARE @deleted INT = @@ROWCOUNT;
    COMMIT TRANSACTION;
    PRINT 'Deleted exact duplicate rows: ' + CAST(@deleted AS varchar(10));

    PRINT 'Sample removed rows (from #to_remove):';
    SELECT TOP 200
        EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, payload_hash
    FROM #to_remove
    ORDER BY snapshot_date;
END
ELSE
BEGIN
    PRINT 'No exact duplicate rows found for ' + @EMPLID;
END

IF OBJECT_ID('tempdb..#to_remove') IS NOT NULL DROP TABLE #to_remove;
PRINT 'Done.';