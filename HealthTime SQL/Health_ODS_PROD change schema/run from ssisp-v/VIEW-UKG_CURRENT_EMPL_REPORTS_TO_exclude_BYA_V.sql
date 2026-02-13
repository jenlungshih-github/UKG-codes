USE [Health_ODS]
GO

/****** Object:  View [stage].[UKG_CURRENT_EMPL_REPORTS_TO_exclude_BYA_V]    Script Date: 2/3/2026 3:06:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [stage].[UKG_CURRENT_EMPL_REPORTS_TO_exclude_BYA_V]
AS
    -- ==========================================================================================
    -- View: stage.UKG_CURRENT_EMPL_REPORTS_TO_exclude_BYA_V
    -- Description: Returns CURRENT_EMPL_REPORTS_TO rows but excludes employees whose primary PS_JOB
    --              record has SAL_ADMIN_PLAN = 'BYA'. This prevents BYA assignments from appearing in
    --              downstream manager/reporting logic.
    -- Created By: Jim Shih
    -- Created On: 2026-01-28
    -- Version: 1.0
    -- Technical Details:
    -- - Purpose: Exclude employees who belong to BYA payroll plan from CURRENT_EMPL_REPORTS_TO
    --            so they are not considered in non-UKG manager processing and related joins.
    -- - Logic: Uses NOT EXISTS against stable.PS_JOB filtering primary job (JOB_INDICATOR='P'),
    --          active rows (DML_IND <> 'D'), and SAL_ADMIN_PLAN = 'BYA'.
    -- - Performance: Ensure stable.PS_JOB has an index on (EMPLID, JOB_INDICATOR, SAL_ADMIN_PLAN, DML_IND)
    --                and RPT.CURRENT_EMPL_REPORTS_TO has an index on EMPLID for optimal performance.
    -- - Version History:
    --   1.0 (2026-01-28) Jim Shih - Initial creation
    -- ==========================================================================================
    SELECT
        T.*
    FROM [RPT].[CURRENT_EMPL_REPORTS_TO] T
    WHERE T.EMPLID IS NOT NULL
        AND NOT EXISTS (
    SELECT 1
        FROM [stable].PS_JOB J
        WHERE J.EMPLID = T.EMPLID
            AND J.JOB_INDICATOR = 'P'
            AND J.DML_IND <> 'D'
            AND ISNULL(J.SAL_ADMIN_PLAN,'') = 'BYA'
);
GO


