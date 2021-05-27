IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'SplitList' AND ss.name = N'dbo')
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[i] [int] NULL
)
GO
