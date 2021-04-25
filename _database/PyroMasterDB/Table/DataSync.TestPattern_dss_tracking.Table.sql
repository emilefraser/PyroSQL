SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[TestPattern_dss_tracking]') AND type in (N'U'))
BEGIN
CREATE TABLE [DataSync].[TestPattern_dss_tracking](
	[PatternID] [int] NOT NULL,
	[update_scope_local_id] [int] NULL,
	[scope_update_peer_key] [int] NULL,
	[scope_update_peer_timestamp] [bigint] NULL,
	[local_update_peer_key] [int] NOT NULL,
	[local_update_peer_timestamp] [timestamp] NOT NULL,
	[create_scope_local_id] [int] NULL,
	[scope_create_peer_key] [int] NULL,
	[scope_create_peer_timestamp] [bigint] NULL,
	[local_create_peer_key] [int] NOT NULL,
	[local_create_peer_timestamp] [bigint] NOT NULL,
	[sync_row_is_tombstone] [int] NOT NULL,
	[restore_timestamp] [bigint] NULL,
	[last_change_datetime] [datetime] NULL,
 CONSTRAINT [PK_DataSync.TestPattern_dss_tracking] PRIMARY KEY CLUSTERED 
(
	[PatternID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DataSync].[TestPattern_dss_tracking]') AND name = N'local_update_peer_timestamp_index')
CREATE NONCLUSTERED INDEX [local_update_peer_timestamp_index] ON [DataSync].[TestPattern_dss_tracking]
(
	[local_update_peer_timestamp] ASC,
	[PatternID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DataSync].[TestPattern_dss_tracking]') AND name = N'tombstone_index')
CREATE NONCLUSTERED INDEX [tombstone_index] ON [DataSync].[TestPattern_dss_tracking]
(
	[sync_row_is_tombstone] ASC,
	[local_update_peer_timestamp] ASC
)
INCLUDE([last_change_datetime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
