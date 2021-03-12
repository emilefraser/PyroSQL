IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'LIVE_PUID' AND ss.name = N'dss')
CREATE TYPE [dss].[LIVE_PUID] FROM [bigint] NULL
GO
