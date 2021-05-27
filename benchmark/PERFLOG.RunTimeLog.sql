SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [PERFLOG].[RunTimeLog](
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
	[EndDate] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
