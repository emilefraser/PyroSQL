SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[ManyToManyLink](
	[ManyToManyLinkID] [int] IDENTITY(1,1) NOT NULL,
	[LinkName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ManyToManyDataEntityID] [int] NOT NULL,
	[SourceDataEnitityID] [int] NULL,
	[HubID] [int] NULL
) ON [PRIMARY]

GO
