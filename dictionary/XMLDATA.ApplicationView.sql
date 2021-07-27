SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationView](
	[ApplicationViewID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [smallint] NOT NULL,
	[RotoID] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableCodes] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Dll] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
