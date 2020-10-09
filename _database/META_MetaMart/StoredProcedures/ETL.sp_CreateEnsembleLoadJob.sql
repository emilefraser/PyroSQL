SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
SELECT * FROM DC.[Database]

DECLARE @HubID INT
DECLARE ensemble_cursor CURSOR FOR   
    SELECT h.HubID
    FROM DMOD.Hub AS h
	WHERE h.IsActive = 1
	ORDER BY HubID ASC
  
    OPEN ensemble_cursor  
    FETCH NEXT FROM ensemble_cursor INTO @HubID  
  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
  
       EXEC [ETL].[sp_CreateEnsembleLoadJob] 12, @HubID

	    FETCH NEXT FROM ensemble_cursor INTO @HubID  
	  END
    CLOSE ensemble_cursor  
    DEALLOCATE ensemble_cursor 
*/
/*
DECLARE @DatabaseID int = 9
DECLARE @HubID int = 32
DECLARE @IsInitiallLoad bit = 0
DECLARE @IsTest bit = 0

EXEC [ETL].[sp_CreateEnsembleLoadJob] @DatabaseID, @HubID, @IsInitiallLoad, @IsTest

*/

CREATE PROCEDURE [ETL].[sp_CreateEnsembleLoadJob] 
	(@DatabaseID int
	, @HubID int
	, @IsInitiallLoad bit = 0
	, @IsTest bit = 0
	)
AS
/*
SELECT * FROM DMOD.Hub
SELECT * FROM DC.[Database]



DECLARE
	  @DatabaseID int
	, @HubID int
	, @IsInitiallLoad bit
	, @IsTest bit

SET @DatabaseID = 12
SET @HubID = 1018
SET @IsInitiallLoad = 0
SET	@IsTest = 0
*/

--SELECT All the vault and stage entities related to the selected hub to determine what to load

DROP TABLE IF EXISTS #LoadEntities

CREATE TABLE #LoadEntities (
	RowNo int NOT NULL
	, StageDatabaseName varchar(500) NOT NULL
	, StageSchemaName varchar(500) NOT NULL
	, StageTableName varchar(500) NOT NULL
	, StageTableEntityID int NOT NULL
	, VaultDatabaseName varchar(500) NOT NULL
	, VaultSchemaName varchar(500) NOT NULL
	, VaultTableName varchar(500) NOT NULL
	, VaultTableEntityID int NOT NULL
	, VaultTableType varchar(500) NOT NULL
	, BusinessEntity varchar(500) NOT NULL
	)

INSERT INTO #LoadEntities
SELECT DISTINCT
	ROW_NUMBER() OVER(ORDER BY SUBSTRING(VaultTableName, 1, CHARINDEX('_', VaultTableName) - 1), StageTableName, VaultTableName ASC) AS RowNo
	, StageDatabaseName
	, StageSchemaName
	, StageTableName
	, StageTableEntityID
	, VaultDatabaseName 
	, VaultSchemaName
	, VaultTableName 
	, VaultTableEntityID
	, SUBSTRING(VaultTableName, 1, CHARINDEX('_', VaultTableName) - 1) AS VaultTableType
	, CASE
		WHEN SUBSTRING(VaultTableName, 1, CHARINDEX('_', VaultTableName) - 1) = 'LINK' THEN SUBSTRING(VaultTableName, 6, 1000)
		WHEN SUBSTRING(VaultTableName, 1, CHARINDEX('_', VaultTableName) - 1) = 'HUB' THEN SUBSTRING(VaultTableName, 5, 1000)
		WHEN LEN(VaultTableName) - LEN(REPLACE(VaultTableName, '_', '')) >= 2 THEN SUBSTRING(VaultTableName, CHARINDEX('_', VaultTableName) + 1, CHARINDEX('_', VaultTableName, CHARINDEX('_', VaultTableName) + 1) - CHARINDEX('_', VaultTableName) - 1)
		ELSE SUBSTRING(VaultTableName, 1, CHARINDEX('_',VaultTableName)-1)
	  END AS BusinessEntity
