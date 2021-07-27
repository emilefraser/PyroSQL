SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationTable](
	[ApplicationTableID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [smallint] NOT NULL,
	[TableID] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Title] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
