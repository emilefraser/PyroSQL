SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestPattern]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[TestPattern](
	[PatternID] [int] IDENTITY(0,1) NOT NULL,
	[TestName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestDesription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestObjectType] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestScope] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PatternID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF_test_TestPattern_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [test].[TestPattern] ADD  CONSTRAINT [DF_test_TestPattern_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestPattern_dss_delete_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestPattern_dss_delete_trigger] ON [test].[TestPattern] FOR DELETE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 882102183 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestPattern_dss_tracking] AS [target] 
USING (SELECT [i].[PatternID] FROM DELETED AS [i]) AS source([PatternID]) 
ON ([target].[PatternID] = [source].[PatternID])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 1, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[PatternID] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[PatternID],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 1, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestPattern] ENABLE TRIGGER [TestPattern_dss_delete_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestPattern_dss_insert_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestPattern_dss_insert_trigger] ON [test].[TestPattern] FOR INSERT AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 882102183 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestPattern_dss_tracking] AS [target] 
USING (SELECT [i].[PatternID] FROM INSERTED AS [i]) AS source([PatternID]) 
ON ([target].[PatternID] = [source].[PatternID])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[PatternID] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[PatternID],NULL, NULL, NULL, 0, CAST(@@DBTS AS BIGINT) + 1, NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestPattern] ENABLE TRIGGER [TestPattern_dss_insert_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestPattern_dss_update_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestPattern_dss_update_trigger] ON [test].[TestPattern] FOR UPDATE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 882102183 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestPattern_dss_tracking] AS [target] 
USING (SELECT [i].[PatternID] FROM INSERTED AS [i]) AS source([PatternID]) 
ON ([target].[PatternID] = [source].[PatternID])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[PatternID] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[PatternID],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestPattern] ENABLE TRIGGER [TestPattern_dss_update_trigger]
GO
