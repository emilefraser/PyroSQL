SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Monitoring_LoadStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Monitoring_LoadStatus](
	[Monitoring_LoadStatusId] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadProcedureName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReturnValue] [smallint] NULL,
	[ReturnMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadCycleID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
