IF NOT EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'TestClass_dss_BulkType_f0bc5ede-b67c-444d-a637-8db2ce41f2a3' AND ss.name = N'DataSync')
CREATE TYPE [DataSync].[TestClass_dss_BulkType_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS TABLE(
	[TestClassId] [smallint] NOT NULL,
	[TestClassCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestClassName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[sync_update_peer_timestamp] [bigint] NULL,
	[sync_update_peer_key] [int] NULL,
	[sync_create_peer_timestamp] [bigint] NULL,
	[sync_create_peer_key] [int] NULL,
	PRIMARY KEY CLUSTERED 
(
	[TestClassId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
