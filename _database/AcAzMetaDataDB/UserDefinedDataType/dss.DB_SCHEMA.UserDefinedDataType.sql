IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'DB_SCHEMA' AND ss.name = N'dss')
CREATE TYPE [dss].[DB_SCHEMA] FROM [nvarchar](max) NULL
GO
