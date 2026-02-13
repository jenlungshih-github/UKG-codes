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
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Description]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('1900-01-01') FOR [Effective Date]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('3000-01-01') FOR [Expiration Date]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Address]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Cost Center]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Direct Work Percent]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Indirect Work Percent]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Timezone]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [Transferable]
GO

ALTER TABLE [dbo].[UKG_LOCATION] ADD  DEFAULT ('') FOR [External ID]
GO