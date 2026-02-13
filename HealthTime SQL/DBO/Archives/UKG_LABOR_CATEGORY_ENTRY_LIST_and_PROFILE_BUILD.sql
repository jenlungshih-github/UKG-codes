USE [HealthTime]
GO

/****** Object:  StoredProcedure [dbo].[UKG_LABOR_CATEGORY_ENTRY_LIST_and_PROFILE_BUILD]    Script Date: 9/6/2025 4:03:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***************************************
* Created By: May Xu	
* Table: This SP creates table [dbo].[UKG_LABOR_CATEGORY_ENTRY_LIST] for labor_category_entry_list.csv
         [dbo].UKG_LABOR_CATEGORY_PROFILE for labor_category_profile.csv
* EXEC [dbo].UKG_LABOR_CATEGORY_ENTRY_LIST_and_PROFILE_BUILD	
* -- 05/06/2025 May Xu: Created
* -- 06/04/2025 Jim Shih: replace LIVED_LAST_FIRST_NAME with LIVED_FIRST_LAST_NAME, to avoid comma
* -- 6/12/2025 Jim Shih: rename UKG_LABOR_CATEGORY_ENTRY_LIST_BUILD to UKG_LABOR_CATEGORY_ENTRY_LIST_and_PROFILE_BUILD	 
* -- 7/3/2025  Jim SHih:  AND Substring([Labor Category List Name], 10,  3)	= 'All' 
* -- 7/9/2025  May Xu: Change the list name and Labor category Name based on JohnK's request.
* -- 7/14/2025 Jim Shih: Per JK, Please adjust the LC_Profile_Import extract to only include the _ALL for both Position and Job Code.
*-- migrate from hs-ssisp-v
*-- 07/28/2025 May Xu: add code to create a snapshot of UKG_LABOR_CATEGORY_ENTRY_LIST and drop any 30 days old snapshot
*-- 8/4/2025   Jim Shih: add DROP TABLE IF EXISTS
******************************************/

CREATE OR ALTER PROCEDURE [dbo].[UKG_LABOR_CATEGORY_ENTRY_LIST_and_PROFILE_BUILD]
AS  

