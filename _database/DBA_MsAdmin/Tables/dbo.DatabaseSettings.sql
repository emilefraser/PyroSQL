SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DatabaseSettings](
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaTracking] [bit] NOT NULL,
	[LogFileAlerts] [bit] NOT NULL,
	[LongQueryAlerts] [bit] NOT NULL,
	[Reindex] [bit] NOT NULL,
	[HealthReport] [bit] NOT NULL
) ON [PRIMARY]

GO
