IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'DISPLAY_NAME' AND ss.name = N'dss')
CREATE TYPE [dss].[DISPLAY_NAME] FROM [nvarchar](140) NOT NULL
GO
