/*
    Stored Procedure: [stage].[EMPL_DEPT_TRANSFER_build]
    Version: 2025-10-13 (Created by Jim Shih)

    Description:
    This stored procedure builds the [STAGE].[EMPL_DEPT_TRANSFER] table, tracking department transfer events for employees with detailed business logic and filters.
    Logic Details:
    - Identifies latest effective-dated job records for each employee and record number (EMPLID, EMPL_RCD).
    - Uses LEAD() window functions to compare current and next department, VC_CODE, HR_STATUS, jobcode, and other attributes.
    - Filters for department changes (DEPTID != NEXT_DEPTID), only when both current and next HR_STATUS are 'A' (active).
    - Includes only records for MED CENTER (VC_CODE = 'VCHSH') or PHSO (DEPTID between '002000' and '002999', excluding certain DEPTIDs).
    - Excludes specific DEPTID/JOBCODE combinations.
    - Excludes transfers to MED CENTER or PHSO.
    - Adds a snapshot_date column to record the date of the transfer event.
    - Adds a NOTE column (default '').
    - Uses MERGE to upsert into [STAGE].[EMPL_DEPT_TRANSFER] based on EMPLID and EFFDT.
    - Results are ordered by EMPLID, EMPL_RCD, EFFDT.

    Usage:
    EXEC [stage].[EMPL_DEPT_TRANSFER_build]
*/

CREATE OR ALTER PROCEDURE [stage].[EMPL_DEPT_TRANSFER_build]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @snapshot_date DATE = CAST(GETDATE() AS DATE);
    -- Build temp table with NOTE and snapshot_date
    WITH
        MaxEffdt
        AS
        (
            SELECT EMPLID,
                EMPL_RCD,
                MAX(EFFDT) AS EFFDT
            FROM health_ods.[health_ods].STABLE.PS_JOB
            WHERE DML_IND <> 'D'
                AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
        ),
        EMPL_DEPT_TRANSFERS
        AS
        (
            SELECT
                JOB.EMPLID,
                JOB.EMPL_RCD,
                DH.VC_CODE,
                JOB.HR_STATUS,
                JOB.DEPTID,
                JOB.EFFDT,
                JOB.ACTION,
                JOB.ACTION_DT,
                JOB.jobcode,
                JOB.POSITION_NBR,
                LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID,
                LEAD(JOB.EFFDT) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_EFFDT,
                LEAD(JOB.ACTION) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_ACTION,
                LEAD(DH.VC_CODE) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_CODE,
                LEAD(DH.VC_NAME) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_NAME,
                LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_HR_STATUS,
                LEAD(JOB.jobcode) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_jobcode,
                LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_POSITION_NBR
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB
                JOIN MaxEffdt MEP
                ON JOB.EMPLID = MEP.EMPLID
                    AND JOB.EMPL_RCD = MEP.EMPL_RCD
                    AND JOB.EFFDT = MEP.EFFDT
                JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH
                ON JOB.DEPTID = DH.DEPTID
            WHERE JOB.JOB_INDICATOR = 'P'
                AND JOB.DML_IND <> 'D'
                AND JOB.EFFSEQ = (
                SELECT MAX(EFFSEQ)
                FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
                WHERE JOB.EMPLID = JOB2.EMPLID
                    AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                    AND JOB.EFFDT = JOB2.EFFDT
                    AND JOB2.DML_IND <> 'D'
            )
        )
    SELECT *, @snapshot_date AS snapshot_date, '' AS NOTE
    INTO STAGE.EMPL_DEPT_TRANSFER_TEMP
    FROM EMPL_DEPT_TRANSFERS
    WHERE DEPTID != NEXT_DEPTID
        AND NEXT_DEPTID IS NOT NULL
        AND HR_STATUS = 'A'
        AND NEXT_HR_STATUS = 'A'
        AND (
            VC_CODE = 'VCHSH' -- MED CENTER
        OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280')) -- PHSO
        )
        AND NOT (DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776'))
        AND (
            NEXT_VC_CODE NOT IN ('VCHSH') -- not transferring to MED CENTER
        AND NOT (NEXT_DEPTID BETWEEN '002000' AND '002999' AND NEXT_DEPTID NOT IN ('002230','002231','002280')) -- not transferring to PHSO
        );

    -- Use MERGE to upsert into STAGE.EMPL_DEPT_TRANSFER based on EMPLID and EFFDT
    MERGE INTO STAGE.EMPL_DEPT_TRANSFER AS target
    USING STAGE.EMPL_DEPT_TRANSFER_TEMP AS source
    ON target.EMPLID = source.EMPLID AND target.EFFDT = source.EFFDT
    -- WHEN MATCHED THEN
    --     UPDATE SET
    --         target.EMPL_RCD = source.EMPL_RCD,
    --         target.VC_CODE = source.VC_CODE,
    --         target.HR_STATUS = source.HR_STATUS,
    --         target.DEPTID = source.DEPTID,
    --         target.ACTION = source.ACTION,
    --         target.ACTION_DT = source.ACTION_DT,
    --         target.jobcode = source.jobcode,
    --         target.POSITION_NBR = source.POSITION_NBR,
    --         target.NEXT_DEPTID = source.NEXT_DEPTID,
    --         target.NEXT_EFFDT = source.NEXT_EFFDT,
    --         target.NEXT_ACTION = source.NEXT_ACTION,
    --         target.NEXT_VC_CODE = source.NEXT_VC_CODE,
    --         target.NEXT_VC_NAME = source.NEXT_VC_NAME,
    --         target.NEXT_HR_STATUS = source.NEXT_HR_STATUS,
    --         target.NEXT_jobcode = source.NEXT_jobcode,
    --         target.NEXT_POSITION_NBR = source.NEXT_POSITION_NBR,
    --         target.snapshot_date = source.snapshot_date,
    --         target.NOTE = source.NOTE
    WHEN NOT MATCHED THEN
        INSERT (
            EMPLID, EMPL_RCD, VC_CODE, HR_STATUS, DEPTID, EFFDT, ACTION, ACTION_DT, jobcode, POSITION_NBR,
            NEXT_DEPTID, NEXT_EFFDT, NEXT_ACTION, NEXT_VC_CODE, NEXT_VC_NAME, NEXT_HR_STATUS, NEXT_jobcode, NEXT_POSITION_NBR, snapshot_date, NOTE
        )
        VALUES (
            source.EMPLID, source.EMPL_RCD, source.VC_CODE, source.HR_STATUS, source.DEPTID, source.EFFDT, source.ACTION, source.ACTION_DT, source.jobcode, source.POSITION_NBR,
            source.NEXT_DEPTID, source.NEXT_EFFDT, source.NEXT_ACTION, source.NEXT_VC_CODE, source.NEXT_VC_NAME, source.NEXT_HR_STATUS, source.NEXT_jobcode, source.NEXT_POSITION_NBR, source.snapshot_date, source.NOTE
        );
    DROP TABLE IF EXISTS STAGE.EMPL_DEPT_TRANSFER_TEMP;
END
GO


