SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataEntityFileFormat](
	[DEFileFormatID] [int] IDENTITY(1,1) NOT NULL,
	[DEFileFormatCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DEFileFormatDescription] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
