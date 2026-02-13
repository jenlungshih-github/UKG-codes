USE [Health_ODS]
GO

/****** Object:  View [stage].[UKG_probation_dt_retain_lookup_V]    Script Date: 2/3/2026 3:09:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [stage].[UKG_probation_dt_retain_lookup_V] 
AS
-- ==========================================================================================
-- View Name: stage.UKG_probation_dt_retain_lookup_V
-- Description: This view retrieves the top 1 record for each position_nbr based on the maximum effdt, empl_rcd, and effseq.
--              It excludes rows with NULL or blank position_nbr values.
-- Created By: Jim Shih
-- Created On: 2026-01-28
-- Version: 1.0
-- ==========================================================================================
-- Technical Details:
-- - This view uses a CTE (Common Table Expression) to rank records for each position_nbr.
-- - The ROW_NUMBER() function is used to rank records based on effdt, empl_rcd, and effseq in descending order.
-- - The OUTER APPLY retrieves the top 1 record for each position_nbr based on the maximum effdt, empl_rcd, and effseq.
-- - The view excludes rows with NULL or blank position_nbr values.
-- - The final result includes only the top 1 record for each position_nbr.

-- Version History:
-- Version 1.0 (2026-01-28): Initial creation of the view by Jim Shih.
-- ==========================================================================================
WITH RankedPositions AS (
    SELECT
        D.position_nbr,
        U1.uc_prob_end_dt,
        U1.uc_probation_code,
        D.emplid,
        D.empl_rcd,
        D.effdt,
        D.effseq,
        ROW_NUMBER() OVER (
            PARTITION BY D.position_nbr
            ORDER BY U1.effdt DESC, U1.empl_rcd DESC, U1.effseq DESC
        ) AS RowNum
    FROM stable.ps_job D
    OUTER APPLY (
        SELECT TOP 1
            UU1.uc_prob_end_dt,
            UU1.uc_probation_code,
            UU1.effdt,
            UU1.empl_rcd,
            UU1.effseq
        FROM stable.ps_uc_empl_prb_dtl UU1
        WHERE UU1.emplid = D.emplid
            AND UU1.empl_rcd = D.empl_rcd
            AND UU1.dml_ind <> 'D'
            AND UU1.effdt <= D.effdt
        ORDER BY UU1.effdt DESC, UU1.empl_rcd DESC, UU1.effseq DESC
    ) AS U1
    WHERE U1.uc_prob_end_dt IS NOT NULL
        AND U1.uc_probation_code = 'P'
        AND D.position_nbr IS NOT NULL
        AND LTRIM(RTRIM(D.position_nbr)) <> ''
)
SELECT *
FROM RankedPositions
WHERE RowNum = 1
--ORDER BY position_nbr;

GO


