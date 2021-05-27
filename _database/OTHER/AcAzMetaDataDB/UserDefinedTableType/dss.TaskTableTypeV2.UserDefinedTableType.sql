IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'TaskTableTypeV2' AND ss.name = N'dss')
CREATE TYPE [dss].[TaskTableTypeV2] AS TABLE(
	[id] [uniqueidentifier] NULL,
	[actionid] [uniqueidentifier] NULL,
	[agentid] [uniqueidentifier] NULL,
	[request] [dss].[TASK_REQUEST_RESPONSE] NULL,
	[dependency_count] [int] NULL,
	[priority] [int] NULL DEFAULT ((100)),
	[type] [int] NULL,
	[version] [bigint] NULL DEFAULT ((0))
)
GO
