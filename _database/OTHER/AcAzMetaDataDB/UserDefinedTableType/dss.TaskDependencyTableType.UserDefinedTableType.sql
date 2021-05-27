IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'TaskDependencyTableType' AND ss.name = N'dss')
CREATE TYPE [dss].[TaskDependencyTableType] AS TABLE(
	[nexttaskid] [uniqueidentifier] NULL,
	[prevtaskid] [uniqueidentifier] NULL
)
GO
