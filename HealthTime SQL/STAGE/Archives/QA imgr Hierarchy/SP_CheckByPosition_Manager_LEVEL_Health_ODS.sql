USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_CheckByPosition_Health_ODS]    Script Date: 8/29/2025 12:20:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE Or ALTER   PROCEDURE [stage].[SP_CheckByPosition_Manager_LEVEL_Health_ODS]
    @POSITION_NBR NVARCHAR(10)
AS
-- Example usage:
-- EXEC [stage].[SP_CheckByPosition_Manager_LEVEL_Health_ODS] @POSITION_NBR = '40734409';
BEGIN
    SET NOCOUNT ON;

    -- Create a table variable to store messages
    DECLARE @messages TABLE (
        message_id INT IDENTITY(1,1),
        message_text VARCHAR(MAX)
    );


--------------------------------------
-- Message template
    -- 1. Investigate [POSITION_REPORTS_TO] is not null but MANAGER_EMPLID is NULL
	-- Insert message
    INSERT INTO @messages
        (message_text)
    VALUES
        ('1. Investigate [POSITION_REPORTS_TO] is not null but MANAGER_EMPLID is NULL');

    SELECT
        message_id,
        message_text
    FROM @messages
    where message_id=1;

   --Insert Script below
    SELECT DISTINCT top 1
        imgr.[Inactive_EMPLID],
		imgr.POSITION_NBR as Inactive_EMPLID_POSITION_NBR,
		empl.MANAGER_EMPLID,
        empl.MANAGER_NAME,
		empl.[POSITION_REPORTS_TO]
    FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] empl
        INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] imgr
        ON empl.emplid = imgr.[Inactive_EMPLID]
		and empl.POSITION_NBR=imgr.POSITION_NBR
where empl.MANAGER_EMPLID is NULL
;
    -- 2. Check POSN_STATUS, deptid in STABLE.PS_POSITION_DATA 
    INSERT INTO @messages
        (message_text)
    VALUES
        ('2. Checking POSN_STATUS (should be A) and deptid in STABLE.PS_POSITION_DATA');

    SELECT
        message_id,
        message_text
    FROM @messages
    where message_id=2;

    SELECT
        POSN_STATUS,
        deptid,
        POSITION_NBR,
        EFFDT,
        DML_IND
    FROM health_ods.stable.PS_POSITION_DATA
    WHERE POSITION_NBR = @POSITION_NBR
        AND dml_ind <> 'D'
    ORDER BY effdt DESC;

    -- Return collected messages at the end
    SELECT
        message_id,
        message_text
    FROM @messages
    ORDER BY message_id;

END;
GO


