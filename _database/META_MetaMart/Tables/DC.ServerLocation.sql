SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[ServerLocation](
	[ServerLocationID] [int] IDENTITY(1,1) NOT NULL,
	[ServerLocationCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServerLocationName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsCloudLocation] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
