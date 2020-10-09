SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [META].[SqlObject](
	[SqlObjectID] [int] IDENTITY(1,1) NOT NULL,
	[SqlObjectName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SqlObjectDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SqlObjectType] [int] NOT NULL
) ON [PRIMARY]

GO