FROM
	(
	SELECT DISTINCT
		vdb.DatabaseName AS VaultDatabaseName
		, vsc.SchemaName AS VaultSchemaName
		, vde.DataEntityName AS VaultTableName
		, vde.DataEntityID AS VaultTableEntityID
		--, vrc.TBLRowCount AS VaultRowCount
		, sdb.DatabaseName AS StageDatabaseName
		, ssc.SchemaName AS StageSchemaName
		, sde.DataEntityName AS StageTableName
		, sde.DataEntityID AS StageTableEntityID
		--, src.TBLRowCount AS StageRowCount
		--, odsdb.DatabaseName AS ODSDatabaseName
		--, odssc.SchemaName AS ODSSchemaName
		--, odsde.DataEntityName AS ODSTableName
		--, odsrc.TBLRowCount AS ODSRowCount
	FROM
		[DC].[Database] vdb
			INNER JOIN [DC].[Schema] vsc				ON vdb.DatabaseID = vsc.DatabaseID
			INNER JOIN [DC].[DataEntity] vde			ON vsc.SchemaID  = vde.SchemaID
			--INNER JOIN [DC].vw_rpt_TableRowcounts vrc	ON vdb.DatabaseName = vrc.DatabaseName AND vsc.SchemaName = vrc.SchemaName AND vde.DataEntityName = vrc.[name]
			INNER JOIN [DC].[Field] vf					ON vde.DataEntityID = vf.DataEntityID 
			INNER JOIN [DC].[FieldRelation] vfr			ON vf.FieldID = vfr.TargetFieldID
			INNER JOIN [DC].[Field] sf					ON vfr.SourceFieldID = sf.FieldID
			INNER JOIN [DC].[DataEntity] sde			ON sf.DataEntityID = sde.DataEntityID
			INNER JOIN [DC].[Schema] ssc				ON sde.SchemaID = ssc.SchemaID
			INNER JOIN [DC].[Database] sdb				ON ssc.DatabaseID = sdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts src	ON sdb.DatabaseName = src.DatabaseName AND ssc.SchemaName = src.SchemaName AND sde.DataEntityName = src.[name]
			--INNER JOIN [DC].[FieldRelation] sfr			ON sf.FieldID = sfr.TargetFieldID
			--INNER JOIN [DC].[Field] odsf				ON sfr.SourceFieldID = odsf.FieldID
			--INNER JOIN [DC].[DataEntity] odsde			ON odsf.DataEntityID = odsde.DataEntityID
			--INNER JOIN [DC].[Schema] odssc				ON odsde.SchemaID = odssc.SchemaID
			--INNER JOIN [DC].[Database] odsdb			ON odssc.DatabaseID = odsdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts odsrc	ON odsdb.DatabaseName = odsrc.DatabaseName AND odssc.SchemaName = odsrc.SchemaName AND odsde.DataEntityName = odsrc.[name]
	WHERE
		vde.DataEntityName = (SELECT HubName FROM DMOD.Hub WHERE HubID = @HubID)
		AND vsc.DatabaseID = @DatabaseID

	UNION ALL

	SELECT DISTINCT
		vdb.DatabaseName AS VaultDatabaseName
		, vsc.SchemaName AS VaultSchemaName
		, vde.DataEntityName AS VaultTableName
		, vde.DataEntityID AS VaultTableEntityID
		--, vrc.TBLRowCount AS VaultRowCount
		, sdb.DatabaseName AS StageDatabaseName
		, ssc.SchemaName AS StageSchemaName
		, sde.DataEntityName AS StageTableName
		, sde.DataEntityID AS StageTableEntityID
		--, src.TBLRowCount AS StageRowCount
		--, odsdb.DatabaseName AS ODSDatabaseName
		--, odssc.SchemaName AS ODSSchemaName
		--, odsde.DataEntityName AS ODSTableName
		--, odsrc.TBLRowCount AS ODSRowCount
	FROM
		[DC].[Database] vdb
			INNER JOIN [DC].[Schema] vsc				ON vdb.DatabaseID = vsc.DatabaseID
			INNER JOIN [DC].[DataEntity] vde			ON vsc.SchemaID  = vde.SchemaID
			--INNER JOIN [DC].vw_rpt_TableRowcounts vrc	ON vdb.DatabaseName = vrc.DatabaseName AND vsc.SchemaName = vrc.SchemaName AND vde.DataEntityName = vrc.[name]
			INNER JOIN [DC].[Field] vf					ON vde.DataEntityID = vf.DataEntityID 
			INNER JOIN [DC].[FieldRelation] vfr			ON vf.FieldID = vfr.TargetFieldID
			INNER JOIN [DC].[Field] sf					ON vfr.SourceFieldID = sf.FieldID
			INNER JOIN [DC].[DataEntity] sde			ON sf.DataEntityID = sde.DataEntityID
			INNER JOIN [DC].[Schema] ssc				ON sde.SchemaID = ssc.SchemaID
			INNER JOIN [DC].[Database] sdb				ON ssc.DatabaseID = sdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts src	ON sdb.DatabaseName = src.DatabaseName AND ssc.SchemaName = src.SchemaName AND sde.DataEntityName = src.[name]
			--INNER JOIN [DC].[FieldRelation] sfr			ON sf.FieldID = sfr.TargetFieldID
			--INNER JOIN [DC].[Field] odsf				ON sfr.SourceFieldID = odsf.FieldID
			--INNER JOIN [DC].[DataEntity] odsde			ON odsf.DataEntityID = odsde.DataEntityID
			--INNER JOIN [DC].[Schema] odssc				ON odsde.SchemaID = odssc.SchemaID
			--INNER JOIN [DC].[Database] odsdb			ON odssc.DatabaseID = odsdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts odsrc	ON odsdb.DatabaseName = odsrc.DatabaseName AND odssc.SchemaName = odsrc.SchemaName AND odsde.DataEntityName = odsrc.[name]
	WHERE
		vde.DataEntityName IN (SELECT SatelliteName FROM DMOD.Satellite WHERE HubID = @HubID)
		AND vsc.DatabaseID = @DatabaseID

	UNION ALL

	SELECT DISTINCT
		vdb.DatabaseName AS VaultDatabaseName
		, vsc.SchemaName AS VaultSchemaName
		, vde.DataEntityName AS VaultTableName
		, vde.DataEntityID AS VaultTableEntityID
		--, vrc.TBLRowCount AS VaultRowCount
		, sdb.DatabaseName AS StageDatabaseName
		, ssc.SchemaName AS StageSchemaName
		, sde.DataEntityName AS StageTableName
		, sde.DataEntityID AS StageTableEntityID
		--, src.TBLRowCount AS StageRowCount
		--, odsdb.DatabaseName AS ODSDatabaseName
		--, odssc.SchemaName AS ODSSchemaName
		--, odsde.DataEntityName AS ODSTableName
		--, odsrc.TBLRowCount AS ODSRowCount
	FROM
		[DC].[Database] vdb
			INNER JOIN [DC].[Schema] vsc				ON vdb.DatabaseID = vsc.DatabaseID
			INNER JOIN [DC].[DataEntity] vde			ON vsc.SchemaID  = vde.SchemaID
			--INNER JOIN [DC].vw_rpt_TableRowcounts vrc	ON vdb.DatabaseName = vrc.DatabaseName AND vsc.SchemaName = vrc.SchemaName AND vde.DataEntityName = vrc.[name]
			INNER JOIN [DC].[Field] vf					ON vde.DataEntityID = vf.DataEntityID 
			INNER JOIN [DC].[FieldRelation] vfr			ON vf.FieldID = vfr.TargetFieldID
			INNER JOIN [DC].[Field] sf					ON vfr.SourceFieldID = sf.FieldID
			INNER JOIN [DC].[DataEntity] sde			ON sf.DataEntityID = sde.DataEntityID
			INNER JOIN [DC].[Schema] ssc				ON sde.SchemaID = ssc.SchemaID
			INNER JOIN [DC].[Database] sdb				ON ssc.DatabaseID = sdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts src	ON sdb.DatabaseName = src.DatabaseName AND ssc.SchemaName = src.SchemaName AND sde.DataEntityName = src.[name]
			--INNER JOIN [DC].[FieldRelation] sfr			ON sf.FieldID = sfr.TargetFieldID
			--INNER JOIN [DC].[Field] odsf				ON sfr.SourceFieldID = odsf.FieldID
			--INNER JOIN [DC].[DataEntity] odsde			ON odsf.DataEntityID = odsde.DataEntityID
			--INNER JOIN [DC].[Schema] odssc				ON odsde.SchemaID = odssc.SchemaID
			--INNER JOIN [DC].[Database] odsdb			ON odssc.DatabaseID = odsdb.DatabaseID 
			--INNER JOIN [DC].vw_rpt_TableRowcounts odsrc	ON odsdb.DatabaseName = odsrc.DatabaseName AND odssc.SchemaName = odsrc.SchemaName AND odsde.DataEntityName = odsrc.[name]
	WHERE
		vde.DataEntityName IN (SELECT LinkName FROM DMOD.PKFKLink WHERE ChildHubID = @HubID)
		AND vsc.DatabaseID = @DatabaseID
	) RelatedEntities
	WHERE 
		StageSchemaName <> 'EMS'
	
	SELECT * FROM #LoadEntities


