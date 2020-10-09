SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[TSTParameters](
	[ParameterId] [int] IDENTITY(1,1) NOT NULL,
	[TestSessionId] [int] NOT NULL,
	[ParameterName] [varchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Scope] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScopeValue] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
