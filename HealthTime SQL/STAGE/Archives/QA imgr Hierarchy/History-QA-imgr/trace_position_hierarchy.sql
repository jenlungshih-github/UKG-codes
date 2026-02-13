-- Position Hierarchy Trace for 40692970
-- This script traces the complete management hierarchy for position 40692970

USE [HealthTime]
GO

PRINT 'POSITION HIERARCHY TRACE FOR 40692970'
PRINT '====================================='
PRINT ''

-- Level 1: Direct trace for position 40692970
PRINT 'LEVEL 1 - Position 40692970:'
PRINT '-----------------------------'
SELECT
    'Level ' + CAST([LEVEL UP] AS VARCHAR(2)) as Level,
    [Inactive_EMPLID_POSITION_NBR] as Position,
    [POSITION_REPORTS_TO] as Reports_To,
    [POSN_STATUS] as Position_Status,
    [PS_JOB_EMPLID] as Manager_EMPLID,
    [PS_JOB_HR_STATUS] as Manager_HR_Status,
    [NOTE] as Note
FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [Inactive_EMPLID_POSITION_NBR] = '40692970'
ORDER BY [LEVEL UP];

PRINT ''
PRINT 'MANAGER HIERARCHY CHAIN:'
PRINT '========================'

-- Trace Manager 10405830 (from Level 1)
PRINT ''
PRINT 'Manager 10405830 (from Level 1) hierarchy:'
PRINT '-------------------------------------------'
SELECT
    'Level ' + CAST([LEVEL UP] AS VARCHAR(2)) as Level,
    [Inactive_EMPLID] as Manager_EMPLID,
    [POSITION_REPORTS_TO] as Reports_To_Position,
    [POSN_STATUS] as Position_Status,
    [PS_JOB_EMPLID] as Their_Manager_EMPLID,
    [PS_JOB_HR_STATUS] as Their_Manager_HR_Status,
    [NOTE] as Note
FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [Inactive_EMPLID] = '10405830'
ORDER BY [LEVEL UP];

-- Trace Manager 10797799 (from Level 3 of 10405830)
PRINT ''
PRINT 'Manager 10797799 (from Level 3) hierarchy:'
PRINT '-------------------------------------------'
SELECT
    'Level ' + CAST([LEVEL UP] AS VARCHAR(2)) as Level,
    [Inactive_EMPLID] as Manager_EMPLID,
    [POSITION_REPORTS_TO] as Reports_To_Position,
    [POSN_STATUS] as Position_Status,
    [PS_JOB_EMPLID] as Their_Manager_EMPLID,
    [PS_JOB_HR_STATUS] as Their_Manager_HR_Status,
    [NOTE] as Note
FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [Inactive_EMPLID] = '10797799'
ORDER BY [LEVEL UP];

PRINT ''
PRINT 'COMPLETE HIERARCHY SUMMARY:'
PRINT '==========================='
PRINT ''
PRINT 'Position 40692970 Hierarchy Chain:'
PRINT '1. Position 40692970 (Status: R) -> Reports to Position 40734409'
PRINT '   Manager: EMPLID 10405830 (HR Status: I - Inactive)'
PRINT ''
PRINT '2. Manager 10405830 -> Reports to Position 40734409 (same position - top of branch)'
PRINT '   BUT at Level 3, Manager 10405830 -> Reports to Position 41156004'
PRINT '   Their Manager: EMPLID 10797799 (HR Status: A - Active)'
PRINT ''
PRINT '3. Manager 10797799 hierarchy (if exists):'

-- Check if 10797799 has any higher level records
DECLARE @Count INT;
SELECT @Count = COUNT(*)
FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [Inactive_EMPLID] = '10797799';

IF @Count = 0
    PRINT '   EMPLID 10797799 - TOP OF HIERARCHY (no higher level records found)'
ELSE
    PRINT '   EMPLID 10797799 has higher level records - see above query results'

PRINT ''
PRINT 'ANALYSIS COMPLETE'
PRINT '================='
