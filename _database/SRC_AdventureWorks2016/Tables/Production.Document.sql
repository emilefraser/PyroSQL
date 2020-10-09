SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Document](
	[DocumentNode] [hierarchyid] NOT NULL,
	[DocumentLevel]  AS ([DocumentNode].[GetLevel]()),
	[Title] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Owner] [int] NOT NULL,
	[FolderFlag] [bit] NOT NULL,
	[FileName] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileExtension] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Revision] [nchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ChangeNumber] [int] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[DocumentSummary] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Document] [varbinary](max) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
