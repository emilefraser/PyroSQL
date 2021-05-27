IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'MappingTable' AND ss.name = N'dbo')
CREATE TYPE [dbo].[MappingTable] AS TABLE(
	[src_id] [int] NOT NULL,
	[trg_id] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[src_id] ASC,
	[trg_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
