IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'DataEntity' AND ss.name = N'dbo')
CREATE TYPE [dbo].[DataEntity] AS TABLE(
	[Value] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
