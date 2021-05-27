SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[provision_marker_dss]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataSync].[provision_marker_dss](
	[object_id] [int] NOT NULL,
	[owner_scope_local_id] [int] NOT NULL,
	[provision_scope_local_id] [int] NULL,
	[provision_timestamp] [bigint] NOT NULL,
	[provision_local_peer_key] [int] NOT NULL,
	[provision_scope_peer_key] [int] NULL,
	[provision_scope_peer_timestamp] [bigint] NULL,
	[provision_datetime] [datetime] NULL,
	[state] [int] NULL,
	[version] [timestamp] NOT NULL,
 CONSTRAINT [PK_DataSync.provision_marker_dss] PRIMARY KEY CLUSTERED 
(
	[owner_scope_local_id] ASC,
	[object_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
