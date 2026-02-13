-- Test script to verify To_Trace column rename
USE [HealthTime]
GO

-- Test the stored procedure and create a permanent table for verification
EXEC [stage].[SP_Create_Position_Trace_Analysis];

-- Copy results from temp table to permanent table for verification
IF OBJECT_ID('[stage].[Test_Position_Trace_Results]', 'U') IS NOT NULL 
    DROP TABLE [stage].[Test_Position_Trace_Results];

SELECT * 
INTO [stage].[Test_Position_Trace_Results]
FROM tempdb..#temp1;

-- Show sample results with To_Trace column
SELECT TOP 5 
    POSITION_NBR_To_Check,
    MANAGER_POSITION_NBR,
    POSN_LEVEL,
    To_Trace
FROM [stage].[Test_Position_Trace_Results]
WHERE To_Trace = 'yes'
ORDER BY POSITION_NBR_To_Check;

-- Clean up test table
DROP TABLE [stage].[Test_Position_Trace_Results];