-- Build List of Stage Loads to run


DECLARE
	@EntityCount int = 1, @EntityNo int = 0
	, @sql nvarchar(max), @EnsembleSQL nvarchar(max)


DROP TABLE IF EXISTS #StageLoadProcs

CREATE TABLE #StageLoadProcs (
	ProcID int identity(1,1) NOT NULL
	, LoadProcName varchar(max) NOT NULL
	)

SELECT
	@EntityCount = COUNT(1)
FROM
	#LoadEntities 

WHILE @EntityNo < @EntityCount
BEGIN

	SET @EntityNo = @EntityNo + 1
	
	SELECT
		@sql = CONVERT(nvarchar(max), N'INSERT INTO #StageLoadProcs (LoadProcName) SELECT sc.[name] + ''.'' + pr.[name] from [' + tle.StageDatabaseName + '].sys.procedures pr INNER JOIN [' + tle.StageDatabaseName + '].sys.schemas sc ON pr.schema_id = sc.schema_id  WHERE pr.[name] = '''
				+ 'sp_'	+ ltype.LoadTypeCode +'_' + DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(tle.StageTableEntityID) +'_' + tle.StageTableName + ''' AND sc.[name] = '''
				+ DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(tle.StageTableEntityID) + ''' AND NOT EXISTS (SELECT 1 FROM #StageLoadProcs WHERE LoadProcName = '''
				+ DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(tle.StageTableEntityID) + '.sp_' + ltype.LoadTypeCode +'_' + DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(tle.StageTableEntityID) +'_' + tle.StageTableName  + ''')')
		--, ltype.LoadTypeCode
		--, tle.StageTableName
	FROM
		DMOD.LoadConfig lconfig
			INNER JOIN DMOD.LoadType ltype	ON lconfig.LoadTypeID = ltype.LoadTypeID
			LEFT JOIN #LoadEntities tle	ON lconfig.TargetDataEntityID = tle.StageTableEntityID
	WHERE
		tle.RowNo = @EntityNo
	


	--SELECT @sql

	EXEC sp_executesql @sql

END


-- Build list of Vault Loads to run

DROP TABLE IF EXISTS #VaultLoadProcs

CREATE TABLE #VaultLoadProcs (
	ProcID int identity(1,1) NOT NULL
	, LoadProcName varchar(max) NOT NULL
	, ProcType varchar(10) NOT NULL
	)

SET @EntityNo = 0

SELECT
	@EntityCount = COUNT(1)
FROM
	#LoadEntities 

WHILE @EntityNo < @EntityCount
BEGIN

	SET @EntityNo = @EntityNo + 1

	
	SELECT
		@sql = CASE 
					WHEN VaultTableType = 'HUB' THEN N'INSERT INTO #VaultLoadProcs (LoadProcName, ProcType) SELECT s.[name] + ''.'' + pr.[name], ''HUB'' FROM [' + VaultDatabaseName + '].sys.procedures pr JOIN [' + VaultDatabaseName + '].sys.schemas s ON pr.[schema_id] = s.[schema_id] WHERE pr.[name] like ''sp_loadhub_%'' AND pr.[name] like ''%' + StageSchemaName  + '_' + BusinessEntity  + '%'' AND NOT EXISTS (SELECT 1 FROM #VaultLoadProcs WHERE LoadProcName = s.[name] + ''.'' + pr.[name])'
					WHEN VaultTableType = 'SAT' THEN N'INSERT INTO #VaultLoadProcs (LoadProcName, ProcType) SELECT s.[name] + ''.'' + pr.[name], ''SAT'' FROM [' + VaultDatabaseName + '].sys.procedures pr JOIN [' + VaultDatabaseName + '].sys.schemas s ON pr.[schema_id] = s.[schema_id] WHERE pr.[name] like ''sp_loadsat_%'' AND pr.[name] like ''%' + StageSchemaName  + '_' + BusinessEntity  + '%'' AND NOT EXISTS (SELECT 1 FROM #VaultLoadProcs WHERE LoadProcName = s.[name] + ''.'' + pr.[name])'
					WHEN VaultTableType = 'LINK' THEN N'INSERT INTO #VaultLoadProcs (LoadProcName, ProcType) SELECT s.[name] + ''.'' + pr.[name], ''LINK'' FROM [' + VaultDatabaseName + '].sys.procedures pr JOIN [' + VaultDatabaseName + '].sys.schemas s ON pr.[schema_id] = s.[schema_id] WHERE pr.[name] like ''sp_loadlink_%'' AND pr.[name] like ''%' + StageSchemaName  + '_' + BusinessEntity  + '%'' AND NOT EXISTS (SELECT 1 FROM #VaultLoadProcs WHERE LoadProcName = s.[name] + ''.'' + pr.[name])'
					ELSE N'SELECT 1'
				END
	FROM
		#LoadEntities
	WHERE
		RowNo = @EntityNo
	
	--SELECT @sql

	EXEC sp_executesql @sql

END


--Build Ensemble Script

SET @EnsembleSQL = 'DECLARE @Today datetime2(7) = GetDate() ' + CHAR(10) + CHAR(13)

-- Add Use for Stage Database
SET @EnsembleSQL = @EnsembleSQL + 'USE ' + (SELECT DISTINCT StageDatabaseName FROM #LoadEntities) +  + CHAR(10) + CHAR(13)

-- Include Stage Loads


SET @EntityNo = 0

SELECT
	@EntityCount = COUNT(1)
FROM
	#StageLoadProcs

WHILE @EntityNo < @EntityCount
BEGIN

	SET @EntityNo = @EntityNo + 1

	SELECT
		@sql = 'EXECUTE ' + LoadProcName + ' @Today, ' + CONVERT(varchar(1), @IsInitiallLoad) + ', ' + CONVERT(varchar(1), @IsTest) 
	FROM
		#StageLoadProcs
	WHERE
		ProcID = @EntityNo

	SET @EnsembleSQL = @EnsembleSQL + @sql  + CHAR(10) + CHAR(13)
	
END

-- Add Use for Vault Database
SET @EnsembleSQL = @EnsembleSQL + 'USE ' + (SELECT DISTINCT VaultDatabaseName FROM #LoadEntities) +  + CHAR(10) + CHAR(13)

-- Include Vault Loads


SET @EntityNo = 0

SELECT
	@EntityCount = COUNT(1)
FROM
	#VaultLoadProcs

WHILE @EntityNo < @EntityCount
BEGIN

	SET @EntityNo = @EntityNo + 1

	SELECT
		@sql = 'EXECUTE ' + LoadProcName + ' @Today, ' + CONVERT(varchar(1), @IsTest) 
	FROM
		#VaultLoadProcs
	WHERE
		ProcID = @EntityNo

	SET @EnsembleSQL = @EnsembleSQL + @sql  + CHAR(10) + CHAR(13)
	
END


DECLARE
	@JobName nvarchar(500)

SET @JobName = 'VaultLoad_' + (SELECT HubName FROM DMOD.Hub WHERE HubID = @HubID) 

--EXEC msdb..sp_delete_job @job_name = @JobName

EXEC msdb..sp_add_job @job_name = @JobName
EXEC msdb..sp_add_jobstep @job_name = @JobName, @step_name = N'Run Ensemble Load Script', @subsystem = N'TSQL', @command = @EnsembleSQL

SELECT @EnsembleSQL 

/*

--SELECT * FROM [DEV_StageArea].sys.procedures pr WHERE pr.[name] like 'sp_StageFullLoad_KEYS%'
--SELECT * FROM [DEV_DataVault].sys.procedures pr WHERE pr.[name] like 'sp_loadlink_%'
SELECT * FROM #LoadEntities
SELECT * FROM #StageLoadProcs
SELECT * FROM #VaultLoadProcs 

INSERT INTO #VaultLoadProcs (LoadProcName) SELECT pr.name FROM [DEV_DataVault].sys.procedures pr WHERE pr.[name] like 'sp_load_%' AND pr.[name] like '%LINK_Region_Customer%' AND NOT EXISTS (SELECT 1 FROM #StageLoadProcs WHERE LoadProcName = pr.[name])

SELECT
	*
	, CASE
		WHEN LEN(VaultTableName) - LEN(REPLACE(VaultTableName, '_', '')) >= 2 THEN SUBSTRING(VaultTableName, CHARINDEX('_', VaultTableName) + 1, CHARINDEX('_', VaultTableName, CHARINDEX('_', VaultTableName) + 1) - CHARINDEX('_', VaultTableName) - 1)
		ELSE SUBSTRING(VaultTableName, 1, CHARINDEX('_',VaultTableName)-1)
	  END AS BusinessEntity
FROM #LoadEntities

SELECT pr.name FROM [DEV_DataVault].sys.procedures pr WHERE pr.[name] like 'sp_loadsat_%' AND pr.[name] like '%D365_Customer%'
'sp_loadsat_D365_Customer_LVD'

'SAT_Customer_D365_LVD'


*/


GO
