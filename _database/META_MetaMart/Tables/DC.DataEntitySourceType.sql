SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataEntitySourceType](
	[DESourceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DESourceTypeCode] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DESourceTypeDescription] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsFileDataSource] [bit] NULL
) ON [PRIMARY]

GO
