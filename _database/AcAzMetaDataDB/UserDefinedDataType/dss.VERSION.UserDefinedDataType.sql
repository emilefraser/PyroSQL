IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'VERSION' AND ss.name = N'dss')
CREATE TYPE [dss].[VERSION] FROM [nvarchar](40) NOT NULL
GO
