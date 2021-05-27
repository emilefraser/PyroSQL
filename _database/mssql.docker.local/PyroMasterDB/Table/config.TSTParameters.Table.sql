SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[TSTParameters]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[TSTParameters](
	[ParameterId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[ParameterName] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Scope] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScopeValue] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_TSTParameters] PRIMARY KEY CLUSTERED 
(
	[ParameterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_TSTParameters_TestSessionId_ParameterName_Scope_ScopeValue] UNIQUE NONCLUSTERED 
(
	[TestSessionId] ASC,
	[ParameterName] ASC,
	[Scope] ASC,
	[ScopeValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTParameters_ParameterName]') AND parent_object_id = OBJECT_ID(N'[config].[TSTParameters]'))
ALTER TABLE [config].[TSTParameters]  WITH CHECK ADD  CONSTRAINT [CK_TSTParameters_ParameterName] CHECK  (([ParameterName]='UseTSTRollback'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTParameters_ParameterName]') AND parent_object_id = OBJECT_ID(N'[config].[TSTParameters]'))
ALTER TABLE [config].[TSTParameters] CHECK CONSTRAINT [CK_TSTParameters_ParameterName]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTParameters_Scope]') AND parent_object_id = OBJECT_ID(N'[config].[TSTParameters]'))
ALTER TABLE [config].[TSTParameters]  WITH CHECK ADD  CONSTRAINT [CK_TSTParameters_Scope] CHECK  (([Scope]='All' OR [Scope]='Suite' OR [Scope]='Test'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[config].[CK_TSTParameters_Scope]') AND parent_object_id = OBJECT_ID(N'[config].[TSTParameters]'))
ALTER TABLE [config].[TSTParameters] CHECK CONSTRAINT [CK_TSTParameters_Scope]
GO
