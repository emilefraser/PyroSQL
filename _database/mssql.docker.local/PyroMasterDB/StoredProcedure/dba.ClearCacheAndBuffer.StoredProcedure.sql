SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[ClearCacheAndBuffer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[ClearCacheAndBuffer] AS' 
END
GO
/* 
	WHY? 
		Ad-hoc Query workload issues due to cache bloat
		Excessive use of dynamic T-SQL code
		Server has insufficient memory or not properly assigned to SQL instances
		Memory pressure generated due to heavy long running transactions
		Server has frequent recompilation events
*/
ALTER PROCEDURE [dba].[ClearCacheAndBuffer]
AS 
BEGIN

	-- CHECKPOINT
	-- GET Dirty Pages out of bugger pool
	CHECKPOINT

	-- FREEPROCCACHE
	-- DBCC FREEPROCCACHE [ ( { plan_handle | sql_handle | pool_name } ) ] [ WITH NO_INFOMSGS ] 
	-- This command allows you to clear the plan cache, a specific plan or a SQL Server resource pool
	DBCC FREEPROCCACHE WITH NO_INFOMSGS;

	-- FLUSHPROCINDB
	-- DBCC FLUSHPROCINDB(database_id)
	DECLARE @dbid INT = DB_ID() 
	DBCC FLUSHPROCINDB (@dbId)

	-- FREEESYSTEMCACHE
	-- DBCC FREESYSTEMCACHE( 'ALL' [, pool_name ] ) [WITH { [ MARK_IN_USE_FOR_REMOVAL ] , [ NO_INFOMSGS ]]
	-- Releases all unused cache entries from all caches.
	DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL 

	-- FREESESSIONCACHE
	-- DBCC FREESESSIONCACHE [ WITH NO_INFOMSGS ]
	-- Flushes the distributed query connection cache used by distributed queries against an instance of SQL Server
	DBCC FREESESSIONCACHE WITH NO_INFOMSGS;

	-- FLUASHAUTHCACHE
	-- DBCC FLUSHAUTHCACHE [ ; ]
	--  flushes the database authentication cache maintained information regarding login and firewall rules for the current user database
	DBCC FLUSHAUTHCACHE

	-- sp_recompile
	-- EXEC sp_recompile N'Object';
	-- For procedure name, trigger, table, view, function in the current database and it will be recompiled
	 EXEC sp_recompile N'ProcedureName'

	-- DROPCLEANBUFFERS
	-- DBCC DROPCLEANBUFFERS [ WITH NO_INFOMSGS ] 
	-- DBCC DROPCLEANBUFFERS ( COMPUTE | ALL ) [ WITH NO_INFOMSGS ]
	-- Test queries with a cold buffer cache without shutting down and restarting the server
	DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS 


END
GO
