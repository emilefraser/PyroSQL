SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DatabaseSettings]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[DatabaseSettings](
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaTracking] [bit] NULL,
	[LogFileAlerts] [bit] NULL,
	[LongQueryAlerts] [bit] NULL,
	[Reindex] [bit] NULL,
 CONSTRAINT [pk_DatabaseSettings] PRIMARY KEY CLUSTERED 
(
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
