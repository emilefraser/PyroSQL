IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ParamTable' AND ss.name = N'dbo')
CREATE TYPE [dbo].[ParamTable] AS TABLE(
	[param_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[param_value] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
