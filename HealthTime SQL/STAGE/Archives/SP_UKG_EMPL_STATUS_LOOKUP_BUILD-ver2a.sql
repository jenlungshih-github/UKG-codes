USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD]    Script Date: 7/14/2025 2:43:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/***************************************************************************************************************************************************************************************************************************************************************
--  Procedure Name: [dbo].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD]
--  Author:         Jim Shih
--  Version:        1.0
--  Date:           Current Date -- Please update with the original creation date
--  Description:    This stored procedure identifies the most recent employee status change for each employee from stable.ps_job.
--                  It uses the LAG window function to compare the current row's EMPL_STATUS with the previous row's status
--                  within each employee's history, ordered by effective date and sequence.
--                  It filters out deleted records and records with effective dates after the current date.
--  Parameters:     None
--  Example:        EXEC [dbo].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD];
--
--  Version History:
--  Date        Author               Description
--  6/10/2025 Jim Shih             Initial procedure creation.
*-- 7/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- changed to health_ods.[health_ods].[stable].ps_job
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

CREATE OR ALTER       PROCEDURE [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD]
AS
BEGIN
    -- Drop table if it exists
    IF OBJECT_ID('[stage].[UKG_EMPL_STATUS_LOOKUP]') IS NOT NULL
        DROP TABLE [stage].[UKG_EMPL_STATUS_LOOKUP];


WITH StatusChanges AS (
    SELECT
        emplid,
        EMPL_STATUS,
        EFFDT,
        EFFSEQ,
        EMPL_RCD,
        -- Determine the previous EMPL_STATUS. If it's the first record for an employee, previous_EMPL_STATUS will be the current EMPL_STATUS.
        -- Using EMPL_STATUS as default for LAG ensures previous_EMPL_STATUS is never NULL if a row exists.
        LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
        -- Rank records for each employee by effective date, oldest first.
        ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
    FROM health_ods.[health_ods].[stable].ps_job
    WHERE EFFDT <= GETDATE() -- Consider records up to the current date
    AND DML_IND <> 'D'       -- Exclude deleted records
    AND JOB_INDICATOR='P'    -- Primary job indicator
),
ActualChangePoints AS (
    -- Identify records where EMPL_STATUS actually changed compared to the previous chronological record.
    SELECT
        emplid,
        EMPL_STATUS,
        EFFDT,
        EFFSEQ,
        EMPL_RCD,
        previous_EMPL_STATUS, -- Keep for clarity if needed
        -- Rank these change points for each employee, latest change first.
        ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
    FROM StatusChanges
    WHERE EMPL_STATUS <> previous_EMPL_STATUS -- This condition defines a "change event"
),
OldestRecordsCTE AS (
    -- Dataset 2: Oldest record for each employee
    SELECT
        sc.emplid,
        sc.EMPL_STATUS,
        sc.EFFDT,
        sc.EFFSEQ,
        sc.EMPL_RCD,
        'Oldest Record' AS NOTE
    FROM StatusChanges sc
    WHERE sc.RowNum_Oldest = 1
),
LatestChangeRecordsCTE AS (
    -- Dataset 1: Latest change record for each employee
    SELECT
        acp.emplid,
        acp.EMPL_STATUS,
        acp.EFFDT,
        acp.EFFSEQ,
        acp.EMPL_RCD,
        'Latest Change' AS NOTE
    FROM ActualChangePoints acp
    WHERE acp.rn_of_change = 1
)
SELECT --top 1000
    UnionData.emplid,
    UnionData.EMPL_STATUS,
    UnionData.EFFDT,
    UnionData.EFFSEQ,
    UnionData.EMPL_RCD,
    UnionData.NOTE,
    GETDATE() AS LOAD_DTTM
INTO [stage].[UKG_EMPL_STATUS_LOOKUP]
FROM (
    SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, NOTE FROM LatestChangeRecordsCTE
    UNION ALL
    SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, NOTE FROM OldestRecordsCTE
	where emplid NOT IN
	(SELECT EMPLID FROM LatestChangeRecordsCTE)
) AS UnionData;


END;
GO


