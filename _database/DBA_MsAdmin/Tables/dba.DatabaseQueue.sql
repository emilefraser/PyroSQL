SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dba].[DatabaseQueue](
	[QueueID] [bigint] NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseOrder] [int] NULL,
	[DatabaseStartTime] [datetime2](7) NULL,
	[DatabaseEndTime] [datetime2](7) NULL,
	[SessionID] [smallint] NULL,
	[RequestID] [int] NULL,
	[RequestStartTime] [datetime2](7) NULL
) ON [PRIMARY]

GO
