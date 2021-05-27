SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[FileStatsHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[FileStatsHistory](
	[FileStatsHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[FileStatsID] [int] NULL,
	[FileStatsDateStamp] [datetime] NOT NULL,
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBID] [int] NULL,
	[FileID] [int] NULL,
	[FileName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LogicalFileName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VLFCount] [int] NULL,
	[DriveLetter] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileMBSize] [bigint] NULL,
	[FileMaxSize] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileGrowth] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FileMBUsed] [bigint] NULL,
	[FileMBEmpty] [bigint] NULL,
	[FilePercentEmpty] [numeric](12, 2) NULL,
	[LargeLDF] [int] NULL,
	[FileGroup] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NumberReads] [bigint] NULL,
	[KBytesRead] [numeric](20, 2) NULL,
	[NumberWrites] [bigint] NULL,
	[KBytesWritten] [numeric](20, 2) NULL,
	[IoStallReadMS] [bigint] NULL,
	[IoStallWriteMS] [bigint] NULL,
	[Cum_IO_GB] [numeric](20, 2) NULL,
	[IO_Percent] [numeric](12, 2) NULL,
 CONSTRAINT [pk_FileStatsHistory] PRIMARY KEY CLUSTERED 
(
	[FileStatsHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[DF_FileStatsHistory_DateStamp]') AND type = 'D')
BEGIN
ALTER TABLE [monitor].[FileStatsHistory] ADD  CONSTRAINT [DF_FileStatsHistory_DateStamp]  DEFAULT (getdate()) FOR [FileStatsDateStamp]
END
GO
