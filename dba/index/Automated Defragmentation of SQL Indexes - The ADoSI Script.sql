USE [MSDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================================================
-- Description:	Automated Defragmentation of SQL Indexes - The ADoSI Script
--				Defragment indexes that fall outside desirable fragmentation and page space use thresholds.
--				http://benefic.net/automated-defragmentation-of-sql-indexes-the-adosi-script
-- ------------
-- Modification By:					- Description of Change:
--   2014/02/11 Ben Moore			- Creation
-- =====================================================================================================================
ALTER PROCEDURE [dbo].[DefragIndexes] 
													-- A comma-delimited list of database names to check indexes on.
													--   If null, the currently active database is checked.
	@DatabasesToReorg nvarchar(200)					--   Ex.  'master,msdb'
			= NULL

	,@RunMode varchar(7)							-- A mode of operation, with options as follows:
			= 'Normal'								--   Normal	 = Gather, Defrag, Alert.
													--   Create	 = Create defrag tables.
													--   Gather	 = Get index stats.
													--   Defrag	 = Defrag flagged indexes.
													--   Alert   = Produce alert messages.
													--   All	 = Create, Gather, Defrag, Alert.
													--   DCreate = Drop and Create defrag tables.

	,@OnlineMode varchar(12)						-- Use the following online option when rebuilding indexes:
			= 'Normal'								--   Normal  = ReOrg or reBuild as flagged. ReBuild offline.
													--   Lazy    = ReOrg or reBuild as flagged.  ReBuild online if
													--				possible, offline otherwise.
													--   Offline = Offline reBuild all, even if flagged for reOrg.
													--   Online  = Only allow online operations. Fallback to reOrg
													--				if online reBuild is not possible.

	,@DefragOnly1 bit								-- If enabled, only a single index gets defragged this run.
			= 'false'								--   Useful when combined with RunMode Defrag for testing.

	,@SPTimeMaxRun DATETIME			 				-- No index defrags will be started after this maximum time
			= '03:00'								--   duration is reached.  Set to NULL for no time limit.

	----------------------------------------
	,@AlertMode varchar(12)							-- Produce Alert messages of the following types:
			= 'Error'								--   None       = No message
													--   Error      = Show indexes that had defrag errors.
													--   Success    = Show successfully defragged indexes.
													--   Both       = Error and Success.
													--   Candidate  = Show index candidates for defrag.

													-- A semicolon-delimited list of e-mail addresses
													--   to send Alerts to.  Leave null to disable email.
	,@AlertEmailRecipients nvarchar(500)			--   Ex.  'me@myCompany.com;you@anotherCompany.com'
			= NULL

	,@AlertEmailProfile sysname						-- A valid Database Mail Profile that you have set up in
			= NULL									--   SQL Server.  Leave null to use any user/system defaults.

	,@AlertAcknowledge bit							-- Set the defragAcknowledged bit on entries that are sent
			= 'true'								--   in Alerts so that they will not be sent again.

AS
------------------------------------------------------------------------------------------------------------------------
BEGIN -- Stored Procedure
--
--
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;				-- Sets WITH (NOLOCK) on all tables in this session.

----------------
-- Perform some error checking on the SP parameters
--
IF @RunMode not in (											-- Test if @RunMode is a valid option.
	'Normal','Create','Gather','Defrag','Alert','All','DCreate')
BEGIN
	RAISERROR('Invalid RunMode.
		Valid modes: Normal, Create, Gather, Defrag, Alert, All, DCreate'
		,11 ,1);
	RETURN
END


IF @OnlineMode not in (											-- Test if @OnlineMode is a valid option.
	'Normal','Lazy','Offline','Online')
BEGIN
	RAISERROR('Invalid OnlineMode.
		Valid modes: Normal, Lazy, Offline, Online'
		,11 ,1);
	RETURN
END


IF @AlertMode not in (											-- Test if @AlertMode is a valid option.
'None','Error','Success','Both','Candidate')
BEGIN
	RAISERROR('Invalid AlertMode.
		Valid modes: None, Error, Success, Both, Candidate'
		,11 ,1);
	RETURN
END


----------------
-- Set up a few vars related to the max run time option.
--
DECLARE @SPTimeStarted DATETIME = GetDate();					-- Time this SP was started.
DECLARE @SPTimeLimit DATETIME									-- Time when limit will be exceeded.
	= (@SPTimeStarted + @SPTimeMaxRun)							--   If @SPTimeMaxRun is null, this will also be null.
DECLARE @SPTimeExceeded bit = 'false';							-- A flag to capture if time limit was exceeded when
																--   work was still left to be done.

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Create defrag tables.
--
IF @RunMode in ('Create','All','DCreate')
BEGIN -- Create defrag tables

	----------------
	-- This table holds the current fragmentation statistics.
	--
	IF object_id('dbo.IndexFragStats') IS NOT NULL
	BEGIN
		IF @RunMode = 'DCreate'
			DROP TABLE dbo.IndexFragStats;
		ELSE
			BEGIN
				RAISERROR('Support table ''dbo.IndexFragStats'' already exists, 
					first drop this table if you wish to recreate it.' 
					,11 ,1);
				RETURN
			END
	END

	CREATE TABLE dbo.IndexFragStats (
		 [id]							[int] IDENTITY(1,1) NOT NULL	-- The row identity column of the defrag table.
		,[runDate]						[datetime] NULL					-- DateTime last operation was performed.
		,[dbName]						[nvarchar](128) NOT NULL
		,[schemaName]					[nvarchar](128) NOT NULL
		,[objectName]					[sysname] NOT NULL				-- Table name.
		,[indexName]					[sysname] NULL
		,[index_type_desc]				[nvarchar](60) NULL
		,[partition_number]				[bigint] NULL
		,[partitionCount]				[bigint] NULL					-- Total count of partitions for an index.
		,[db_id]						[int] NOT NULL
		,[object_id]					[int] NOT NULL
		,[index_id]						[int] NOT NULL

		,[is_disabled]					[bit] NULL
		,[allow_page_locks]				[bit] NOT NULL
		,[objectLOBColumnCount]			[int] NULL
		,[indexLOBColumnCount]			[int] NULL
		,[fill_factor]					[tinyint] NULL
		,[record_count]					[bigint] NULL

		,[avg_fragmentation_pct]			[float] NULL
		,[fragment_count]					[bigint] NULL
		,[avg_frag_size_in_pages]			[float] NULL
		,[avg_page_space_used_pct]			[float] NULL
		,[page_count]						[bigint] NULL

		,[defrag_avg_fragmentation_pct]		[float] NULL
		,[defrag_fragment_count]			[bigint] NULL
		,[defrag_avg_frag_size_in_pages]	[float] NULL
		,[defrag_avg_page_space_used_pct]	[float] NULL
		,[defrag_page_count]				[bigint] NULL

		,[defragRequired]				[char](1) NULL					-- reBuild, reOrganize, or Skip.
		,[defragCommand]				[nvarchar](255) NULL
		,[defragStatus]					[nvarchar](2048) NULL			-- Command exit status, 0 indicates success.
		,[defragDurationSeconds]		[int] NULL
		,[defragAcknowledged]			[bit] NULL

	) ON [PRIMARY];



	----------------
	-- This table holds the history of fragmentation statistics for all indexes that have been defragmented.
	--
	IF object_id('dbo.IndexFragHist') IS NOT NULL
	BEGIN
		IF @RunMode = 'DCreate'
			DROP TABLE dbo.IndexFragHist;
		ELSE
			BEGIN
				RAISERROR('Support table ''dbo.IndexFragHist'' already exists, 
					first drop this table if you wish to recreate it.' 
					,11 ,1);
				RETURN
			END
	END

	CREATE TABLE dbo.IndexFragHist (
		 [id]							[int] IDENTITY(1,1) NOT NULL
		,[runDate]						[datetime] NULL
		,[dbName]						[nvarchar](128) NOT NULL
		,[schemaName]					[nvarchar](128) NOT NULL
		,[objectName]					[sysname] NOT NULL
		,[indexName]					[sysname] NULL
		,[index_type_desc]				[nvarchar](60) NULL
		,[partition_number]				[bigint] NULL
		,[partitionCount]				[bigint] NULL
		,[db_id]						[int] NOT NULL
		,[object_id]					[int] NOT NULL
		,[index_id]						[int] NOT NULL

		,[is_disabled]					[bit] NULL
		,[allow_page_locks]				[bit] NULL
		,[objectLOBColumnCount]			[int] NULL
		,[indexLOBColumnCount]			[int] NULL
		,[fill_factor]					[tinyint] NULL
		,[record_count]					[bigint] NULL

		,[avg_fragmentation_pct]			[float] NULL
		,[fragment_count]					[bigint] NULL
		,[avg_frag_size_in_pages]			[float] NULL
		,[avg_page_space_used_pct]			[float] NULL
		,[page_count]						[bigint] NULL

		,[defrag_avg_fragmentation_pct]		[float] NULL
		,[defrag_fragment_count]			[bigint] NULL
		,[defrag_avg_frag_size_in_pages]	[float] NULL
		,[defrag_avg_page_space_used_pct]	[float] NULL
		,[defrag_page_count]				[bigint] NULL

		,[defragRequired]				[char](1) NULL
		,[defragCommand]				[nvarchar](255) NULL
		,[defragStatus]					[nvarchar](2048) NULL
		,[defragDurationSeconds]		[int] NULL
		,[defragAcknowledged]			[bit] NULL

	) ON [PRIMARY];



	----------------
	-- This exclusion table holds index entries you would like this defragmentation process to skip.
	--   Useful, for example, if you have a huge index that would take hours to defragment that you prefer
	--   to maintain manually.  Or maybe you have an index that is requiring a daily defrag, an issue that
	--   might be resolvable with an ETL change, but you have not gotten around to seeing if that is possible. 
	--
	IF object_id('dbo.IndexFragExclusion') IS NOT NULL
	BEGIN
		IF @RunMode = 'DCreate'
			DROP TABLE dbo.IndexFragExclusion;
		ELSE
			BEGIN
				RAISERROR('Support table ''dbo.IndexFragExclusion'' already exists, 
					first drop this table if you wish to recreate it.' 
					,11 ,1);
				RETURN
			END
	END

	CREATE TABLE dbo.IndexFragExclusion (
		 [dbName]						[nvarchar](128) NOT NULL
		,[schemaName]					[nvarchar](128) NOT NULL
		,[objectName]					[sysname] NOT NULL
		,[indexName]					[sysname] NOT NULL
		,[exclude]						[bit] NOT NULL

	) ON [PRIMARY];

END -- Create defrag tables
	



------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Get current index information and identify which indexes require defragmentation.
--
IF @RunMode in ('Normal','Gather','All')
BEGIN -- Gather index stats

	DECLARE @sql NVARCHAR(4000)

	DECLARE @in_dbCurrent VARCHAR(50) = NULL
	DECLARE @dbname VARCHAR(50) = NULL
	DECLARE @db_id VARCHAR(8) = NULL


	while len(@DatabasesToReorg) > 0							-- Iterate through all passed in database names.
		OR @DatabasesToReorg is NULL							-- If no database passed in, use current database.
	BEGIN --Loop to Get index info for all requested databases

		SET @in_dbCurrent =  left(@DatabasesToReorg				-- Get first database from the list...
			, charindex(',', @DatabasesToReorg+',')-1);
		set @DatabasesToReorg = stuff(@DatabasesToReorg, 1		-- AND remove it from the list to prepare for
			, charindex(',', @DatabasesToReorg+','), '');		--   the next iteration.

		SET @db_id = case when @in_dbCurrent is null			-- Get ID of the database from passed in name
			then DB_ID() else DB_ID(@in_dbCurrent) end;			--   and verify that it exists.

		IF @db_id is not NULL
		BEGIN --Get index info for database

			SET @dbname = DB_NAME(@db_id);

			DELETE dbo.IndexFragStats							-- Delete existing entries for current database to
				WHERE dbName = @dbName;							--   prepare to get current index data.
			
				

			------------------------------------------------------------------------------------------------------------
			-- Get info for all indexes across all table objects across all schemas of the current database.
			set @sql = '
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;	-- Sets WITH (NOLOCK) on all tables in this session.
			INSERT dbo.IndexFragStats
			(
				 [runDate]
				,[dbName]	
				,[schemaName]
				,[objectname]	
				,[indexName]
				,[index_type_desc]
				,[partition_number]
				,[partitionCount]
				,[db_id]	
				,[object_id]
				,[index_id]	

				,[is_disabled]
				,[allow_page_locks]
				,[objectLOBColumnCount]
				,[indexLOBColumnCount]
				,[fill_factor]	
				,[record_count]	

				,[avg_fragmentation_pct]		
				,[fragment_count]	
				,[avg_frag_size_in_pages]		
				,[avg_page_space_used_pct]	
				,[page_count]
			)						
			SELECT
				 getdate() as rundate
				,o.dbName
				,o.schemaName
				,o.objectname
				,i.name AS indexname
				,s.index_type_desc
				,s.partition_number
				,p.partitionCount
				,o.db_id
				,o.object_id
				,i.index_id

				,i.is_disabled
				,i.allow_page_locks
				,ObjectWithLOBs.objectLOBColumnCount
				,IndexWithLOBs.indexLOBColumnCount
				,fill_factor
				,s.record_count

				,s.avg_fragmentation_in_percent
				,s.fragment_count
				,s.avg_fragment_size_in_pages
				,s.avg_page_space_used_in_percent
				,s.page_count
			--------
			FROM  ' + @dbname + '.sys.dm_db_index_physical_stats('
				 + @db_id + ', NULL, NULL, NULL , ''SAMPLED'') s
			--------
			join  ' + @dbname + '.sys.indexes i					-- Get basic Index information.
			on s.index_id = i.index_id 
				and s.object_id = i.object_id
			join (												-- Get basic DB, Schema, and Object information.
				select ''' + @dbname + ''' as dbName
					,''' +@db_id + ''' as db_id
					,OBJECT_SCHEMA_NAME(so.object_id
						, ' + @db_id + ') as schemaName
					,so.name as objectname
					,so.object_id
				from ' + @dbname + '.sys.objects so
				join ' + @dbname + '.sys.tables st
					on so.object_id = st.object_id
			) o
			on s.object_id =o.object_id
			--------
			join (												-- Does index have multiple partitions?
				select object_id
					,index_id
					,count(*) as partitionCount
				FROM  ' + @dbname + '.sys.partitions
				group by object_id, index_id
			) p
			on s.index_id = p.index_id
				and s.object_id = p.object_id
			--------
			left outer join (									-- Does indexes source table have LOB columns?
				SELECT object_id
					,COUNT(*) as objectLOBColumnCount
				FROM ' + @dbname + '.sys.columns
				WHERE (system_type_id IN (34, 35, 99)			-- 34 = IMAGE, 35 = TEXT, 99 = NTEXT
					OR max_length = -1)							-- VARBINARY(MAX), (N)VARCHAR(MAX), XML, Spatial
				group by object_id
			) ObjectWithLOBs
			on s.object_id = ObjectWithLOBs.object_id
			--------
			left outer join (									-- Does index have LOB columns?
				SELECT tc.object_id, ic.index_id
					,COUNT(*) as indexLOBColumnCount
				FROM ' + @dbname + '.sys.index_columns ic
				JOIN ' + @dbname + '.sys.columns tc
					ON ic.object_id = tc.object_id
						AND ic.[column_id]  =   tc.[column_id]
				WHERE (system_type_id IN (34, 35, 99)			-- 34 = IMAGE, 35 = TEXT, 99 = NTEXT
					OR max_length = -1)							-- VARBINARY(MAX), (N)VARCHAR(MAX), XML, Spatial
				group by tc.object_id, ic.index_id
			) IndexWithLOBs
			on s.object_id = IndexWithLOBs.object_id
				and s.index_id = IndexWithLOBs.index_id
			--------
			where s.alloc_unit_type_desc = ''IN_ROW_DATA''		-- Disregard overflow, LOB, etc. sub-index types.
			order by o.dbName, o.schemaName, o.objectName
			';

				
			EXEC SP_EXECUTESQL @sql

		END --Get index info for database

		IF @DatabasesToReorg is NULL break;						-- Break out of loop if only running on current DB.

	END --Loop to Get index info for all requested databases




	--------------------------------------------------------------------------------------------------------------------
	-- Identify which indexes fall outside desirable fragmentation and page space use thresholds and need defragged.
	--
	-- Based on MS Recommended thresholds for reorg/rebuild operations:
	-- frag type							reorg		rebuild
	-- avg_fragmentation_in_percent			> 5			> 30
	-- avg_page_space_used_in_percent		< 75		< 60
	--
	UPDATE  ifs
	set defragRequired =
	CASE
		when ife.exclude = 'true'					-- If you have indexes you do not want to defrag add them to the
			then 'S'								--   exclusion table and they will be flagged here to be Skipped.
		--------
		when	(avg_fragmentation_pct   > 30)  
			or	(avg_page_space_used_pct < 60)
			then 'B'								-- reBuild
		when	(avg_fragmentation_pct   >  5)  
			or	(avg_page_space_used_pct < 75)
			then 'O'								-- reOrganize
	END
	from dbo.IndexFragStats ifs
	left outer join dbo.IndexFragExclusion ife
		on	ifs.dbName		= ife.dbName
		and	ifs.schemaName	= ife.schemaName
		and	ifs.objectName	= ife.objectName
		and	ifs.indexName	= ife.indexName
	--------
	where index_type_desc <> 'heap'					-- To 'defrag' a heap, you could create then drop a clust index.
		and page_count > 500						-- Per Microsoft, defragging indexes with low (<1000) page
													--   counts results in negligible performance gains.
		and is_disabled = 0							-- We want to leave disabled indexes alone, because a rebuild 
													--   would reenable them and an attempt to reorg would fail.


	--------------------------------------------------------------------------------------------------------------------
	-- Assemble the index reorg/rebuild SQL command and save to the defragCommand field.
	--		NOTE:  In almost all cases a normal index rebuild will cause a lock that prevents other interactions
	--			with the underlying table for the duration of the rebuild.  Usage of an ONLINE option can keep the
	--			table operational, IF your environment and index meet the correct requirements that allow it.
	--
	DECLARE @ProdVerMajor  varchar(3)									-- The version of SQL server we are running.
	DECLARE @EngineEdition varchar(1)									-- To check if we have Enterprise edition.

	SET @ProdVerMajor = SUBSTRING(cast(SERVERPROPERTY('ProductVersion') as VARCHAR(36))
		, 1, ( CHARINDEX('.',cast(SERVERPROPERTY('ProductVersion') as VARCHAR(36))) - 1) )
	SET @EngineEdition = cast(SERVERPROPERTY('EngineEdition') as varchar(1))

	----------------
	-- Contains the logic that decides if an online reBuild is possible
	--   based on SQL Server and index properties.
	--
	; WITH CTE_FragStats_base as (
		select
			 dbName
			,schemaName
			,objectName
			,indexName
			,index_type_desc
			,allow_page_locks
			,partitionCount
			,CAST(partition_number AS nvarchar(10)) as partition_number
			,defragRequired
			,defragCommand

			,CASE
				WHEN @EngineEdition = 3									-- SQL Enterprise edition is required.

																		-- Partition check:
				and	(	@ProdVerMajor > 11								-- SQL Server 2014+  OR
					OR	(  @ProdVerMajor <= 11  						-- SQL Server 2012 and lower
							AND partitionCount = 1 )					--   and Index not partitioned.
				)

				and index_type_desc not in (							-- These index types cannot be
					 'PRIMARY XML INDEX'								--   rebuilt online.
					,'SPATIAL INDEX'
					,'XML INDEX'
					,'CLUSTERED COLUMNSTORE'
					,'NONCLUSTERED COLUMNSTORE'
				)
																		-- LOB check:
				and (	@ProdVerMajor >= 11								-- SQL Server 2012 and Higher OR
					OR (	index_type_desc not in
								('CLUSTERED INDEX'
								,'NONCLUSTERED INDEX')
						OR	( index_type_desc = 'CLUSTERED INDEX'		-- Clustered Index
								AND objectLOBColumnCount is null )		--   with no table LOB columns.
						OR	(index_type_desc = 'NONCLUSTERED INDEX'		-- NonClustered index
								AND indexLOBColumnCount is null )		--   with no index LOB columns.
					)
				)

				THEN 'true'
				ELSE 'false'
			END as [isRebuildOnlinePossible]

		from dbo.IndexFragStats
		WHERE (	defragRequired is not null								-- Index was flagged to be rebuilt.
					and defragRequired <> 'S')
			and defragCommand is null									-- A defrag command has not yet been generated.
	)	
	----------------
	-- Contains the logic that decides if a reBuild or reOrg should be done based on the @onlineMode,
	--   the calculated defragRequired type, the isRebuildOnlinePossible status, and the index properties.
	--
	, CTE_FragStats as (
		select *
		,case
			when @onlineMode  = 'Normal'								-- ReOrg or reBuild as flagged. ReBuild offline.
			then (
				case 	when defragRequired = 'B'  then  'REBUILD' 
						when defragRequired = 'O' 
							and allow_page_locks = 0  then  'REBUILD'
						else 'REORGANIZE'
				end
			)
			when @onlineMode  = 'Lazy'									-- ReOrg or reBuild as flagged.  ReBuild online
			then (														--   if possible, offline otherwise.
				case 	when defragRequired = 'B'  then  'REBUILD'
						when defragRequired = 'O' 
							and allow_page_locks = 0  then  'REBUILD'
						else 'REORGANIZE'
				end
			)

			when @onlineMode = 'Offline'								-- Offline reBuild all, even if flagged reOrg.
			then 'REBUILD'

			when @onlineMode = 'Online'									-- Only allow online operations. Fallback to
			then (														--   reOrg if online reBuild is not possible.
				case	when isRebuildOnlinePossible = 'false'  
							then  'REORGANIZE'
						when defragRequired = 'B'  then  'REBUILD' 
						when allow_page_locks = 0  then  'REBUILD'
						else 'REORGANIZE' 
				end	
			)
		END as [rebuildOrReorg]

		from CTE_FragStats_base
	)
	--------
	UPDATE fs
	set defragCommand =
		'ALTER INDEX   [' + indexName + ']'
		+ '    ON    [' + dbName + '].[' + schemaName + '].[' + objectName + ']    '

		+ rebuildOrReorg												-- ReBuild or reOrganize?

		+ CASE															-- Run on individual partition?
			when partitionCount > 1
				and index_type_desc not in (							-- These index types cannot be
					 'PRIMARY XML INDEX'								--   reBuilt or reOrged by partition.
					,'SPATIAL INDEX'
					,'XML INDEX'
				)
			then (' PARTITION=' + partition_number)
			else '' end

		+ CASE															-- Rebuild ONLINE?
			when 
				@onlineMode in ('Online','Lazy')
				and rebuildOrReorg = 'REBUILD'
				and isRebuildOnlinePossible = 'true'
			then ' WITH (ONLINE=ON)'
			else '' end
	FROM CTE_FragStats fs


END -- Gather index stats




--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- Defrag all identified indexes, one by one, that have not yet been defragged.
--
IF @RunMode in ('Normal','Defrag','All')
BEGIN -- Defrag flagged indexes

	DECLARE @r_ID				INT							-- The row identity column from the defrag table.
	DECLARE @r_db_id			INT
	DECLARE @r_object_id		INT
	DECLARE @r_index_id			INT
	DECLARE @r_partition_number	INT
	DECLARE @r_defragCommand	NVARCHAR(255)				-- The reBuild/reOrganize SQL command.

	DECLARE @r_Error			NVARCHAR(2048)				-- Command exit status, 0 indicates success.
	DECLARE @r_startTime		datetime					-- Time defrag started.
	DECLARE @r_endTime			datetime					-- Time defrag completed.

	
	DECLARE cur_indexes CURSOR FOR							-- Cursor for the list of indexes to process.
		SELECT
			 id
			,db_id
			,object_id
			,index_id
			,partition_number
			,defragCommand
		FROM dbo.IndexFragStats
		WHERE defragCommand is not null						-- Index was flagged to be defragged.		
			and defragStatus is null						-- No defrag attempted on this index yet.
		ORDER BY page_count ,objectname ,indexname;			-- Reorder/change this order by if you want to
															-- change the order that indexes get defragged.


	OPEN cur_indexes;										-- Open the cursor.

	WHILE (1=1)
	BEGIN													-- Loop through the indexes/partitions.
		SET @r_startTime = getdate()						-- Time defrag started.

		FETCH NEXT
		FROM cur_indexes
		INTO
			 @r_id
			,@r_db_id
			,@r_object_id
			,@r_index_id
			,@r_partition_number
			,@r_defragCommand
		IF @@FETCH_STATUS < 0 BREAK;						-- Exit loop if we have reached end of cursor.
		IF (GETDATE() > isnull(@SPTimeLimit,GETDATE()))		-- Exit loop if a max run time was passed in
		BEGIN												--   that has been exceeded.
			SET @SPTimeExceeded = 'true';
			-- Notify that defragging is being stopped.
			RAISERROR('Notice: Defragging stopped due to a time limit imposed on this run.'
				,1 ,1);
			BREAK;
		END

		-- PRINT 'Executing: ' + @r_defragCommand			-- For Debugging

		----------------
		-- By just capturing an @@ERROR code you cannot always get a clear picture of why an error occurred.
		--   We will run this EXEC in a try/catch block to capture any error message in all its detailed glory.
		--
		BEGIN TRY
			EXEC SP_EXECUTESQL @r_defragCommand				-- Run the index reorg/rebuild command.
			SET @r_Error = '0'
		END TRY
		BEGIN CATCH
			SET @r_Error = ERROR_MESSAGE()					-- Capture detailed error message.
		END CATCH

		SET @r_endTime = getdate()							-- Time defrag completed.
			
			
		----------------
		-- Set the status of this index defrag and update the post-defrag stats.
		--
		UPDATE dbo.IndexFragStats
		SET  defragStatus						= @r_Error
			,defrag_avg_fragmentation_pct		= s.avg_fragmentation_in_percent
			,defrag_fragment_count				= s.fragment_count
			,defrag_avg_frag_size_in_pages		= s.avg_fragment_size_in_pages
			,defrag_avg_page_space_used_pct		= s.avg_page_space_used_in_percent
			,defrag_page_count					= s.page_count
			,runDate							= getdate()
			,defragDurationSeconds				= datediff([second], @r_startTime, @r_endTime)
		--------
		FROM sys.dm_db_index_physical_stats(
			@r_db_id, @r_object_id, @r_index_id, @r_partition_number, 'SAMPLED') s
		where id = @r_id
			and s.alloc_unit_type_desc = 'IN_ROW_DATA'		-- Disregard overflow, LOB, etc. sub-index types.

		----------------
		-- Store the result of this index defrag into a history table.
		--
		insert dbo.IndexFragHist
		SELECT
			 [runDate]
			,[dbName]
			,[schemaName]
			,[objectName]
			,[indexName]
			,[index_type_desc]
			,[partition_number]
			,[partitionCount]
			,[db_id]
			,[object_id]
			,[index_id]

			,[is_disabled]
			,[allow_page_locks]
			,[objectLOBColumnCount]
			,[indexLOBColumnCount]
			,[fill_factor]
			,[record_count]

			,[avg_fragmentation_pct]
			,[fragment_count]
			,[avg_frag_size_in_pages]
			,[avg_page_space_used_pct]
			,[page_count]

			,[defrag_avg_fragmentation_pct]
			,[defrag_fragment_count]
			,[defrag_avg_frag_size_in_pages]
			,[defrag_avg_page_space_used_pct]
			,[defrag_page_count]

			,[defragRequired]	
			,[defragCommand]
			,[defragStatus]
			,[defragDurationSeconds]
			,[defragAcknowledged]

		from dbo.IndexFragStats
		WHERE id = @r_id

		IF @DefragOnly1 = 'true'							-- If @DefragOnly1 is enabled, run one index defrag
			BREAK;											--   and exit with this break.

	END -- Loop through the indexes/partitions.

	
	CLOSE cur_indexes;										-- Close and deallocate the cursor.
	DEALLOCATE cur_indexes;

END -- Defrag flagged indexes




------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Produce alert messages based on the status of the defrag tables.
--
IF @RunMode in ('Normal','Alert','All')
BEGIN -- Produce alert messages

	declare @Subject nvarchar(200) = '';
	declare @Body nvarchar(max) = '';
	declare @AlertHasErrors bit = 'false';

	----------------------------------------
	-- Build the Alert message
	--
	IF exists (														-- Get info on indexes that had
		select 1 FROM dbo.IndexFragHist								--   ERRORS when being defragged.
		where @AlertMode in ('Error', 'Both')
			and defragAcknowledged is null
			and defragStatus <> '0'
	)
	BEGIN
		set @Body = @Body 
			+ CHAR(0x0D) + CHAR(0x0A) + 'The following indexes produced ERRORS when being defragged:'
			+ CHAR(0x0D) + CHAR(0x0A) + '-----------------------------------------------------------'
			+ CHAR(0x0D) + CHAR(0x0A)
			+ CHAR(0x0D) + CHAR(0x0A)
		select @Body = @Body +
			(SELECT
				quotename(dbName) + '.' + quotename(schemaName) + '.' 
				+  quotename(objectName) + '.' +  quotename(indexName)
				+ CHAR(0x0D) + CHAR(0x0A) 
				+ '        Error Message:    ' + isnull(defragStatus,'')
				+ CHAR(0x0D) + CHAR(0x0A) --+ ' '
				+ CHAR(0x0D) + CHAR(0x0A)
			FROM dbo.IndexFragHist
			where defragAcknowledged is null
				and defragStatus <> '0'
			FOR XML PATH(''), TYPE
			).value('.','nvarchar(max)')

		If @AlertAcknowledge = 'true'
			UPDATE dbo.IndexFragHist
			SET defragAcknowledged = 'true'
			WHERE defragAcknowledged is null
				and defragStatus <> '0'

		SET @AlertHasErrors = 'true'
	END



	----------------
	IF exists (														-- Get info on indexes that were
		select 1 FROM msdb.dbo.IndexFragHist						--   defragged SUCCESSFULLY.
		where @AlertMode in ('Success', 'Both')
			and defragAcknowledged is null
			and defragStatus = '0'
	)
	BEGIN
		set @Body = @Body 
			+ CHAR(0x0D) + CHAR(0x0A) + 'The following indexes have been defragged successfully:'
			+ CHAR(0x0D) + CHAR(0x0A) + '-------------------------------------------------------'
			+ CHAR(0x0D) + CHAR(0x0A)
			+ CHAR(0x0D) + CHAR(0x0A)
		select @Body = @Body +
			(SELECT
				quotename(dbName) + '.' + quotename(schemaName) + '.' 
				+  quotename(objectName) + '.' +  quotename(indexName)
				+ CHAR(0x0D) + CHAR(0x0A) 
				+ '        Old Frag %:  ' 
				+ isnull(cast(cast(avg_fragmentation_pct as DECIMAL(5,2)) as char(5)),'') 
				+ '        Old Page Space Used %:  ' 
				+ isnull(cast(cast(avg_page_space_used_pct as DECIMAL(5,2)) as char(5)),'')
				+ CHAR(0x0D) + CHAR(0x0A) 
				+ '        New Frag %:  ' 
				+ isnull(cast(cast(defrag_avg_fragmentation_pct as DECIMAL(5,2)) as char(5)),'') 
				+ '        New Page Space Used %:  ' 
				+ isnull(cast(cast(defrag_avg_page_space_used_pct as DECIMAL(5,2)) as char(5)),'')
				+ CHAR(0x0D) + CHAR(0x0A) --+ ' '
				+ CHAR(0x0D) + CHAR(0x0A)
			FROM msdb.dbo.IndexFragHist
			where defragAcknowledged is null
				and defragStatus = '0'
			FOR XML PATH(''), TYPE
			).value('.','nvarchar(max)')

		If @AlertAcknowledge = 'true'
			UPDATE dbo.IndexFragHist
			SET defragAcknowledged = 'true'
			WHERE defragAcknowledged is null
				and defragStatus = '0'
	END



	----------------
	IF exists (														-- Get info on index CANDIDATES that
		select 1 FROM msdb.dbo.IndexFragStats						--   should potentially be defragged.
		where @AlertMode = 'Candidate'
			and defragAcknowledged is null
			and defragStatus is null
			and defragRequired is not null
			and defragRequired <> 'S'
	)
	BEGIN
		set @Body = @Body 
			+ CHAR(0x0D) + CHAR(0x0A) + 'The following indexes should be defragged:'
			+ CHAR(0x0D) + CHAR(0x0A) + '------------------------------------------'
			+ CHAR(0x0D) + CHAR(0x0A)
			+ CHAR(0x0D) + CHAR(0x0A)
		select @Body = @Body +
			(SELECT
				quotename(dbName) + '.' + quotename(schemaName) + '.' 
				+  quotename(objectName) + '.' +  quotename(indexName)
				+ case when partitionCount > 1 
					then '  Partition: ' + cast(partition_number as char(4)) else '' end
				+ CHAR(0x0D) + CHAR(0x0A) 
				+ '        Frag %:  ' 
				+ isnull(cast(cast(avg_fragmentation_pct as DECIMAL(5,2)) as char(5)),'') 
				+ '        Page Space Used %:  ' 
				+ isnull(cast(cast(avg_page_space_used_pct as DECIMAL(5,2)) as char(5)),'')
				+ '        Record Count:  ' 
				+ isnull(cast(record_count as char(12)),'') 
				+ '        Page Count:  ' 
				+ isnull(cast(page_count as char(12)),'')
				+ CHAR(0x0D) + CHAR(0x0A) --+ ' '
				+ CHAR(0x0D) + CHAR(0x0A)
			FROM msdb.dbo.IndexFragStats
			where defragAcknowledged is null
				and defragStatus is null
				and defragRequired is not null
				and defragRequired <> 'S'
			FOR XML PATH(''), TYPE
			).value('.','nvarchar(max)')

		If @AlertAcknowledge = 'true'
			UPDATE dbo.IndexFragStats
			SET defragAcknowledged = 'true'
			WHERE defragAcknowledged is null
				and defragStatus is null
				and defragRequired is not null
				and defragRequired <> 'S'
	END




	----------------------------------------
	-- Display and email the Alert message
	--
	if @AlertMode <> 'None'
	BEGIN

		SET @Subject = @@SERVERNAME + ' Alert:  '					-- Build the alert Subject.
		+ 'Index Defrag completed'
		+ case when @AlertHasErrors = 'true' 
			then ' --ERRORS-- Encountered ' else '' end

		SET @Body = @Subject 
			+ CHAR(0x0D) + CHAR(0x0A) 
			+ CHAR(0x0D) + CHAR(0x0A) 
			+ case when @SPTimeExceeded = 'true'
				then 'Notice:  Not all indexes were defragged due to a time limit imposed on this run.'
					+ CHAR(0x0D) + CHAR(0x0A) 
					+ CHAR(0x0D) + CHAR(0x0A) 
				else '' end
			+ @Body;

		-- Note: By default the max number of characters that will display in SSMS per column is 256,
		--   which may make this message look like it is being cut off.  To make sure you can see
		--   the entire message in SSMS, go into the Query menu > Query Options > Results > Text 
		--   and change the Maximum from 256 to something larger.
		--
		select @Body												-- Display the alert.

		if @AlertEmailRecipients is not null						-- Email the alert if recipients exist.
			and @AlertEmailRecipients <> ''
		BEGIN
			DECLARE @AlertImportance varchar(6) =					-- Set a High email importance if there
				case when @AlertHasErrors = 'true'					--    were errors defragging indexes.
					then 'High' else 'Normal' end;

			EXEC msdb.dbo.sp_send_dbmail
				 @recipients = @AlertEmailRecipients
				,@subject = @subject
				,@body = @Body
				,@importance = @AlertImportance
				,@profile_name = @AlertEmailProfile

		END

	END


END -- Produce alert messages


END -- Stored Procedure


