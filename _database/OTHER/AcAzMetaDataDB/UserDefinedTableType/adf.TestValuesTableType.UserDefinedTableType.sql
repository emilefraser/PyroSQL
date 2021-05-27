IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'TestValuesTableType' AND ss.name = N'adf')
CREATE TYPE [adf].[TestValuesTableType] AS TABLE(
	[TestValueID] [int] IDENTITY(1,1) NOT NULL,
	[DataType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestValue_Low] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestValue_High] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PRIMARY KEY CLUSTERED 
(
	[TestValueID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
