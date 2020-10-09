SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationViewKey](
	[ApplicationViewKeyID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationViewID] [int] NULL,
	[ApplicationID] [smallint] NULL,
	[Title] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Fields] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
