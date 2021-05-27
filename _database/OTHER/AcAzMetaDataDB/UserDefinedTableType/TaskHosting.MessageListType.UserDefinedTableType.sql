IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'MessageListType' AND ss.name = N'TaskHosting')
CREATE TYPE [TaskHosting].[MessageListType] AS TABLE(
	[MessageId] [uniqueidentifier] NOT NULL,
	[JobId] [uniqueidentifier] NOT NULL,
	[MessageType] [int] NOT NULL DEFAULT ((0)),
	[MessageData] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Version] [bigint] NOT NULL DEFAULT ((0)),
	[TracingId] [uniqueidentifier] NULL,
	[QueueId] [uniqueidentifier] NULL
)
GO
