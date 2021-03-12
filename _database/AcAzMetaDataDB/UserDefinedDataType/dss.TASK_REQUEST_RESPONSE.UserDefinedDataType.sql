IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'TASK_REQUEST_RESPONSE' AND ss.name = N'dss')
CREATE TYPE [dss].[TASK_REQUEST_RESPONSE] FROM [varbinary](max) NOT NULL
GO
