/*
    Stored Procedure: [stage].[SP_EMP_DEPT_TRANSFER_BUILD]
    Version: 2025-10-09 (Created by Jim Shih)

    Description:
    This stored procedure builds the [STAGE].[EMPL_DEPT_TRANSFER] table, which tracks department transfer events for employees.
    Logic Details:
    - Identifies the latest effective-dated job records for each employee and record number (EMPLID, EMPL_RCD).
    - Uses LEAD() window functions to compare current and next department, VC_CODE, HR_STATUS, and other job attributes.
    - Filters for department changes (DEPTID != NEXT_DEPTID), only when both current and next HR_STATUS are 'A' (active).
    - Includes only records where VC_CODE or NEXT_VC_CODE is in ('VCHSH', 'VCHSS').
    - Results are ordered by EMPLID, EMPL_RCD, EFFDT.
    - The output is first written to a temp table, then renamed to [STAGE].[EMPL_DEPT_TRANSFER].

    Usage:
    EXEC [stage].[SP_EMP_DEPT_TRANSFER_BUILD]
*/

CREATE OR ALTER PROCEDURE [stage].[SP_EMP_DEPT_TRANSFER_BUILD]
AS
BEGIN
    SET NOCOUNT ON;
    -- Find latest effective-dated job records for each employee
    WITH
        MaxEffdt
        AS
        (
            SELECT EMPLID,
                EMPL_RCD,
                MAX(EFFDT) AS EFFDT
            FROM health_ods.[health_ods].STABLE.PS_JOB
            WHERE DML_IND <> 'D'
                AND EFFDT < GETDATE()
            GROUP BY EMPLID, EMPL_RCD, YEAR(EFFDT), MONTH(EFFDT)
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
                JOB.POSITION_NBR,
                LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID,
                LEAD(JOB.EFFDT) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_EFFDT,
                LEAD(JOB.ACTION) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_ACTION,
                LEAD(DH.VC_CODE) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_CODE,
                LEAD(DH.VC_NAME) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_NAME,
                LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_HR_STATUS,
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
    SELECT *
    INTO STAGE.EMPL_DEPT_TRANSFER_TEMP
    FROM EMPL_DEPT_TRANSFERS
    WHERE DEPTID != NEXT_DEPTID
        AND NEXT_DEPTID IS NOT NULL
        AND HR_STATUS = 'A'
        AND NEXT_HR_STATUS = 'A'
        AND (VC_CODE IN ('VCHSH', 'VCHSS') OR NEXT_VC_CODE IN ('VCHSH', 'VCHSS'))
    ORDER BY EMPLID, EMPL_RCD, EFFDT;

    DROP TABLE IF EXISTS STAGE.EMPL_DEPT_TRANSFER;
    EXEC SP_RENAME 'STAGE.EMPL_DEPT_TRANSFER_TEMP', 'EMPL_DEPT_TRANSFER';
END
GO


