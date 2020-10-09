SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ExecutionLogStorage](
	[LogEntryId] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceName] [nvarchar](38) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ReportID] [uniqueidentifier] NULL,
	[UserName] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExecutionId] [nvarchar](64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestType] [tinyint] NOT NULL,
	[Format] [nvarchar](26) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Parameters] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReportAction] [tinyint] NULL,
	[TimeStart] [datetime] NOT NULL,
	[TimeEnd] [datetime] NOT NULL,
	[TimeDataRetrieval] [int] NOT NULL,
	[TimeProcessing] [int] NOT NULL,
	[TimeRendering] [int] NOT NULL,
	[Source] [tinyint] NOT NULL,
	[Status] [nvarchar](40) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ByteCount] [bigint] NOT NULL,
	[RowCount] [bigint] NOT NULL,
	[AdditionalInfo] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
