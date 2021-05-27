SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[BenchmarkTSQL]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[BenchmarkTSQL](
	[BenchmarkTSQLID] [int] IDENTITY(1,1) NOT NULL,
	[TSQLStatementGUID] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StepRowNumber] [int] NOT NULL,
	[StartBenchmark] [datetime2](7) NOT NULL,
	[EndBenchmark] [datetime2](7) NOT NULL,
	[StartStep] [datetime2](7) NOT NULL,
	[EndStep] [datetime2](7) NOT NULL,
	[StepDuration] [bigint] NOT NULL,
	[DurationAccuracy] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TsqlStatementBefore] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TsqlStatement] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TsqlStatementAfter] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClearCache] [bit] NOT NULL,
	[PrintStepInfo] [bit] NOT NULL,
	[OriginalLogin] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AdditionalInfo] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
