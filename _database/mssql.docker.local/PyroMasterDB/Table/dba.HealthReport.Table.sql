SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[HealthReport]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[HealthReport](
	[HealthReportID] [int] IDENTITY(1,1) NOT NULL,
	[DateStamp] [datetime] NOT NULL,
	[GeneratedHTML] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_HealthReport] PRIMARY KEY CLUSTERED 
(
	[HealthReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DF_HealthReport_datestamp]') AND type = 'D')
BEGIN
ALTER TABLE [dba].[HealthReport] ADD  CONSTRAINT [DF_HealthReport_datestamp]  DEFAULT (getdate()) FOR [DateStamp]
END
GO
