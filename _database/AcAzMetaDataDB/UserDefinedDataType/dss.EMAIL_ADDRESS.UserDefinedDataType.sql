IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'EMAIL_ADDRESS' AND ss.name = N'dss')
CREATE TYPE [dss].[EMAIL_ADDRESS] FROM [nvarchar](256) NULL
GO
