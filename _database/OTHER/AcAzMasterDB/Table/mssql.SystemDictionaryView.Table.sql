SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[SystemDictionaryView]') AND type in (N'U'))
BEGIN
CREATE TABLE [mssql].[SystemDictionaryView](
	[SystemViewId] [int] IDENTITY(1,1) NOT NULL,
	[TechnologyName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TechnologyVersion] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ViewName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ViewType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
