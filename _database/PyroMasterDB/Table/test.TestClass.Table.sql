SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[TestClass]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[TestClass](
	[TestClassId] [smallint] IDENTITY(0,1) NOT NULL,
	[TestClassCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestClassName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TestClassId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF__TestClass__Creat__3B95D2F1]') AND type = 'D')
BEGIN
ALTER TABLE [test].[TestClass] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestClass_dss_delete_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestClass_dss_delete_trigger] ON [test].[TestClass] FOR DELETE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 967674495 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestClass_dss_tracking] AS [target] 
USING (SELECT [i].[TestClassId] FROM DELETED AS [i]) AS source([TestClassId]) 
ON ([target].[TestClassId] = [source].[TestClassId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 1, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestClassId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestClassId],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 1, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestClass] ENABLE TRIGGER [TestClass_dss_delete_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestClass_dss_insert_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestClass_dss_insert_trigger] ON [test].[TestClass] FOR INSERT AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 967674495 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestClass_dss_tracking] AS [target] 
USING (SELECT [i].[TestClassId] FROM INSERTED AS [i]) AS source([TestClassId]) 
ON ([target].[TestClassId] = [source].[TestClassId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestClassId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestClassId],NULL, NULL, NULL, 0, CAST(@@DBTS AS BIGINT) + 1, NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestClass] ENABLE TRIGGER [TestClass_dss_insert_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[TestClass_dss_update_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[TestClass_dss_update_trigger] ON [test].[TestClass] FOR UPDATE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 967674495 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[TestClass_dss_tracking] AS [target] 
USING (SELECT [i].[TestClassId] FROM INSERTED AS [i]) AS source([TestClassId]) 
ON ([target].[TestClassId] = [source].[TestClassId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestClassId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestClassId],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[TestClass] ENABLE TRIGGER [TestClass_dss_update_trigger]
GO
