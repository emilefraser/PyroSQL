SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Monitoring_Count]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Monitoring_Count](
	[Monitoring_CountId] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EnsambleName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CountType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountValue] [int] NULL,
	[LoadCycleID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]
END
GO
