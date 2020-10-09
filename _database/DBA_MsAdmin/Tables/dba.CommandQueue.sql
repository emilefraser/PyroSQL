SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dba].[CommandQueue](
	[QueueID] [bigint] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Parameters] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QueueStartTime] [datetime2](7) NULL,
	[SessionID] [smallint] NULL,
	[RequestID] [int] NULL,
	[RequestStartTime] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
