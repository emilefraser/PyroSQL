IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'RunStatus' AND ss.name = N'adf')
CREATE TYPE [adf].[RunStatus] FROM [varchar](100) NOT NULL
GO
