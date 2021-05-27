SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[sp_Update_StorageStats_Database]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[sp_Update_StorageStats_Database] AS' 
END
GO

/*
	--POPULATES THE STORAGE STATS FOR A SPECIFIC DATABASE
	DECLARE @BatchID INT = 1
	EXEC [dba].sp_Update_StorageStats_Database @BatchID
*/
ALTER   PROCEDURE [dba].[sp_Update_StorageStats_Database]
	@BatchID INT
AS
BEGIN
	
	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('[dba].StorageStats_Database', 'U') IS NULL
	BEGIN 
		CREATE TABLE [dba].[StorageStats_Database](
			[StorageStats_Database_ID] [int] NULL,
			[BatchID] [int] NULL,
			[database_id] [int] NOT NULL,
			[size_database] [int] NULL,
			[state] [tinyint] NULL,
			[state_desc] [nvarchar](60) NULL,
			[recovery_model] [tinyint] NULL,
			[recovery_model_desc] [nvarchar](60) NULL,
			[is_auto_create_stats_on] [bit] NULL,
			[is_auto_update_stats_on] [bit] NULL,
			[is_auto_shrink_on] [bit] NULL,
			[is_ansi_padding_on] [bit] NULL,
			[is_fulltext_enabled] [bit] NULL,
			[is_query_store_on] [bit] NULL,
			[is_temporal_history_retention_enabled] [bit] NULL,
			[SqlServerInstanceName] nvarchar(128) NULL,
			[MachineName]  nvarchar(128) NULL,
			[CreatedDT] [datetime2](7) NULL,
		)

	END
	

	INSERT INTO
		[dba].StorageStats_Database
	(
      	[BatchID]
      ,	[database_id]
      ,	[size_database]
      ,	[state]
      ,	[state_desc]
      ,	[recovery_model]
      ,	[recovery_model_desc]
      ,	[is_auto_create_stats_on]
      ,	[is_auto_update_stats_on]
      ,	[is_auto_shrink_on]
      ,	[is_ansi_padding_on]
      ,	[is_fulltext_enabled]
      ,	[is_query_store_on]
      ,	[is_temporal_history_retention_enabled]
	  , [SqlServerInstanceName]
	  , [MachineName]
      ,	[CreatedDT]
	)
	SELECT 
		@BatchID AS BatchID
	,	d.database_id AS database_id
	,	SUM(m.size) AS size_bytes
	,	d.state
	,	d.state_desc
	,	d.recovery_model
	,	d.recovery_model_desc
	,	d.is_auto_create_stats_on
	,	d.is_auto_update_stats_on
	,	d.is_auto_shrink_on
	,	d.is_ansi_padding_on
	,	d.is_fulltext_enabled
	,	d.is_query_store_on
	,	d.is_temporal_history_retention_enabled
	,	CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) AS SqlServerInstanceName
	,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS MachineName
	,	GETDATE() AS CreatedDT
	FROM 
		sys.databases AS d
	INNER JOIN 
		sys.master_files AS m
	ON 
		m.database_id = d.database_id 
	GROUP BY 
		d.database_id
	,	d.state
	,	d.state_desc
	,	d.recovery_model
	,	d.recovery_model_desc
	,	is_auto_create_stats_on
	,	is_auto_update_stats_on
	,	is_auto_shrink_on
	,	is_ansi_padding_on
	,	is_fulltext_enabled
	,	is_query_store_on
	,	is_temporal_history_retention_enabled

	END

GO
