SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[TestPattern_dss_bulkinsert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataSync].[TestPattern_dss_bulkinsert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS' 
END
GO
ALTER PROCEDURE [DataSync].[TestPattern_dss_bulkinsert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [DataSync].[TestPattern_dss_BulkType_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([PatternID] int, PRIMARY KEY ([PatternID]));

SET IDENTITY_INSERT [test].[TestPattern] ON;
-- update/insert into the base table
MERGE [test].[TestPattern] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [DataSync].[TestPattern_dss_tracking] t ON p.[PatternID] = t.[PatternID]) AS changes ON changes.[PatternID] = base.[PatternID]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([PatternID], [TestName], [TestDesription], [TestClassName], [TestObjectType], [TestScope], [CreatedDT]) VALUES (changes.[PatternID], changes.[TestName], changes.[TestDesription], changes.[TestClassName], changes.[TestObjectType], changes.[TestScope], changes.[CreatedDT])
OUTPUT INSERTED.[PatternID] INTO @changed; -- populates the temp table with successful PKs

SET IDENTITY_INSERT [test].[TestPattern] OFF;
UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0,
create_scope_local_id = @sync_scope_local_id,
scope_create_peer_key = changes.sync_create_peer_key,
scope_create_peer_timestamp = changes.sync_create_peer_timestamp,
local_create_peer_key = 0
FROM 
[DataSync].[TestPattern_dss_tracking] side JOIN 
(SELECT p.[PatternID], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[PatternID] = t.[PatternID]) AS changes ON changes.[PatternID] = side.[PatternID]
SELECT [PatternID] FROM @changeTable t WHERE NOT EXISTS (SELECT [PatternID] from @changed i WHERE t.[PatternID] = i.[PatternID])
END
GO