BEGIN

    DROP TABLE IF EXISTS [dbo].UKG_LABOR_CATEGORY_ENTRY_LIST;

    SELECT *
    INTO  [dbo].UKG_LABOR_CATEGORY_ENTRY_LIST
    FROM (
                                    SELECT DISTINCT
                emplid +'_POS'+ '_All'  AS 'Labor Category List Name',
                LIVED_FIRST_LAST_NAME AS  [List Description],
                'Position_Record_Number' AS 'Labor Category Name',
                position_nbr + '_' + cast (empl_rcd as varchar) AS [Assigned Entry]
            FROM health_ods.[Health_ODS].[RPT].CURRENT_EMPL_DATA EMPL
            WHERE 1=1
                -- AND EMPL.JOB_INDICATOR = 'P'   
                AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
                OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
   )
                AND ((EMPL.hr_status = 'A' 	) -- active empl
                OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE()))	 --terminated empl today
   )
                AND PAY_FREQUENCY = 'B'
                AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )
            --exclude ARC MSP POPULATION

        UNION
            SELECT DISTINCT
                emplid +'_POS'+ '_Secondary'  AS 'Labor Category List Name',
                LIVED_FIRST_LAST_NAME AS  [List Description],
                'Position_Record_Number' AS 'Labor Category Name',
                position_nbr + '_' + cast (empl_rcd as varchar) AS [Assigned Entry]
            FROM health_ods.[Health_ODS].[RPT].current_empl_data empl
            where 1=1
                AND EMPL.JOB_INDICATOR = 'S'
                AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
                OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
   )
                AND ((EMPL.hr_status = 'A' 	) -- active empl
                OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE()))	 --terminated empl today
   )
                AND PAY_FREQUENCY = 'B'
                AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )
        --exclude ARC MSP POPULATION

        UNION
            SELECT DISTINCT
                emplid +'_JOB'+ '_All'  AS 'Labor Category List Name',
                LIVED_FIRST_LAST_NAME AS  [List Description],
                'HR Job Code' AS 'Labor Category Name',
                Jobcode AS [Assigned Entry]
            FROM health_ods.[Health_ODS].[RPT].current_empl_data empl
            where 1=1
                AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
                OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
   )
                AND ((EMPL.hr_status = 'A' 	) -- active empl
                OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE()))	 --terminated empl today
   )
                AND PAY_FREQUENCY = 'B'
                AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )
        --exclude ARC MSP POPULATION

        UNION
            SELECT DISTINCT
                emplid +'_JOB'+ '_Secondary'  AS 'Labor Category List Name',
                LIVED_FIRST_LAST_NAME AS  [List Description],
                'HR Job Code' AS 'Labor Category Name',
                Jobcode AS [Assigned Entry]
            FROM health_ods.[Health_ODS].[RPT].current_empl_data empl
            where 1=1
                AND EMPL.JOB_INDICATOR = 'S'
                AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
                OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
   )
                AND ((EMPL.hr_status = 'A' 	) -- active empl
                OR (EMPL.hr_status = 'I' and CONVERT(DATE, effdt) = CONVERT(DATE, GETDATE()))	 --terminated empl today
   )
                AND PAY_FREQUENCY = 'B'
                AND EMPL_TYPE = 'H' -- Biweekly and hourly empl only
                AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776')   )	--exclude ARC MSP POPULATION
 
 ) TEMP;

    DROP TABLE IF EXISTS [dbo].UKG_LABOR_CATEGORY_PROFILE;

    -- 7/14/2025 Jim Shih: Per JK, Please adjust the LC_Profile_Import extract to only include the _ALL for both Position and Job Code.
    SELECT *
    INTO  [dbo].UKG_LABOR_CATEGORY_PROFILE
    FROM (
                    SELECT DISTINCT
                Substring([Labor Category List Name], 1,  8 ) AS 'Labor Category Profile Name',
                [List Description] AS 'Profile Description',
                [Labor Category List Name] AS 'Labor Category List',
                [Labor Category Name]   AS 'Labor Category List Category'
            FROM [dbo].UKG_LABOR_CATEGORY_ENTRY_LIST
            WHERE [Labor Category Name] =	'HR Job Code'
                AND Substring([Labor Category List Name], 14,  3)	= 'All'

        UNION

            SELECT DISTINCT
                Substring([Labor Category List Name], 1,  8 ) AS 'Labor Category Profile Name',
                [List Description] AS 'Profile Description',
                [Labor Category List Name] AS 'Labor Category List',
                [Labor Category Name]   AS 'Labor Category List Category'
            FROM [dbo].UKG_LABOR_CATEGORY_ENTRY_LIST
            WHERE [Labor Category Name] =	'Position_Record_Number'
                AND Substring([Labor Category List Name], 14,  3)	= 'All'    

    ) TEMP;

    -- ***LOOP TO DROP ANY 30 DAY OLD and TODAY'S UKG_LABOR_CATEGORY_ENTRY_LIST_SNAPSHOT TABLES ***--
    DECLARE @SQL_DROP NVARCHAR(MAX)

    SELECT
        @SQL_DROP = COALESCE(@SQL_DROP + ' ;', '') +       
         'DROP TABLE IF EXISTS ' + QUOTENAME(S.NAME) + '.' + QUOTENAME(T.NAME)
    FROM SYS.SCHEMAS S
        INNER JOIN SYS.TABLES T ON T.SCHEMA_ID = S.SCHEMA_ID
    WHERE S.NAME IN ( 'BCK')
        AND T.NAME LIKE 'UKG_LABOR_CATEGORY_ENTRY_LIST_SNAPSHOT_%'
        AND ( CAST(SUBSTRING (T.NAME,40, 10 ) AS DATE) <  CAST(DATEADD(DAY,-30, GETDATE())   AS DATE) OR CAST(SUBSTRING (T.NAME,40, 10 ) AS DATE) =  CAST(GETDATE()       AS DATE) )

    --PRINT @SQL_DROP  
    EXEC(@SQL_DROP)

    --*** CREATE SNAPSHOT TABLE for UKG_LABOR_CATEGORY_ENTRY_LIST ***--

    DECLARE @SQL_CREATE NVARCHAR(MAX)
    DECLARE @SNAPSHOT_TABLENAME NVARCHAR(50);

    SET @SNAPSHOT_TABLENAME = 'UKG_LABOR_CATEGORY_ENTRY_LIST_SNAPSHOT_'+CAST(CAST(GETDATE() AS DATE) AS CHAR(10));

    SELECT
        @SQL_CREATE =  N'SELECT  * INTO BCK.[' +  @SNAPSHOT_TABLENAME + ']' + ' FROM dbo.UKG_LABOR_CATEGORY_ENTRY_LIST';

    --PRINT @SQL_CREATE;
    EXEC(@SQL_CREATE)

    -- ***LOOP TO DROP ANY 30 DAY OLD and TODAY'S UKG_LABOR_CATEGORY_PROFILE_SNAPSHOT TABLES ***--

    SET @SQL_DROP = NULL;
    -- Reset the variable for the second drop operation

    SELECT
        @SQL_DROP = COALESCE(@SQL_DROP + ' ;', '') +       
         'DROP TABLE IF EXISTS ' + QUOTENAME(S.NAME) + '.' + QUOTENAME(T.NAME)
    FROM SYS.SCHEMAS S
        INNER JOIN SYS.TABLES T ON T.SCHEMA_ID = S.SCHEMA_ID
    WHERE S.NAME IN ( 'BCK')
        AND T.NAME LIKE 'UKG_LABOR_CATEGORY_PROFILE_SNAPSHOT_%'
        AND ( CAST(SUBSTRING (T.NAME,37, 10 ) AS DATE) <  CAST(DATEADD(DAY,-30, GETDATE())   AS DATE) OR CAST(SUBSTRING (T.NAME,37, 10 ) AS DATE) =  CAST(GETDATE()       AS DATE) )

    --PRINT @SQL_DROP  
    EXEC(@SQL_DROP)

    --*** CREATE SNAPSHOT TABLE  ***--	

    SET @SNAPSHOT_TABLENAME = 'UKG_LABOR_CATEGORY_PROFILE_SNAPSHOT_'+CAST(CAST(GETDATE() AS DATE) AS CHAR(10));

    SELECT
        @SQL_CREATE = 
        N'DROP TABLE IF EXISTS bck.[' + @SNAPSHOT_TABLENAME + ']; ' +
        N'SELECT * INTO bck.[' + @SNAPSHOT_TABLENAME + '] FROM dbo.UKG_LABOR_CATEGORY_PROFILE';

    --PRINT @SQL_CREATE;
    EXEC(@SQL_CREATE)

END;

GO


