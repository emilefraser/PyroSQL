IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'PASSWORD_SALT' AND ss.name = N'dss')
CREATE TYPE [dss].[PASSWORD_SALT] FROM [varbinary](256) NOT NULL
GO
