SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Object_Database]'))
EXEC dbo.sp_executesql @statement = N'


CREATE   VIEW [meta].[Object_Database]
AS
	SELECT 
		[DatabaseId]				= [db].[database_id]
	  , [DatabaseName]				= [db].[name]
	  , [ObjectId]					= CONVERT(BIGINT, NULL)
	  , [PhysicalDatabaseName]		= [db].[physical_database_name]
	  , [CompatibilityLevel]		= [db].[compatibility_level]
	  , [DatabaseCollation]			= [db].[collation_name]
	  , [CatalogCollation]			= IIF([db].[catalog_collation_type_desc] = ''DATABASE_DEFAULT'', [db].[collation_name], [db].[catalog_collation_type_desc])
	  , [DatabaseState]				= [db].[state_desc]
	  , [RecoveryModel]				= [db].[recovery_model_desc]
	  , [StatisticsSummary]			= CASE
										  WHEN [db].[is_auto_create_stats_incremental_on] = 1
											  THEN ''STATS AUTO CREATE'' + IIF([db].[is_auto_update_stats_on] = 1, ''&UPDATE'', '''')
										  WHEN [db].[is_auto_create_stats_on] = 1
											  THEN ''STATS AUTO CREATE'' + IIF([db].[is_auto_update_stats_on] = 1, ''&UPDATE'', '''')
										  ELSE ''NO STATS CREATE'' + IIF([db].[is_auto_update_stats_on] = 1, ''BUT AUTO UPDATE'', '''')
									  END
	  , [DelayedDuribilityState]	= [db].[delayed_durability_desc]
	  , [LogReuseWaitState]			= [db].[log_reuse_wait_desc]
	  , [IsSystemDatabase]			= IIF([db].[name] IN (''master'', ''model'', ''tempdb'', ''msdb''), 1, 0)
	  , [IsTrustWorthy]				= [db].[is_trustworthy_on]
	  , [IsCdCEnabled]				= [db].[is_cdc_enabled]
	  , [DatabaseOptionEnable]		= ''|'' 
											+ IIF([db].[is_ansi_nulls_on] = 1, ''ANSI NULL|'', '''')
											+ IIF([db].[is_ansi_padding_on] = 1, ''ANSI PAD|'', '''') 
											+ IIF([db].[is_ansi_warnings_on] = 1, ''ANSI WARN|'', '''') 
											+ IIF([db].[is_concat_null_yields_null_on] = 1, ''CONCAT NULL|'', '''') 
											+ IIF([db].[is_quoted_identifier_on] = 1, ''QUOTEIDENTIFIER|'', '''') 
											+ IIF([db].[is_fulltext_enabled] = 1, ''FULLTEXT|'', '''') 
											+ IIF([db].[is_query_store_on] = 1, ''QUERYSTORE|'', '''')
	  ,	[ObjectType]		= ''DB''
	  ,	[ObjectClass]		= ''COL''
	  , [CreatedDT] = [db].[create_date]
	FROM 
		[sys].[databases] AS [db];

' 
GO
