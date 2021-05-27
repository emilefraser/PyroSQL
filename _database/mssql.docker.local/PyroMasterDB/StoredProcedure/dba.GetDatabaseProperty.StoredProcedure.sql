SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[GetDatabaseProperty]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[GetDatabaseProperty] AS' 
END
GO

ALTER   PROCEDURE [dba].[GetDatabaseProperty]
AS
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Collation' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'ComparisonStyle' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'ComparisonStyle') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Edition' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Edition') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAnsiNullDefault' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAnsiNullDefault') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAnsiNullsEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAnsiNullsEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAnsiPaddingEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAnsiPaddingEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAnsiWarningsEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAnsiWarningsEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsArithmeticAbortEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsArithmeticAbortEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAutoClose' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAutoClose') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAutoCreateStatistics' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAutoCreateStatistics') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAutoCreateStatisticsIncremental' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAutoCreateStatisticsIncremental') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAutoShrink' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAutoShrink') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsAutoUpdateStatistics' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsAutoUpdateStatistics') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsClone' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsClone') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsCloseCursorsOnCommitEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsCloseCursorsOnCommitEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsFulltextEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsFulltextEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsInStandBy' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsInStandBy') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsLocalCursorsDefault' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsLocalCursorsDefault') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsMemoryOptimizedElevateToSnapshotEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsMemoryOptimizedElevateToSnapshotEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsMergePublished' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsMergePublished') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsNullConcat' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsNullConcat') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsNumericRoundAbortEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsNumericRoundAbortEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsParameterizationForced' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsParameterizationForced') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsQuotedIdentifiersEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsQuotedIdentifiersEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsPublished' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsPublished') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsRecursiveTriggersEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsRecursiveTriggersEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsSubscribed' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsSubscribed') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsSyncWithBackup' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsSyncWithBackup') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsTornPageDetectionEnabled' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsTornPageDetectionEnabled') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsVerifiedClone' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsVerifiedClone') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'IsXTPSupported' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'IsXTPSupported') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'LastGoodCheckDbTime' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'LastGoodCheckDbTime') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'LCID' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'LCID') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'MaxSizeInBytes' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'MaxSizeInBytes') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Recovery' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Recovery') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'ServiceObjective' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'ServiceObjectiveId' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjectiveId') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'SQLSortOrder' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'SQLSortOrder') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Status' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Status') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Updateability' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'UserAccess' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'UserAccess') AS [PropertyValue]
	UNION ALL
	SELECT 
		DB_NAME() AS [DatabaseName]
	  , 'Version' AS [PropertyName]
	  , DATABASEPROPERTYEX(DB_NAME(), 'Version') AS [PropertyValue]
	UNION ALL 
	select 
		name AS [DatabaseName] 
	,	'TrustWorthy' AS [PropertyName]
	,	[PropertyValue] =
			case is_trustworthy_on
			when 1 then 'TrustWorthy'
			ELSE 'UnTrustWorthy'
			END
			from sys.databases 
			where database_id =  DB_ID()
GO
