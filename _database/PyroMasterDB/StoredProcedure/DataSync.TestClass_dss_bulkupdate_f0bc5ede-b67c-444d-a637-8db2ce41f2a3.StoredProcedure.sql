SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[TestClass_dss_bulkupdate_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataSync].[TestClass_dss_bulkupdate_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS' 
END
GO
ALTER PROCEDURE [DataSync].[TestClass_dss_bulkupdate_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [DataSync].[TestClass_dss_BulkType_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] READONLY
AS
BEGIN
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

DECLARE @marker_update_scope_local_id INT
DECLARE @marker_scope_update_peer_timestamp BIGINT
DECLARE @marker_scope_update_peer_key INT
DECLARE @marker_local_update_peer_timestamp BIGINT
DECLARE @marker_local_update_peer_key INT
SELECT TOP 1 @marker_update_scope_local_id = [provision_scope_local_id], @marker_local_update_peer_timestamp = [provision_timestamp], @marker_local_update_peer_key = [provision_local_peer_key], @marker_scope_update_peer_timestamp = [provision_scope_peer_timestamp], @marker_scope_update_peer_key = [provision_scope_peer_key]
FROM [DataSync].[provision_marker_dss]
WHERE [object_id] = 967674495 
 AND [owner_scope_local_id] = 1
-- use a temp table to store the list of PKs that successfully got updated
declare @changed TABLE ([TestClassId] smallint, PRIMARY KEY ([TestClassId]));

SET IDENTITY_INSERT [test].[TestClass] ON;
-- update the base table
MERGE [test].[TestClass] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.update_scope_local_id, t.scope_update_peer_key, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [DataSync].[TestClass_dss_tracking] t ON p.[TestClassId] = t.[TestClassId]) as changes ON changes.[TestClassId] = base.[TestClassId]
WHEN MATCHED AND (changes.update_scope_local_id = @sync_scope_local_id AND changes.scope_update_peer_key = changes.sync_update_peer_key) OR changes.local_update_peer_timestamp <= @sync_min_timestamp-- No tracking record exists
OR (changes.update_scope_local_id IS NULL AND changes.scope_update_peer_key IS NULL AND changes.local_update_peer_timestamp IS NULL) 
 THEN
UPDATE SET [TestClassCode] = changes.[TestClassCode], [TestClassName] = changes.[TestClassName], [CreatedDT] = changes.[CreatedDT]
OUTPUT INSERTED.[TestClassId] into @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [test].[TestClass] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0
FROM 
[DataSync].[TestClass_dss_tracking] side JOIN 
(SELECT p.[TestClassId], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[TestClassId] = t.[TestClassId]) as changes ON changes.[TestClassId] = side.[TestClassId]
SELECT [TestClassId] FROM @changeTable t WHERE NOT EXISTS (SELECT [TestClassId] from @changed i WHERE t.[TestClassId] = i.[TestClassId])
END
GO
