IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'SplitStringType' AND ss.name = N'dbo')
CREATE TYPE [dbo].[SplitStringType] AS TABLE(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StringValue] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
