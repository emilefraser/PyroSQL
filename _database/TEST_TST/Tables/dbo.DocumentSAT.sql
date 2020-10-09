SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DocumentSAT](
	[DocumentVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[FolderFlag] [bit] NULL,
	[ChangeNumber] [int] NOT NULL,
	[DocumentFileName] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocumentRevision] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileExtension] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [tinyint] NOT NULL,
	[Title] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Document] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocumentSummary] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
