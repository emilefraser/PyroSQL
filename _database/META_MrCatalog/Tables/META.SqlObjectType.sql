SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [META].[SqlObjectType](
	[SqlObjectTypeID] [int] IDENTITY(1,1) NOT NULL,
	[SqlObjectTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SqlObjectTypeDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
