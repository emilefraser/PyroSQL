SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[TSTVariables](
	[VariableId] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VariableName] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VariableValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
