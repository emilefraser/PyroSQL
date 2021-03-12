SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Monitoring_Date]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Monitoring_Date](
	[Monitoring_DateId] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EnsambleName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DateType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateValue] [datetime2](7) NULL,
	[LoadCycleID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[EntityType] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
