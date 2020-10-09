SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[FileStatsHistory](
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
	[IO_Percent] [numeric](12, 2) NULL
) ON [PRIMARY]

GO
