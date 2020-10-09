SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [META].[SqlObjectDefinition](
	[SqlObjectDefinitionID] [int] IDENTITY(1,1) NOT NULL,
	[SqlObjectDefinitionName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SqlObjectDefinitionDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SqlObjectDefinition] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SqlObjectID] [int] NOT NULL,
	[SqlStatementTypeID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
