SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadTableAuditTrailConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TargetDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Active] [bit] NOT NULL
) ON [PRIMARY]

GO
