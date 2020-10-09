SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [META].[SqlStatementType](
	[SqlStatementTypeID] [int] IDENTITY(1,1) NOT NULL,
	[SqlStatementTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SqlStatementTypeDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
