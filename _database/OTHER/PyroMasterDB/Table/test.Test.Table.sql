SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[Test]') AND type in (N'U'))
BEGIN
CREATE TABLE [test].[Test](
	[TestId] [int] IDENTITY(0,1) NOT NULL,
	[TestCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestDescription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TestClassId] [int] NOT NULL,
	[TestTypeId] [int] NOT NULL,
	[ObjectType] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[test].[DF__Test__CreatedDT__442B18F2]') AND type = 'D')
BEGIN
ALTER TABLE [test].[Test] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[Test_dss_delete_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[Test_dss_delete_trigger] ON [test].[Test] FOR DELETE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 1111675008 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[Test_dss_tracking] AS [target] 
USING (SELECT [i].[TestId] FROM DELETED AS [i]) AS source([TestId]) 
ON ([target].[TestId] = [source].[TestId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 1, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestId],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 1, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[Test] ENABLE TRIGGER [Test_dss_delete_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[Test_dss_insert_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[Test_dss_insert_trigger] ON [test].[Test] FOR INSERT AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 1111675008 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[Test_dss_tracking] AS [target] 
USING (SELECT [i].[TestId] FROM INSERTED AS [i]) AS source([TestId]) 
ON ([target].[TestId] = [source].[TestId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestId],NULL, NULL, NULL, 0, CAST(@@DBTS AS BIGINT) + 1, NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[Test] ENABLE TRIGGER [Test_dss_insert_trigger]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[test].[Test_dss_update_trigger]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [test].[Test_dss_update_trigger] ON [test].[Test] FOR UPDATE AS
SET NOCOUNT ON
DECLARE @marker_create_scope_local_id INT
DECLARE @marker_scope_create_peer_timestamp BIGINT
DECLARE @marker_scope_create_peer_key INT
DECLARE @marker_local_create_peer_timestamp BIGINT
DECLARE @marker_local_create_peer_key INT
DECLARE @marker_state INT
SELECT TOP 1 @marker_create_scope_local_id = [provision_scope_local_id], @marker_local_create_peer_timestamp = [provision_timestamp], @marker_local_create_peer_key = [provision_local_peer_key], @marker_scope_create_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_create_peer_key = [provision_scope_peer_key], @marker_state = [state]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 1111675008 
 AND [owner_scope_local_id] = 0

MERGE [DataSync].[Test_dss_tracking] AS [target] 
USING (SELECT [i].[TestId] FROM INSERTED AS [i]) AS source([TestId]) 
ON ([target].[TestId] = [source].[TestId])
WHEN MATCHED THEN
UPDATE SET [sync_row_is_tombstone] = 0, 
[local_update_peer_key] = 0, 
[restore_timestamp] = NULL, 
[update_scope_local_id] = NULL, [last_change_datetime] = GETDATE()
WHEN NOT MATCHED THEN
INSERT (
[TestId] ,
[create_scope_local_id], [scope_create_peer_key], [scope_create_peer_timestamp], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) 
VALUES (
[source].[TestId],@marker_create_scope_local_id, @marker_scope_create_peer_key, @marker_scope_create_peer_timestamp, 0, @marker_local_create_peer_timestamp , NULL, 0, 0, GETDATE() , NULL);
' 
GO
ALTER TABLE [test].[Test] ENABLE TRIGGER [Test_dss_update_trigger]
GO