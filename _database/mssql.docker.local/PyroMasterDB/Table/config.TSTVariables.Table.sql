SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[TSTVariables]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[TSTVariables](
	[VariableId] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VariableName] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VariableValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_TSTVariables] PRIMARY KEY CLUSTERED 
(
	[VariableId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_TSTVariables_DatabaseName_VariableName] UNIQUE NONCLUSTERED 
(
	[DatabaseName] ASC,
	[VariableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTVariables_VariableName]') AND parent_object_id = OBJECT_ID(N'[config].[TSTVariables]'))
ALTER TABLE [config].[TSTVariables]  WITH CHECK ADD  CONSTRAINT [CK_TSTVariables_VariableName] CHECK  (([VariableName]='SqlTestPrefix'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTVariables_VariableName]') AND parent_object_id = OBJECT_ID(N'[config].[TSTVariables]'))
ALTER TABLE [config].[TSTVariables] CHECK CONSTRAINT [CK_TSTVariables_VariableName]
GO
