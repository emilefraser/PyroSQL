IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'PASSWORD_HASH' AND ss.name = N'dss')
CREATE TYPE [dss].[PASSWORD_HASH] FROM [varbinary](256) NOT NULL
GO
