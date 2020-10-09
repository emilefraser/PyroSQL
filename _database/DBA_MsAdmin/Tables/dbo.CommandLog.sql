SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CommandLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ObjectType] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndexName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IndexType] [tinyint] NULL,
	[StatisticsName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PartitionNumber] [int] NULL,
	[ExtendedInfo] [xml] NULL,
	[Command] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CommandType] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
