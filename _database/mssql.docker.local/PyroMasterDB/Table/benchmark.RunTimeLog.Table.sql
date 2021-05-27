SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[RunTimeLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[RunTimeLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Spid] [int] NULL,
	[TestClass] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestIterationName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestRunNumber] [int] NULL,
	[SourceObject] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceRows] [int] NULL,
	[TargetObject] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetRows] [int] NULL,
	[TestDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__RunTimeLo__Start__06C3AEAD]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[RunTimeLog] ADD  DEFAULT (sysutcdatetime()) FOR [StartDate]
END
GO
