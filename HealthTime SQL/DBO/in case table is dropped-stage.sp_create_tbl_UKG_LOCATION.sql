CREATE PROCEDURE [stage].[sp_create_tbl_UKG_LOCATION]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create table only if it doesn't exist
    IF OBJECT_ID('[dbo].[UKG_LOCATION]', 'U') IS NULL
    BEGIN
        -- Create the UKG_LOCATION table
        CREATE TABLE [dbo].[UKG_LOCATION](
            [Location Type] [varchar](20) NOT NULL,
            [Parent Path] [varchar](100) NULL,
            [Location Name] [varchar](50) NULL,
            [Full Name] [varchar](100) NULL,
            [Description] [varchar](500) NULL,
            [Effective Date] [varchar](10) NULL,
            [Expiration Date] [varchar](10) NULL,
            [Address] [varchar](1) NULL,
            [Cost Center] [varchar](1) NULL,
            [Direct Work Percent] [varchar](1) NULL,
            [Indirect Work Percent] [varchar](1) NULL,
            [Timezone] [varchar](1) NULL,
            [Transferable] [varchar](1) NULL,
            [External ID] [varchar](1) NULL
        ) ON [PRIMARY];

        -- Add default constraints
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Description];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('1900-01-01') FOR [Effective Date];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('3000-01-01') FOR [Expiration Date];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Address];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Cost Center];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Direct Work Percent];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Indirect Work Percent];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Timezone];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [Transferable];
        ALTER TABLE [dbo].[UKG_LOCATION] ADD DEFAULT ('') FOR [External ID];
        
        PRINT 'UKG_LOCATION table created successfully.';
    END
    ELSE
    BEGIN
        PRINT 'UKG_LOCATION table already exists. No action taken.';
    END
END
GO
