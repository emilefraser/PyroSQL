SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON










--===============================================================================================================================
--Stored Proc Version Control
--===============================================================================================================================
/*

	Author:						| Francois Senekal2
	Stored Proc Create Date:	| 2019-01-21
	Stored Proc Last Modified:	| 2019-06-20
	Last Modified User:			| Frans Germishuizen
	Description:				| Creates staging tables in DC and auto-creates relationships to ODS DataEntity
								| The DC DataEntities get created based on the HubID
								| The HubID is used because you can then link to all the other DataVault objects (SAT, LINK etc.)
								| By doing this you will be able to determine what columns the KEYS and Velocity (SAT) tables need to have

								NOTES TO FRANS: Why is XT Hardcoded? There are additional keys coming from X3 people, specifically for Employee
								
*/

CREATE PROCEDURE [DMOD].[sp_CreateStageTableInVirtualDC] 
	@HubID INT
	--,@SourceSystemID INT --TODOD Remove(?) -Done. No longer used (can remove on review)
	,@TargetDatabaseID INT
AS

-- Test data generator and reset
/*
	-- Create a test server, database instance, database for StageArea
	--Server
	SET IDENTITY_INSERT DC.[Server] ON
	INSERT INTO [DC].[Server]
			   (ServerID,[ServerName],[ServerLocation],[PublicIP],[LocalIP],[UserID],[AccessInstructions],[CreatedDT],[UpdatedDT],[IsActive],[ServerTypeID])
		 VALUES
			   (999,'FransTestServer','','','','','','1900-01-01','1900-01-01',1,0)
	SET IDENTITY_INSERT DC.[Server] OFF

	--Database Instance
	SET IDENTITY_INSERT [DC].[DatabaseInstance] ON
	INSERT INTO [DC].[DatabaseInstance]
			   ([DatabaseInstanceID],[DatabaseInstanceName],[ServerID],[DatabaseAuthenticationTypeID],[AuthUsername],[AuthPassword],[IsDefaultInstance],[NetworkPort],[CreatedDT],[UpdatedDT],[IsActive])
		 VALUES
			   (999,'FransDatabaseInstanceTest',999,1,'','',1,'','1900-01-01','1900-01-01',1)

	SET IDENTITY_INSERT [DC].[DatabaseInstance] OFF

	--Database 
	SET IDENTITY_INSERT [DC].[Database] ON
	INSERT INTO [DC].[Database]
			   ([DatabaseID],[DatabaseName],[AccessInstructions],[Size],[DatabaseInstanceID],[SystemID],[ExternalDatasourceName],[DatabasePurposeID],[DBDatabaseID],[CreatedDT],[UpdatedDT],[IsActive],[LastSeenDT])
		 VALUES
			   (999, 'FransTestDB_Stage','',0,999,999,'',3,999,'1900-01-01','1900-01-01',1,'')

	SET IDENTITY_INSERT [DC].[Database] OFF

	select	*
	from	DC.[Server]
	where	ServerID = 999
		and ServerName = 'FransTestServer'

	select	*
	from	DC.[DatabaseInstance]
	where	DatabaseInstanceID = 999
		and DatabaseInstanceName = 'FransDatabaseInstanceTest'

	select	*
	from	DC.[Database]
	where	DatabaseID = 999
		and DatabaseName = 'FransTestDB_Stage'

	/*
		--Delete Master Test Data
		delete from DC.[Server]
		where	ServerID = 999
			and ServerName = 'FransTestServer'

		delete from DC.[DatabaseInstance]
		where	DatabaseInstanceID = 999
			and DatabaseInstanceName = 'FransDatabaseInstanceTest'

		delete from DC.[Database]
		where	DatabaseID = 999
			and DatabaseName = 'FransTestDB_Stage'

		-- Delete created test data
	--*/
--*/

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	---------------------------------------------------------------------------------------------------------------------------------
	--Testing variables (COMMENT OUT BEFORE ALTERING THE PROC)
	---------------------------------------------------------------------------------------------------------------------------------
	-- (If you uncomment this line the whole testing variable block will become active
		--DECLARE	@HubID INT
		----DECLARE @SourceSystemID INT --KD: Not required
		--DECLARE @TargetDatabaseID INT

		--SET		@HubID = 25
		----SET		@SourceSystemID = 1 --KD: Not required
		--SET		@TargetDatabaseID = 1003

	
	---------------------------------------------------------------------------------------------------------------------------------
	--Stored Proc Variables
	---------------------------------------------------------------------------------------------------------------------------------
	
/*
declare		@HubID INT
	set @HubID = 1015
declare @TargetDatabaseID INT
set @TargetDatabaseID = 2
*/
		DECLARE	 
				-- @SourceDataEntityID INT
				--,@SourceDataEntityName VARCHAR(50)
				--,@SourceSystemAbbrv varchar(50)
				@ODSDataEntityID int
				,@TargetSchemaID INT
				,@TargetSchemaName VARCHAR(20)
				,@TargetDatabasePurposeCode varchar(50)
				,@Hub_BKName varchar(100)
				,@SatDataEntityID int
				,@FieldRelationTypeID_STT INT = (SELECT [DC].[udf_get_FieldRelationTypeID]('STT')) --2

		SET		@TargetDatabasePurposeCode = (select DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
		
		--SET		@SourceDataEntityID =	(	
		--									SELECT	TOP 1 DataEntityID	  
		--									FROM	DMOD.Hub h 
		--										INNER JOIN DMOD.HubBusinessKey hbk ON hbk.HubID = h.HubID 
		--										INNER JOIN DMOD.HubBusinessKeyField hbkf ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
		--										INNER JOIN DC.vw_rpt_Databasefielddetail dbfd ON dbfd.fieldid = hbkf.fieldid 
		--									WHERE	h.hubid = @HubID
		--										AND dbfd.SystemID = @SourceSystemID
		--								)

		--SET		@SourceDataEntityName =	(
		--									SELECT	[DC].[udf_ConvertStringToCamelCase](DataEntityName) 
		--									FROM	DC.DataEntity 
		--									WHERE	DataEntityID = @SourceDataEntityID
		--								)

		--SET @TargetSchemaName =	(
		--							SELECT	sy.SystemAbbreviation
		--							FROM	DC.[Schema]  sc
		--								inner join DC.[Database] db on db.DatabaseID = sc.DatabaseID
		--								inner join DC.[System] sy on sy.SystemID = db.SystemID
		--							WHERE	sc.DatabaseID = 999
		--								and @TargetDatabasePurposeCode = 'Stage' -- Fail safe check
		--						)
	
		--SET @TargetSchemaID =	(
		--								SELECT	sc.SchemaID
		--								FROM	DC.[Schema]  sc
		--									inner join DC.[Database] db on db.DatabaseID = sc.DatabaseID
		--									--inner join DC.[System] sy on sy.SystemID = db.SystemID
		--								WHERE	sc.DatabaseID = @TargetDatabaseID
		--									and @TargetDatabasePurposeCode = 'Stage' -- Fail safe check
		--									and sc.SchemaName = @TargetSchemaName
		--							)
		-- Table Variables
		DROP TABLE IF EXISTS #SourceDataEntities
		CREATE TABLE #SourceDataEntities
		--DECLARE #SourceDataEntities TABLE
			(
				HubID int
				, HubName varchar(100)
				, Hub_BKName varchar(100)
				, Hub_BKFieldID int
				, SourceSystemID int
				, SourceSystemAbbrv varchar(50)
				, SourceDataEntityID int
				, SourceSchemaID int 
				, SourceSchemaName varchar(50)
			)
		
		INSERT INTO #SourceDataEntities --TODO - Field list
		   (HubID,
			HubName,
			Hub_BKName,
			Hub_BKFieldID,
			SourceSystemID,
			SourceSystemAbbrv,
			SourceDataEntityID,
			SourceSchemaID,
			SourceSchemaName)
		select	distinct h.HubID
				, HubName = h.HubName
				, Hub_BKName = hbk.BKFriendlyName
				, Hub_BKFieldID = hbkf.FieldID
				, [DC].[udf_GetSourceSystemIDForDataEntityID]((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))) as SourceSystemID 
				, ISNULL([DC].[udf_get_SourceSystemAbbrv_for_DataEntityID]((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)))
						, [DC].udf_GetSchemaNameForDataEntityID((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)))) as SourceSystemAbbrv
				, [DC].udf_get_DataEntityID_from_FieldID(hbkf.FieldID) as SourceDataEntityID
				, [DC].udf_GetSchemaIDForDataEntityID((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))) as SourceSchemaID
				, [DC].udf_GetSchemaNameForDataEntityID((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))) AS SourceSchemaName
				--, det.*
		from	DMOD.Hub h
			inner join DMOD.HubBusinessKey hbk on hbk.HubID = h.HubID
			inner join DMOD.HubBusinessKeyField hbkf on hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
			--inner join DC.vw_rpt_DatabaseFieldDetail det on det.DataEntityID = DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)
		where	h.HubID = @HubID
			    AND h.IsActive = 1
			    AND hbk.IsActive = 1
			    AND hbkf.IsActive = 1
		
		--SELECT * FROM #SourceDataEntities

		--drop table if exists #SourceDataEntities
		--Select	*
		--into	#SourceDataEntities
		--from	#SourceDataEntities
		
		--select	distinct DatabaseName, SchemaName, DataEntityID
		--from	DC.vw_rpt_DatabaseFieldDetail
		--where	DataEntityID IN (4741, 4905, 7944, 498)
	
	/*

	select	@HubID as HubID
			, @SourceSystemID AS SourceSystemID
			--, @SourceDataEntityID as InitialSourceDataEntityID
			--, @SourceDataEntityName as InitialSourceDataEntityName
			, @TargetDatabaseID as TargetDatabaseID
			, @TargetSchemaID as TargetSchemaID
			, @TargetSchemaName as TargetSchemaName
	
	select	*
	from	DMOD.Hub
	where	HubID = @HubID
	
	--*/

	/*

	select	distinct 
			ServerName
			, DatabaseInstanceID
			, DatabaseInstanceName
			, SystemID
			, SystemName
			, DatabaseID
			, DatabaseName
			, SchemaID
			, SchemaName
			, DataEntityID
			, DataEntityName
	from	DC.vw_rpt_DatabaseFieldDetail
	where	DatabaseID = @TargetDatabaseID
		and SchemaID = @TargetSchemaID
	order by DataEntityName
	
	*/

	---------------------------------------------------------------------------------------------------------------------------------
	--Log Variables
	---------------------------------------------------------------------------------------------------------------------------------
		--<Declare and set statements for variables used in the stored proc where the generic log functionality is used>
	
	--*/

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/



----====================================================================================================
----	Insert the SAT in TempTable (used downstream) -- all combinations of sat's that are modelled
----====================================================================================================

DROP TABLE IF EXISTS #StageDataEntity_Sat
CREATE TABLE #StageDataEntity_Sat
--DECLARE #StageDataEntity_Sat TABLE 
	    (
			HubID INT
			,Hub_BKName varchar(100)
			,Hub_BKFieldID INT
			,SatelliteDataVelocityTypeID INT
			,SourceDataEntityID INT
			,SourceDataEntityName VARCHAR(50)
			,SourceSystemAbbreviation VARCHAR(50)
			,SourceSchemaName varchar(50)
			,SatelliteDataEntityName VARCHAR(100)
			,SatDataEntityID INT
			,SatDataEntityID_Hist INT
			,SatelliteID INT
	     )

INSERT INTO #StageDataEntity_Sat
	    (HubID
		,Hub_BKName
		,Hub_BKFieldID
		,SatelliteDataVelocityTypeID
		,SourceDataEntityID
		,SourceDataEntityName
		,SourceSystemAbbreviation
		,SourceSchemaName
		,SatelliteDataEntityName
		,SatDataEntityID
		,SatelliteID
	     )
select	DISTINCT HubID = hub.HubID
		, Hub_BKName = hub.Hub_BKName
		, Hub_BKFieldID = hub.Hub_BKFieldID
		, SatelliteDataVelocityTypeID = sat.SatelliteDataVelocityTypeID
		, SourceDataEntityID = hub.SourceDataEntityID
		, SourceDataEntityName = [DC].[udf_ConvertStringToCamelCase]([DC].[udf_GetDataEntityNameForDataEntityID](hub.SourceDataEntityID)) 
		, SourceSystemAbbreviation = hub.SourceSystemAbbrv
		, SourceSchemaName = hub.SourceSchemaName
		, SatelliteDataEntityName = hub.SourceSchemaName + '_' + REPLACE(hub.HubName, 'HUB_', '') + '_' + hub.SourceSystemAbbrv + '_' + vtype.SatelliteDataVelocityTypeCode --TODO Standardise Prefix from Function
		, SatDataEntityID = sat.SatelliteDataEnityID
		, SatelliteID = sat.SatelliteID
FROM	
	(
		SELECT	distinct sat.SatelliteID
				, [DC].udf_get_DataEntityID_from_FieldID(satf.FieldID) AS Sat_SourceDataEntityID
				, sat.SatelliteDataEnityID
				, sat.HubID
				, sat.SatelliteDataVelocityTypeID
				, satf.IsActive
		from	DMOD.Satellite sat 
			inner join DMOD.SatelliteField satf on sat.SatelliteID = satf.SatelliteID
		where	sat.HubID = @HubID
			AND satf.IsActive = 1
			    --AND sat.IsActive = 1 --TODO Uncomment when Sat has IsActive column
				--AND satf.IsActive = 1 --TODO Uncomment when Sat has IsActive column
	) sat
	INNER JOIN #SourceDataEntities hub ON hub.SourceDataEntityID = sat.Sat_SourceDataEntityID
	INNER JOIN DMOD.SatelliteDataVelocityType vtype ON vtype.SatelliteDataVelocityTypeID = sat.SatelliteDataVelocityTypeID
--WHERE	hub.HubID = @HubID

--SELECT * FROM #StageDataEntity_Sat

--=========================================================================================================================================================================
-- Insert the Target Schema in DC (if it does not exist) - the SAT db schema is equal to the source system abbreviation,
-- accoarding to the naming convention
--=========================================================================================================================================================================

--Create Cursor to create each schema and populate a temp table so that you can be certain to grab all the schemas that are inserted in this run of the proc
--DECLARE cursor_schemas CURSOR FOR   
	
	-- Create schemas (source system abbrv) that do not exist in DC.Schema
	INSERT INTO DMOD.[Schema]
	(
		SchemaName
		, DatabaseID
		, DBSchemaID
		, CreatedDT
	)
	select	DISTINCT SourceSystemAbbreviation
		    , @TargetDatabaseID
			, NULL
			, GETDATE()
	from	(SELECT DISTINCT SourceSystemAbbreviation FROM #StageDataEntity_Sat) sat
	where	SourceSystemAbbreviation NOT IN (
												select	de.SourceSystemAbbreviation
												from	(SELECT DISTINCT SourceSystemAbbreviation FROM #StageDataEntity_Sat) de
													left join DMOD.[Schema] sc on sc.SchemaName = de.SourceSystemAbbreviation           --WS DC TO DMOD
												where	sc.DatabaseID = @TargetDatabaseID
											);
  
--OPEN cursor_schemas  
  
--	FETCH NEXT FROM cursor_schemas   
--	INTO @TargetSchemaName 
  
--	WHILE @@FETCH_STATUS = 0  
--	BEGIN  
		
--		--Create new schemas in target DB that do not exist
--		INSERT INTO DC.[Schema]
--			(
--				SchemaName
--				, DatabaseID
--				, DBSchemaID
--				, CreatedDT
--			)
--		SELECT	@TargetSchemaName
--				, @TargetDatabaseID
--				, NULL
--				, GETDATE()

--		-- Get newly inserted SchemaID
--		SET @TargetSchemaID = @@IDENTITY

--		--KD: Don't need this
--		----Populate temp table for all new schemas created
--		--insert into #TargetSchemas (TargetSchemaID, TargetSchemaName)
--		--select	@TargetSchemaID, NULL

--		FETCH NEXT FROM cursor_schemas   
--			INTO @TargetSchemaName  
--	END --While
	
--CLOSE cursor_schemas;  
--DEALLOCATE cursor_schemas;  

--KD: Don't need this
-- Delete from the temp table because the schemas have now been inserted into DC.Schema, and reselect all the schemas for the current execution
--delete	
--from	#TargetSchemas

DROP TABLE IF EXISTS #TargetSchemas
CREATE TABLE #TargetSchemas
--DECLARE #TargetSchemas as TABLE
	(
		TargetSchemaID int
		, TargetSchemaName varchar(100)
	)

INSERT INTO #TargetSchemas
select	DISTINCT sc.SchemaID, sc.SchemaName
from	(SELECT DISTINCT SourceSystemAbbreviation FROM #StageDataEntity_Sat) de
	inner join DMOD.[Schema] sc on sc.SchemaName = de.SourceSystemAbbreviation
where	sc.DatabaseID = @TargetDatabaseID



--=========================================================================================================================================================================
-- Copy the structure of the Source Data Entity into DataEntity table in DC (if it does not exist)
--=========================================================================================================================================================================

-- Check if the Data Entity for the Satellites exists, otherwise insert	
INSERT INTO DMOD.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
		, [DataEntityTypeID]
		, [IsActive]
	)
SELECT	DISTINCT SatelliteDataEntityName
		, SchemaID = sc.TargetSchemaID
		, CreatedDT = GETDATE()
		, [DataEntityTypeID] = [DC].[udf_get_DataEntityTypeID]('STAGE')
		, IsActive = 1
FROM	(SELECT DISTINCT SatelliteDataEntityName, SourceSystemAbbreviation FROM #StageDataEntity_Sat) sat
	inner join #TargetSchemas sc on sc.TargetSchemaName = sat.SourceSystemAbbreviation
WHERE NOT EXISTS
	(
		SELECT	*
		FROM	(SELECT DISTINCT SatelliteDataEntityName FROM #StageDataEntity_Sat) sats
			INNER JOIN DMOD.DataEntity de ON sats.SatelliteDataEntityName = de.DataEntityName --WS
			INNER JOIN #TargetSchemas sc on sc.TargetSchemaID = de.SchemaID
		WHERE sat.SatelliteDataEntityName = SATS.SatelliteDataEntityName
	)
--WHERE	SatelliteDataEntityName NOT IN	(
--											SELECT	distinct SatelliteDataEntityName
--											FROM	(SELECT DISTINCT SatelliteDataEntityName FROM #StageDataEntity_Sat) sat
--												INNER JOIN DC.DataEntity de ON sat.SatelliteDataEntityName = de.DataEntityName
--												INNER JOIN #TargetSchemas sc on sc.TargetSchemaID = de.SchemaID
--										)


--No need to update Data Entity Name, because the above will insert a new Data Entity if the name changed.
--TODO KD We need a separate process to change the Data Entity Name (based on the DataEntityID stored in the DMOD structure)

--Create Hist versions of the Stage Sat tables
INSERT INTO DMOD.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
		, [DataEntityTypeID]
		, [IsActive]
	)
SELECT	DISTINCT SatelliteDataEntityName + '_Hist'
		, SchemaID = sc.TargetSchemaID
		, CreatedDT = GETDATE()
		, [DataEntityTypeID] = [DC].[udf_get_DataEntityTypeID]('STAGE')
		, IsActive = 1
FROM	(SELECT DISTINCT SatelliteDataEntityName, SourceSystemAbbreviation FROM #StageDataEntity_Sat) sat
	inner join #TargetSchemas sc on sc.TargetSchemaName = sat.SourceSystemAbbreviation
WHERE NOT EXISTS
	(
		SELECT	*
		FROM	(SELECT DISTINCT SatelliteDataEntityName FROM #StageDataEntity_Sat) sats
			INNER JOIN DMOD.DataEntity de ON sats.SatelliteDataEntityName + '_Hist' = de.DataEntityName
			INNER JOIN #TargetSchemas sc on sc.TargetSchemaID = de.SchemaID
		WHERE sat.SatelliteDataEntityName = SATS.SatelliteDataEntityName
	
	)

--=========================================================================================================================================================================
-- Copy the structure of the Source Data Entity into Fields table in DC (if it does not exist) and
-- insert the additional SAT Fields (if it does not exist) 
--=========================================================================================================================================================================
--Update the DataEntity of the sat that was created in the dc / exists in the DC
UPDATE	sat
SET		SatDataEntityID = de.DataEntityID,
	    SatDataEntityID_Hist = de_hist.DataEntityID
FROM	#StageDataEntity_Sat sat
	INNER JOIN DMOD.[Schema] s on s.DatabaseID = @TargetDatabaseID AND              --WS DC TO DMOD
								s.SchemaName = sat.SourceSystemAbbreviation
	INNER JOIN DMOD.DataEntity de ON de.SchemaID = s.SchemaID AND                          --WS DC TO DMOD
								   de.DataEntityName = sat.SatelliteDataEntityName
	INNER JOIN DMOD.DataEntity de_hist ON de_hist.SchemaID = s.SchemaID AND
									    de_hist.DataEntityName = sat.SatelliteDataEntityName + '_Hist'        ----WS DC TO DMOD

-- Temp table that will be used to facilicate the generation of each sat in the DC
DROP TABLE IF EXISTS #Fields
CREATE TABLE #Fields
--DECLARE #Fields TABLE
	(
		[SatFieldID] [int] NULL,
		[FieldOriginalID] [int] NOT NULL,
		[ODSFieldID] [int],
		[FieldName] [varchar](1000) NOT NULL,
		[FieldOriginalName] [varchar](100) NOT NULL,
		[FieldFriendlyName] [varchar](100) NULL,
		[DataType] [varchar](500) NULL,
		[MaxLength] [int] NULL,
		[Precision] [int] NULL,
		[Scale] [int] NULL,
		[DataEntityID] [int] NULL,
		[DataEntityID_Hist] [int] NULL,
		[CreatedDT] [datetime2](7) NULL,
		[IsActive] [bit] NULL,
		[FieldSortOrder] [int] NULL
	)

--Create Cursor to populate each satellite's fields because there might be a case where the business key name is different per system.
DECLARE cursor_fields CURSOR FOR   
	select	sat.SatDataEntityID, sat.Hub_BKName
	from	(SELECT DISTINCT SatDataEntityID, SourceSystemAbbreviation, Hub_BKName FROM #StageDataEntity_Sat) sat
	where	SourceSystemAbbreviation IN (
											select	de.SourceSystemAbbreviation
											from	(SELECT DISTINCT SourceSystemAbbreviation FROM #StageDataEntity_Sat) de
												inner join DC.[Schema] sc on sc.SchemaName = de.SourceSystemAbbreviation
											where	sc.DatabaseID = @TargetDatabaseID
										);
  
OPEN cursor_fields  
  
	FETCH NEXT FROM cursor_fields   
	INTO @SatDataEntityID, @Hub_BKName 
  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		--Make sure the temp table is clean before loading the next sat
		delete	
		from	#Fields

		--Insert standard fields for sat's
		INSERT #Fields VALUES
			(NULL,0,NULL,'BKHash','BKHash','','varchar',40,0,0,-1, -1, GETDATE(), 1, 1),
			(NULL,0,NULL,'LoadDT','LoadDT','','datetime2',8,27,7,-1, -1, GETDATE(), 1, 2),
			(NULL,0,NULL,'RecSrcDataEntityID','RecSrcDataEntityID','','int',4,0,0,-1, -1, GETDATE(), 1, 3),
			(NULL,0,NULL,'HashDiff','HashDiff','','varchar',40,0,0,-1, -1, GETDATE(), 1, 4)

		--Create a copy of the standard fields for each Stage Satellite table
		INSERT INTO #Fields 
			(
				[SatFieldID]
				, [FieldOriginalID]
				--, [ODSFieldID]
				, [FieldName]
				, [FieldOriginalName]
				, [FieldFriendlyName]
				, [DataType]
				, [MAXLENGTH]
				, [Precision]
				, [Scale]
				, [DataEntityID]
				, [DataEntityID_Hist]
				, [CreatedDT]
				, [IsActive]
				, [FieldSortOrder]
			)
		SELECT  DISTINCT NULL
				, 0
				--, NULL
				, f.FieldName
				, f.FieldName AS FieldOriginalName
				, '' AS FieldFriendlyName
				, f.DataType
				, f.[MAXLENGTH]
				, f.[Precision]
				, f.[Scale]
				, sat.[SatDataEntityID]
				, sat.[SatDataEntityID_Hist]
				, GETDATE()
				, [IsActive]
				, [FieldSortOrder]			
		FROM #Fields f
			CROSS JOIN (SELECT DISTINCT [SatDataEntityID], [SatDataEntityID_Hist] FROM #StageDataEntity_Sat) sat
		--where	NOT EXISTS 
		--					(
		--						select	1
		--						from	DC.Field f1
		--						where	f.FieldName = f1.FieldName
		--							and f.DataEntityID = f1.DataEntityID
		--					)
		 WHERE SatDataEntityID = @SatDataEntityID

		UNION ALL

		SELECT	DISTINCT NULL
				, f.FieldID
				--, [ODSFieldID] = DC.udf_get_ODSFieldID_From_SourceFieldID(f.FieldID)
				, f.FieldName AS FieldName
				, f.FieldName as FieldOriginalName
				, NULL AS FieldFriendlyName
				, f.DataType
				, f.MAXLENGTH
				, f.PRECISION
				, f.Scale
				, sat.SatDataEntityID
				, sat.SatDataEntityID_Hist
				, GETDATE()
				, [IsActive] = 1
				, [FieldSortOrder] = ROW_NUMBER() OVER (PARTITION BY sat.[SatDataEntityID] ORDER BY ISNULL(f.FieldSortOrder , f.FieldName)) + 4
		FROM	(SELECT DISTINCT SatDataEntityID, [SatDataEntityID_Hist], satelliteid FROM #StageDataEntity_Sat) sat
			INNER JOIN [DMOD].[SatelliteField] satfield ON 
				sat.satelliteid = satfield.satelliteid 
			INNER JOIN DC.Field f ON 
				f.FieldID = satfield.FieldID
			WHERE satfield.IsActive = 1
		--WHERE NOT EXISTS (
		--					SELECT	1
		--					FROM	DC.Field f1
		--					WHERE	f1.FieldName = f.FieldName 
		--						AND sat.SatDataEntityID = f1.DataEntityID		  
		--				  )
		order by f.FieldSortOrder

		-- Remove standard fields only used to facilitate the cross join
		DELETE 
		FROM	#Fields
		WHERE	DataEntityID = -1
		
		--Create field list in the DC
		INSERT INTO DMOD.Field 
			(
				[FieldName]
				,[DataType]
				,[MAXLENGTH]
				,[Precision]
				,[Scale]
				,[DataEntityID]
				,[CreatedDT]
				,[IsActive]
				,[FieldSortOrder] 
			)
		SELECT	[FieldName] 
				, [DataType] 
				, [MaxLength]
				, [Precision]
				, [Scale] 
				, [DataEntityID] 
				, [CreatedDT] 
				, [IsActive] 
				, [FieldSortOrder]
		FROM	#Fields f
		WHERE NOT EXISTS (
							SELECT	1
							FROM	DMOD.FIELD f1
							WHERE	f1.FieldName = f.FieldName
								AND f.DataEntityID = f1.DataEntityID		  
						  )
		ORDER BY f.DataEntityID, f.FieldSortOrder

		--Create field list in the DC (for Hist table)
		INSERT INTO DMOD.Field 
			(
				[FieldName]
				,[DataType]
				,[MAXLENGTH]
				,[Precision]
				,[Scale]
				,[DataEntityID]
				,[CreatedDT]
				,[IsActive]
				,[FieldSortOrder] 
			)
		SELECT	[FieldName] 
				, [DataType] 
				, [MaxLength]
				, [Precision]
				, [Scale] 
				, [DataEntityID_Hist] 
				, [CreatedDT] 
				, [IsActive] 
				, [FieldSortOrder]
		FROM	#Fields f
		WHERE NOT EXISTS (
							SELECT	1
							FROM	DMOD.FIELD f1
							WHERE	f1.FieldName = f.FieldName
								AND f.[DataEntityID_Hist] = f1.DataEntityID		  
						  )
		ORDER BY f.[DataEntityID_Hist], f.FieldSortOrder

		-- Get the new field id of the satellite fields (the descriptive information fields)
		-- This does not get the DataVault added fields FieldID's (HK, LoadDT, LoadEndDT, RecSrcDataEntityID, HashDiff)
		UPDATE	#Fields
		SET		SatFieldID = f.FieldID
		FROM	DC.Field f
			INNER JOIN #Fields satf ON f.DataEntityID = satf.DataEntityID
				AND (
						f.FieldName = satf.FieldOriginalName
						OR 
						f.fieldname = satf.FieldFriendlyName
					)
			INNER JOIN (SELECT DISTINCT SatDataEntityID FROM #StageDataEntity_Sat) sat ON sat.SatDataEntityID = f.DataEntityID

		FETCH NEXT FROM cursor_fields   
			INTO @SatDataEntityID, @TargetSchemaName  
	END --While
	
CLOSE cursor_fields;  
DEALLOCATE cursor_fields;

-- If no new data entities were created or fields, grab all the fields from the #StageDataEntity_Sat table, because it will have the current or newly
-- created DataEntityID that will be used to update or create the FieldRelations from ODS to Stage
	
	--DECLARE #Fields_FieldRelations TABLE
	--	(
	--		SourceDataEntityID int
	--		, SourceFieldID int
	--		, ODSDataEntityID int
	--		, ODSFieldID int
	--		, StageDataEntityID int
	--		, StageFieldID int
	--	)

	--INSERT INTO #Fields_FieldRelations
	--	(
	--		SourceDataEntityID 
	--		, SourceFieldID 
	--		, ODSDataEntityID 
	--		, ODSFieldID 
	--		, StageDataEntityID 
	--		, StageFieldID
	--	)
	


--=========================================================================================================================================================================
-- Create or update the field relations for the sat's in this execution
--=========================================================================================================================================================================

drop table if exists #SourceODS_Fields

	select	f.FieldID
			, ODSFieldID = DC.udf_get_ODSFieldID_From_SourceFieldID(satf.FieldID)
			, sat.SatDataEntityID
	into	#SourceODS_Fields
	from	DC.Field f
		inner join DMOD.SatelliteField satf on satf.FieldID = f.FieldID
		inner join (SELECT DISTINCT SatelliteID, SatDataEntityID FROM #StageDataEntity_Sat) sat on sat.SatelliteID = satf.SatelliteID
    --where	satf.IsActive = 1 TODO - Uncomment once this table has an IsActive

--select	*
--from	#SourceODS_Fields

INSERT INTO DMOD.FieldRelation
	(
		SourceFieldID
		,TargetFieldID
		,FieldRelationTypeID
		,CreatedDT
	)
select	ODSFieldID
		, StageFieldID
		, @FieldRelationTypeID_STT
		, GETDATE()
from	
	(
		--Sat Fields
		select	
				--SourceDataEntityID = fsrc.DataEntityID
				--, SourceFieldID = fsrc.FieldID
				--, ODSDataEntityID = DC.udf_get_ODSDataEntityID_From_SourceDataEntityID(fsrc.DataEntityID)
				ODSFieldID = DC.udf_get_ODSFieldID_From_SourceFieldID(satf.FieldID) 
				--, StageDataEntityID = fstage.DataEntityID	
				, StageFieldID = fstage.FieldID 
		from	DMOD.SatelliteField satf
			inner join (SELECT DISTINCT SatelliteID, SatDataEntityID FROM #StageDataEntity_Sat) sat on sat.SatelliteID = satf.SatelliteID
			inner join DC.Field fsrc on fsrc.FieldID = satf.FieldID
			inner join DC.Field fstage on fstage.DataEntityID = sat.SatDataEntityID
				and fsrc.FieldName = fstage.FieldName

		union all

		--Map all hashdiff columns to ods columns in stage  -DONE
		select	ods.ODSFieldID
				, f.FieldID as StageFieldID
		from	DC.Field f
			inner join (SELECT DISTINCT SatDataEntityID FROM #StageDataEntity_Sat) sat on sat.SatDataEntityID = f.DataEntityID
			inner join #SourceODS_Fields ods on ods.SatDataEntityID = sat.SatDataEntityID
		where	FieldName IN (
								'HashDiff'
								)
	
		union all

		--Map all Hash Key columns from ODS to BKHash in stage
		select	DC.udf_get_ODSFieldID_From_SourceFieldID(sat.Hub_BKFieldID)
				,stage.FieldID AS StageFieldID
		from	(SELECT DISTINCT HubID, Hub_BKFieldID, SourceDataEntityID, SatDataEntityID FROM #StageDataEntity_Sat) sat
			--	DMOD.Hub h
			--inner join DMOD.HubBusinessKey hbk on hbk.HubID = h.HubID
			--inner join DMOD.HubBusinessKeyField hbkf  on hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
			--inner join  sat on sat.HubID = h.HubID
			--	and sat.SourceDataEntityID = DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)
			--	and sat.Hub_BKFieldID = hbkf.FieldID
			inner join 
						(
							select	DataEntityID, FieldID
							from	DC.Field f
								inner join (SELECT DISTINCT SatDataEntityID FROM #StageDataEntity_Sat) sat on sat.SatDataEntityID = f.DataEntityID
							where	f.FieldName = 'BKHash'
						) stage on stage.DataEntityID = sat.SatDataEntityID
	)FR
where	NOT EXISTS
					(
						select	1
						from	DC.FieldRelation fr1
						where	FR.ODSFieldID = fr1.SourceFieldID
							and FR.StageFieldID = fr1.TargetFieldID
							and fr1.FieldRelationTypeID = @FieldRelationTypeID_STT --2
					)



/*
 --Generate the STT mapping for the HashDiff columns for each DataEntityID
SELECT	[DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID) AS SourceFieldID
		, sat_hash.SatFieldID AS TargetFieldID
		, FieldRelationType = DC.udf_get_FieldRelationTypeID('STT') -- STT Mapping type hard coded
		, GETDATE()
FROM	
		   (
				SELECT	f.FieldID
						, sat.SatDataEntityID
				FROM	DC.Field f
					inner join #StageDataEntity_Sat sat on sat.SatDataEntityID = f.DataEntityID
				WHERE	FieldName = 'HashDiff'
		    ) sat_hash
	INNER JOIN 
		   (
				SELECT	f.FieldID
				FROM	DC.Field f
					inner join #StageDataEntity_Sat sat on sat.SatDataEntityID = f.DataEntityID
				WHERE	f.FieldName NOT IN	(
												'HashDiff',
												'LoadDT',
												'LoadEndDT',
												'BKHash',
												'RecSrcDataEntityID'
											)
			) sat_hashsource ON sat_hash.DataEntityID = sat_hashsource.DataEntityID
WHERE NOT EXISTS	(
						SELECT	1 
						FROM	DC.FieldRelation fr
							inner join DC.FieldRelationType frt on frt.FieldRelationTypeID = fr.FieldRelationTypeID
						WHERE	fr.SourceFieldID = [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID)
							AND fr.TargetFieldID = sat_hash.SatFieldID
							AND frt.FieldRelationTypeCode = 'STT' -- FieldRelationTypeCode = STT = Source-To-Target mapping type relation
					)




UNION ALL

SELECT	[DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID) AS SourceFieldID
		, sat_hashsource.SatFieldID AS TargetFieldID
		, FieldRelationType = DC.udf_get_FieldRelationTypeID('STT') -- STT Mapping type hard coded
		, GETDATE()
FROM	
		(
			SELECT	*
			FROM	#Fields
			WHERE	FieldOriginalID <> 0
		) sat_hashsource 
WHERE NOT EXISTS	(
						SELECT	1 
						FROM	DC.FieldRelation fr
							inner join DC.FieldRelationType frt on frt.FieldRelationTypeID = fr.FieldRelationTypeID
						WHERE	fr.SourceFieldID = [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](sat_hashsource.FieldOriginalID)
							AND fr.TargetFieldID = sat_hashsource.SatFieldID
							AND frt.FieldRelationTypeCode = 'STT' -- FieldRelationTypeCode = STT = Source-To-Target mapping type relation
					)
--UNION ALL

---- Generate the STT mapping for the HK columns for each DataEntityID
--SELECT	[DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](hub.SourceFieldID) AS SourceFieldID
--		, field.SatFieldID AS TargetFieldID
--		, 2 AS FieldRelationType -- STT Mapping type hard coded
--		,GETDATE()
--FROM	@StageDataEntity sat
--	INNER JOIN [DMOD].[HubBusinessKey] hub ON sat.HubID = hub.HubID
--	INNER JOIN #Fields field ON field.DataEntityID = sat.SatDataEntityID
--WHERE  NOT EXISTS	(
--						SELECT	1 
--						FROM	DC.FieldRelation fr
--						WHERE	fr.SourceFieldID = [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](hub.SourceFieldID)
--							AND fr.TargetFieldID = field.SatFieldID
--							AND fr.FieldRelationTypeID  = 2
--					)
--	AND	FieldName like 'HK%'
*/


--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************

--Stage KEYS Table
--***********************************************************************************************************/


--DECLARE	@HubID INT
--		DECLARE @SourceSystemID INT
--		DECLARE @TargetDatabaseID INT

--		SET		@HubID = 14
--		SET		@SourceSystemID = 1
--		SET		@TargetDatabaseID = 34

DECLARE @SourceSystemAbbrFromDataEntityID AS VARCHAR(50)
DECLARE @DataEntityIDFromFieldID INT

-- Table Variables
DROP TABLE IF EXISTS #SourceDataEntities_KEYS
CREATE TABLE #SourceDataEntities_KEYS
--DECLARE #SourceDataEntities_KEYS TABLE
	(
		HubID int
		, HubName varchar(100)		
		, SourceSystemID int
		, SourceSystemAbbrv varchar(50)
		, SourceDataEntityID int
		, SourceDataEntityName varchar(100)
		, SourceSchemaID int 
		, SourceSchemaName varchar(50)
		, Hub_BKFriendlyName varchar(100)
		, HubBKFieldID int
		, HubBKFieldName varchar(100)
	)

DECLARE cursor_SourceSystemAbbr CURSOR FOR

SELECT DISTINCT
 DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID) AS DataEntityIDFromFieldID
, [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID](DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)) AS SourceSystemAbbrvFromDataEntityID
from	dmod.hub h
	INNER JOIN DMOD.HubBusinessKey hbk ON hbk.HubID =  h.HubID
	INNER JOIN DMOD.HubBusinessKeyField hbkf ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
	INNER JOIN DC.Field bkfield ON bkfield.FieldID = hbkf.fieldid
where	h.HubID = @HubID
		and h.IsActive = 1
		and hbk.IsActive = 1
		and hbkf.IsActive = 1

OPEN cursor_SourceSystemAbbr
FETCH NEXT FROM cursor_SourceSystemAbbr
INTO @DataEntityIDFromFieldID, @SourceSystemAbbrFromDataEntityID

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #SourceDataEntities_KEYS
	select	distinct h.HubID
				, HubName =					h.HubName
				, SourceSystemID =			[DC].[udf_GetSourceSystemIDForDataEntityID](DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))
				, SourceSystemAbbrv =		[DC].[udf_get_SourceSystemAbbrv_for_DataEntityID](DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))
				, SourceDataEntityID =		[DC].udf_get_DataEntityID_from_FieldID(hbkf.FieldID)
				, SourceDataEntityName =	[DC].udf_GetDataEntityNameForDataEntityID([DC].udf_get_DataEntityID_from_FieldID(hbkf.FieldID)) 
				, SourceSchemaID =			[DC].udf_GetSchemaIDForDataEntityID(DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))
				, SourceSchemaName =		[DC].udf_GetSchemaNameForDataEntityID(DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))
				, Hub_BKFriendlyName =		hbk.BKFriendlyName
				, HubBKFieldID =			hbkf.FieldID
				, HubBKFieldName =			bkfield.FieldName
	from	dmod.hub h
		INNER JOIN DMOD.HubBusinessKey hbk ON hbk.HubID =  h.HubID
		INNER JOIN DMOD.HubBusinessKeyField hbkf ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
		INNER JOIN DC.Field bkfield ON bkfield.FieldID = hbkf.fieldid                             --WS NEXT
	where	1=1
		and h.HubID = @HubID
		and [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID]((select DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID))) = @SourceSystemAbbrFromDataEntityID
		and 
			(
				h.IsActive = 1
				and hbk.IsActive = 1
				and hbkf.IsActive = 1
			)

	FETCH NEXT FROM cursor_SourceSystemAbbr
	INTO @DataEntityIDFromFieldID, @SourceSystemAbbrFromDataEntityID


END

CLOSE cursor_SourceSystemAbbr
DEALLOCATE cursor_SourceSystemAbbr


--SELECT * FROM #SourceDataEntities_KEYS

--drop table if exists #SourceDataEntities
--Select	*
----into	#SourceDataEntities
--from	#SourceDataEntities_KEYS

DROP TABLE IF EXISTS #PKFKTemp
CREATE TABLE #PKFKTemp
--DECLARE #PKFKTemp TABLE 
	    (StageKeysName varchar(1000)
		,SourceSystemAbbrv varchar(100)
		,SourceSystemID int 
		,HubID INT
		,HubName varchar(100)
		,BKFriendlyName varchar(100)
		,BKFieldID INT
		,BKFieldName varchar(100)
		,BKFieldDataType varchar(100)
		,BKFieldMaxLength INT
		,BKFieldPrecision INT
		,BKFieldScale INT
		,BKSourceDataEntityID INT
		,SchemaName varchar(100)
		,BKSourceDataEntityName varchar(100)
		,LinkName varchar(100)
		,ParentHubNameVariation varchar(150)
		,ParentHubID INT
		,ParentHubName varchar(100)
		,ParentHubHubBusinessKeyID int
		,ParentHubBKName varchar(100)
		,ParentDataEntityName varchar(100)
		,PrimaryKeyFieldID INT
		,PrimaryKeyFieldName varchar(100)
		,ParentHubHashKeyName varchar(100)
		,ForeignKeyFieldID INT
		,DataEntityID INT
		,DataEntityID_Hist INT
	     )


INSERT INTO #PKFKTemp 
SELECT DISTINCT  src.SourceSchemaName +'_'+ + REPLACE(src.HubName, 'HUB_', '') +'_'+ src.SourceSystemAbbrv +'_'+ 'KEYS' AS StageKeysName
				,src.SourceSystemAbbrv AS SourceSystemAbbrv
				,src.SourceSystemID
				,src.HubID
				,src.HubName
				,src.Hub_BKFriendlyName
				,src.HubBKFieldID AS BKFieldID
				,dbfd.FieldName AS BKFieldName
				,dbfd.DataType  AS BKFieldDataType
				,dbfd.MaxLength AS BKFieldMaxLength
				,dbfd.Precision AS BKFieldPrecision
				,dbfd.Scale AS BKFieldScale
				,dbfd.DataEntityID AS BKSourceDataEntityID
				,dbfd.SchemaName
				,dbfd.DataEntityName AS BKSourceDataEntityName
				,link.LinkName
				,'HK_' + link.ParentHubNameVariation AS ParentHubNameVariation
				,ParentHubID
				,parenthub.HubName AS ParentHubName
				,parenthubbk.HubBusinessKeyID as ParentHubBusinessKeyID
				,parenthubbk.BKFriendlyName as ParentHubBKName
				,RIGHT(parenthub.HubName,LEN(parenthub.HubName)-4) as ParentDataEntityName
				,linkf.primarykeyfieldID AS PrimaryKeyFieldID
				,primarykeyfield.fieldname AS PrimaryKeyFieldName
				,'HK_'+ REPLACE(parenthub.HubName, 'HUB_', '') AS ParentHubHashKeyName
				,linkf.ForeignKeyFieldID AS ForeignKeyFieldID
				,NULL AS DataEntityID
				,NULL AS DataEntityID_Hist
/*
select	
		--distinct link.PKFKLinkID,  link.ParentHubID, link.ChildHubID, src.HubID, linkf.PKFKLinkFieldID
		--, linkf.ForeignKeyFieldID
		--, [DC].[udf_get_DataEntityID_from_FieldID](linkf.ForeignKeyFieldID)
		--,src.HubBKFieldID 
		--,  [DC].[udf_get_DataEntityID_from_FieldID](src.HubBKFieldID)
		--, dbfd.DataEntityID
		linkf.*
		, linkf.IsActive
		,  *
*/
FROM #SourceDataEntities_KEYS src
	------INNER JOIN DMOD.hub h ON h.HubID = src.HubID
	------INNER JOIN DMOD.HubBusinessKey hbk ON hbk.HubID = src.HubID
	------INNER JOIN DMOD.HubBusinessKeyField hbkf ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
	------INNER JOIN DC.Field bkfield ON bkfield.FieldID = src.HubBKFieldID
	------INNER JOIN DC.DataEntity deBK ON deBK.DataEntityID = bkfield.DataEntityID
	INNER JOIN [DC].[vw_rpt_DatabaseFieldDetail] dbfd ON 
							--dbfd.DataEntityID = deBK.DataEntityID and 
							dbfd.FieldID = src.HubBKFieldID
	LEFT JOIN DMOD.PKFKLinkField linkf ON [DC].[udf_get_DataEntityID_from_FieldID](linkf.ForeignKeyFieldID) = dbfd.DataEntityID  --[DC].[udf_get_DataEntityID_from_FieldID](src.HubBKFieldID)
		and linkf.IsActive = 1
	LEFT JOIN DMOD.PKFKLink link ON link.ChildHubID = src.HubID
								and link.PKFKLinkID = linkf.PKFKLinkID
								and link.IsActive = 1
	LEFT JOIN DMOD.Hub parenthub ON parenthub.HubID = link.ParentHubID
		and parenthub.IsActive = 1
	LEFT JOIN DMOD.HubBusinessKey parenthubbk on parenthubbk.HubID = parenthub.HubID
		and parenthubbk.IsActive = 1
	LEFT JOIN DMOD.HubBusinessKeyField parenthbkf ON parenthbkf.HubBusinessKeyID = parenthubbk.HubBusinessKeyID
		and parenthbkf.IsActive = 1
	LEFT JOIN DC.Field primarykeyfield ON primarykeyfield.FieldID = linkf.PrimaryKeyFieldID
	LEFT JOIN DC.Field foreignkeyfield ON foreignkeyfield.FieldID = linkf.ForeignKeyFieldID
------WHERE src.hubid = @HubID --No need to filter as we're only working with a single hub in #SourceDataEntities_KEYS
----	--AND dbfd.SystemID = @SourceSystemID
 WHERE	1=1
	--and ISNULL(linkf.IsActive, linkf.IsActive) = 1
	--and link.IsActive = 1
	--and parenthub.IsActive = 1
	--and parenthubbk.IsActive = 1
	--and parenthbkf.IsActive = 1
	/*Comment out after testing*/ --and src.HubID = 1033

--select	*
--from	DMOD.PKFKLink
--where	ChildHubID = 1018

--select	*
--from	DMOD.PKFKLinkField
--where	PKFKLinkID = 42

--select	*
--from	DC.vw_rpt_DatabaseFieldDetail
--where	--FieldID IN (749197	,747519, 752983)
-- DataEntityID = 46769
--and FieldName like '%ITEMGROUPID%'



--====================================================================================================
--DATAENTITY
--====================================================================================================
--DECLARE @SourceDataEntityName varchar(100) = (SELECT TOP 1 StageKeysName FROM #PKFKTemp  WHERE SourceSystemAbbrv = 'XT')
----SELECT @SourceDataEntityName

--Select	@TargetSchemaID = s.SchemaID
--from	#SourceDataEntities_KEYS src
--	inner join DC.[Schema] s on s.SchemaName = src.SourceSystemAbbrv
--where	s.DatabaseID = @TargetDatabaseID

----Select	@TargetSchemaID


-- Check if the Data Entity for the Satellites exists, otherwise insert
INSERT INTO DMOD.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
		, [DataEntityTypeID]
		, [IsActive]
)
SELECT	 links.StageKeysName AS KeysName
		, s.SchemaID
		, GETDATE()
		, [DataEntityTypeID] = [DC].[udf_get_DataEntityTypeID]('STAGE')
		, IsActive = 1
FROM	(SELECT DISTINCT StageKeysName, SourceSystemAbbrv
		   FROM #PKFKTemp
		) links
		INNER JOIN [DMOD].[Schema] s ON                               --WSX
			s.DatabaseID = @TargetDatabaseID AND
			s.SchemaName = links.SourceSystemAbbrv
WHERE NOT EXISTS
	(	SELECT	1
		FROM	DMOD.DataEntity de                  --WS
		WHERE links.StageKeysName = de.DataEntityName
			  AND de.SchemaID = s.SchemaID
	 )

-- Create Hist data entities
INSERT INTO DMOD.DataEntity
	(
		DataEntityName
		, SchemaID
		, CreatedDT
		, [DataEntityTypeID]
		, [IsActive]
)
SELECT	 links.StageKeysName + '_Hist' AS KeysName
		, s.SchemaID
		, GETDATE()
		, [DataEntityTypeID] = [DC].[udf_get_DataEntityTypeID]('STAGE')
		, IsActive = 1
FROM	(SELECT DISTINCT StageKeysName, SourceSystemAbbrv
		   FROM #PKFKTemp
		) links
		INNER JOIN [DMOD].[Schema] s ON                                       --WSX
			s.DatabaseID = @TargetDatabaseID AND
			s.SchemaName = links.SourceSystemAbbrv
WHERE NOT EXISTS
	(	SELECT	1
		FROM	DMOD.DataEntity de
		WHERE links.StageKeysName + '_Hist' = de.DataEntityName
			  AND de.SchemaID = s.SchemaID
	 )



--Get the IDs of the Data Entities created
UPDATE links
   SET DataEntityID = de.DataEntityID,
	   DataEntityID_Hist = de_hist.DataEntityID
  FROM #PKFKTemp links
	   INNER JOIN DMOD.[Schema] s ON                ---WS DC TO DMOD
			s.DatabaseID = @TargetDatabaseID AND
			s.SchemaName = links.SourceSystemAbbrv
	   INNER JOIN DMOD.[DataEntity] de ON
			de.SchemaID = s.SchemaID AND
			de.DataEntityName = links.StageKeysName
	   INNER JOIN DMOD.[DataEntity] de_hist ON
			de_hist.SchemaID = s.SchemaID AND
			de_hist.DataEntityName = links.StageKeysName + '_Hist'

--Create Hist versions of the Stage tables


--====================================================================================================
--FIELDS
--====================================================================================================


DROP TABLE IF EXISTS #StageFields1
CREATE TABLE #StageFields1
--DECLARE #StageFields1 TABLE
	(
		FieldName varchar(1000)
		,DataType varchar(500)
		,[MAXLENGTH] int
		,[Precision] int
		,[Scale] int
		,DataEntityID int
		,DataEntityID_Hist int
		,CreatedDT datetime2(7)
		,FieldSortOrder int
		,IsActive int
	)

INSERT INTO #StageFields1
SELECT StandardFields.FieldName, StandardFields.DataType, StandardFields.[MaxLength], StandardFields.[Precision], StandardFields.[Scale], links.DataEntityID, links.DataEntityID_Hist, GETDATE(), StandardFields.FieldSortOrder, StandardFields.IsActive
  FROM 
	(
		SELECT 'BKHash' AS FieldName, 'varchar' AS DataType, 40 AS [MaxLength], 0 AS [Precision], 0 AS [Scale], CONVERT(INT, NULL) AS DataEntityID, CONVERT(INT, NULL) AS DataEntityID_Hist, CONVERT(datetime2(7), NULL) AS CreatedDT, 1 AS FieldSortOrder, 1 AS IsActive
		UNION ALL
		SELECT 'LoadDT', 'datetime2', 8, 27, 7, NULL, NULL, NULL, 2, 1
		UNION ALL
		SELECT 'RecSrcDataEntityID', 'int', 4, 10, 0, NULL, NULL, NULL, 3, 1
	) AS StandardFields
	CROSS JOIN
		(
			SELECT DISTINCT StageKeysName, DataEntityID, DataEntityID_Hist
			  FROM #PKFKTemp
		) AS links

--select * from #PKFKTemp


INSERT INTO #StageFields1
SELECT DISTINCT BKFieldName 
			   ,BKFieldDataType
			   ,BKFieldMaxLength
			   ,BKFieldPrecision
			   ,BKFieldScale
			   ,links.DataEntityID
			   ,links.DataEntityID_Hist
			   ,GETDATE()
			   ,ROW_NUMBER() OVER (PARTITION BY links.[DataEntityID] ORDER BY (hbk.FieldSortOrder)) + 1000
			   ,1
FROM (SELECT DISTINCT BKFieldName 
			   ,BKFieldDataType
			   ,BKFieldMaxLength
			   ,BKFieldPrecision
			   ,BKFieldScale
			   ,BKFieldID
			   ,DataEntityID
			   ,DataEntityID_Hist
	   FROM #PKFKTemp) links
	 INNER JOIN DMOD.HubBusinessKeyField bkf ON
			bkf.FieldID = links.BKFieldID
	 INNER JOIN DMOD.HubBusinessKey hbk ON
			hbk.HubBusinessKeyID = bkf.HubBusinessKeyID
WHERE hbk.HubID = @HubID



--select	*
--from	#StageFields1    --wiumnight

INSERT INTO #StageFields1
SELECT DISTINCT ISNULL(links.ParentHubNameVariation, links.ParentHubHashKeyName) --This is to cater for purpose-built links (i.e. InZone and OutZone)
			   ,'varchar'
			   ,40
			   ,0
			   ,0
			   ,links.DataEntityID
			   ,links.DataEntityID_Hist
			   ,GETDATE()
			   ,ROW_NUMBER() OVER (PARTITION BY links.[DataEntityID] ORDER BY ISNULL(f.FieldSortOrder, f.FieldName)) * 2 + 2 + 2000
			   ,1
FROM (SELECT DISTINCT ParentHubHashKeyName
			   ,ParentHubNameVariation
			   ,ForeignKeyFieldID
			   ,DataEntityID
			   ,DataEntityID_Hist
	   FROM #PKFKTemp) links
	 INNER JOIN DC.Field f ON 
			f.FieldID = links.ForeignKeyFieldID

--select	*
--from	#StageFields1    --wiumnight


/*
SELECT DISTINCT ParentDataEntityName
			   ,BKSourceDataEntityName
			   ,ForeignKeyFieldID
			   ,LinkName
			   ,DataEntityID
			   ,DataEntityID_Hist
	   FROM #PKFKTemp
*/


INSERT INTO #StageFields1   --wiumnight
SELECT DISTINCT REPLACE(links.LinkName, 'LINK_', 'LINKHK_') --+ ParentDataEntityName + '_' + [DC].[udf_ConvertSingleWordToCamelCase](BKSourceDataEntityName)
			   ,'varchar'
			   ,40
			   ,0
			   ,0
			   ,links.DataEntityID
			   ,links.DataEntityID_Hist
			   ,GETDATE()
			   ,null--ROW_NUMBER() OVER (PARTITION BY links.[DataEntityID] ORDER BY ISNULL(f.FieldSortOrder, f.FieldName)) * 2 + 3 + 2000
			   ,1
FROM (SELECT DISTINCT ParentDataEntityName
			   ,BKSourceDataEntityName
			   ,ForeignKeyFieldID
			   ,LinkName
			   ,DataEntityID
			   ,DataEntityID_Hist
	   FROM #PKFKTemp) links
 INNER JOIN DC.Field f ON     
	f.FieldID = links.ForeignKeyFieldID

--select	*
--from	#StageFields1    --wiumnight






--Create the Fields in DC.Field

INSERT INTO DMOD.Field
(FieldName 
,DataType 
,[MAXLENGTH] 
,[Precision]
,[Scale]
,DataEntityID
,CreatedDt 
,FieldSortOrder 
,IsActive)
SELECT   FieldName 
		,DataType 
		,[MAXLENGTH] 
		,[Precision]
		,[Scale]
		,DataEntityID
		,CreatedDt 
		,ROW_NUMBER() OVER (PARTITION BY sf1.[DataEntityID] ORDER BY sf1.FieldSortOrder)
		,IsActive
FROM 
		(
			select	FieldName 
				   ,DataType 
				   ,[MAXLENGTH] 
				   ,[Precision]
				   ,[Scale]
				   ,DataEntityID
				   ,CreatedDt 
				   ,FieldSortOrder 
				   ,IsActive
			from	#StageFields1
			where	FieldName IS NOT NULL
		) sf1
WHERE NOT EXISTS (SELECT 1
				  FROM DMOD.Field f                        --WS
				  WHERE sf1.DataEntityID = f.DataEntityID
				  AND sf1.FieldName = f.FieldName	
				  )

--Create the Hist Fields in DC.Field
INSERT INTO DMOD.Field
(FieldName 
,DataType 
,[MAXLENGTH] 
,[Precision]
,[Scale]
,DataEntityID
,CreatedDt 
,FieldSortOrder 
,IsActive)
SELECT   FieldName 
		,DataType 
		,[MAXLENGTH] 
		,[Precision]
		,[Scale]
		,DataEntityID_Hist
		,CreatedDt 
		,ROW_NUMBER() OVER (PARTITION BY sf1.[DataEntityID_Hist] ORDER BY sf1.FieldSortOrder)
		,IsActive
FROM 
		(
			select	FieldName 
				   ,DataType 
				   ,[MAXLENGTH] 
				   ,[Precision]
				   ,[Scale]
				   ,DataEntityID_Hist
				   ,CreatedDt 
				   ,FieldSortOrder 
				   ,IsActive
			from	#StageFields1
			where	FieldName IS NOT NULL
		) sf1
WHERE NOT EXISTS (SELECT 1
				  FROM DMOD.Field f
				  WHERE sf1.DataEntityID_Hist = f.DataEntityID
				  AND sf1.FieldName = f.FieldName	
				  )


--=========================================================================================================================================================================
-- Create or update the field relations for the KEYS in this execution
--=========================================================================================================================================================================

INSERT INTO DMOD.FieldRelation
	(
		SourceFieldID
		,TargetFieldID
		,FieldRelationTypeID
		,CreatedDT
	)

	select	ODSFieldID
			, StageFieldID
			, @FieldRelationTypeID_STT
			, GETDATE()
	from	
		(
			--Map the BKHash Columns - checked (KD)
			select	distinct 
					  DC.udf_get_ODSFieldID_From_SourceFieldID(h.BKFieldID) AS ODSFieldID
					, f.FieldID as StageFieldID
			from	#PKFKTemp h
				inner join DC.vw_rpt_DatabaseFieldDetail f on f.DataEntityName = h.StageKeysName
			where	f.FieldName = 'BKHash'
			
			union all

			--Map the business key columns that is not hashed
			select	distinct 
					  DC.udf_get_ODSFieldID_From_SourceFieldID(h.BKFieldID) AS ODSFieldID
					, f.FieldID as StageFieldID
			from	#PKFKTemp h
				inner join DC.vw_rpt_DatabaseFieldDetail f on f.DataEntityName = h.StageKeysName
			where	f.FieldName = h.BKFieldName

			union all

			--select	*
			--from	#PKFKTemp
			--order by 1

			--HashKey mapping: Map the primary key hub business key ods field to stage hash key column in the keys table
			select	 
					DISTINCT DC.udf_get_ODSFieldID_From_SourceFieldID(parenthubbkf.FieldID) as ODSFieldID
					, f.FieldID as StageFieldID
					--, [DC].[udf_GetSourceSystemIDForDataEntityID](DC.udf_get_DataEntityID_from_FieldID(parenthubbkf.FieldID))
					--*
			from	#PKFKTemp h
				inner join DMOD.HubBusinessKeyField parenthubbkf on parenthubbkf.HubBusinessKeyID = h.ParentHubHubBusinessKeyID
				--inner join DC.Field sourcef ON sourcef.FieldID = parenthubbkf.FieldID
				inner join DC.Field f on f.FieldName = h.ParentHubHashKeyName AND
										 f.DataEntityID = h.DataEntityID  
										 and [DC].[udf_GetSourceSystemIDForDataEntityID](DC.udf_get_DataEntityID_from_FieldID(parenthubbkf.FieldID)) = h.sourcesystemid 
			where	1=1
				--and parenthubbkf.IsActive = 1
				--and f.FieldID = 748962 
				--and parenthubbkf.FieldID = 748962
			--where	f.FieldName = h.PrimaryHashKeyName
			--order by h.BKFieldID
			


			union all

			--HKLINK Mapping: Map the primary key hub business key ods field to stage LINK hash key column in the keys table
				--First query: Get the mappings for non-base entity business key field/s
			select	 DISTINCT DC.udf_get_ODSFieldID_From_SourceFieldID(parenthubbkf.FieldID) as ODSFieldID --SITE_CODEID & SITE_NAME
					, f.FieldID as StageFieldID --LINKHK_Site_Department
			from	#PKFKTemp h
				inner join DMOD.HubBusinessKeyField parenthubbkf on parenthubbkf.HubBusinessKeyID = h.ParentHubHubBusinessKeyID
				inner join DC.Field sourcef ON sourcef.FieldID = parenthubbkf.FieldID
				inner join DC.Field f on f.FieldName = REPLACE(h.LinkName, 'LINK_', 'LINKHK_') AND
										 f.DataEntityID = h.DataEntityID
										 and [DC].[udf_GetSourceSystemIDForDataEntityID](DC.udf_get_DataEntityID_from_FieldID(parenthubbkf.FieldID)) = h.sourcesystemid 
			where parenthubbkf.IsActive = 1

			UNION ALL

				--Second query: Get the mappings for base entity business key field/s
			select	 DISTINCT DC.udf_get_ODSFieldID_From_SourceFieldID(h.BKFieldID) as ODSFieldID
					, f.FieldID as StageFieldID
			from	#PKFKTemp h
				inner join DMOD.HubBusinessKeyField parenthubbkf on parenthubbkf.HubBusinessKeyID = h.ParentHubHubBusinessKeyID
				inner join DC.Field sourcef ON sourcef.FieldID = parenthubbkf.FieldID
				inner join DC.Field f on f.FieldName = REPLACE(h.LinkName, 'LINK_', 'LINKHK_') AND
										 f.DataEntityID = h.DataEntityID
			where parenthubbkf.IsActive = 1

			--where	f.FieldName = h.PrimaryHashKeyName
		)fr
where	NOT EXISTS
						(
							select	1
							from	DC.FieldRelation fr1
								inner join DC.FieldRelationType frt on frt.FieldRelationTypeID = fr1.FieldRelationTypeID
							where	fr.ODSFieldID = fr1.SourceFieldID
								and fr.StageFieldID = fr1.TargetFieldID
								and frt.FieldRelationTypeCode = 'STT'
						)




--TODO KD "Back"-populate the DataEntityID in Hubs and Sats (look at a separate structure for this to store the link back to Stage Keys and Stage Sat tables)
--TODO KD Update the Stage Table Name if it changes (we need a separate process for this)




--INSERT INTO DC.FieldRelation
--(SourceFieldID
--,TargetFieldID
--,FieldRelationTypeID
--,CreatedDT)
--SELECT(SELECT [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](SourceFieldID)
--FROM dmod.Hub hw
--inner join dmod.HubBusinessKey_Working hkw ON
--hw.HubID = hkw.HubID 
--WHERE hw.HubID = @HubID)
--,f.FieldID
--,2
--,GETDATE()
--FROM DC.Field f
--WHERE NOT EXISTS (SELECT 1
--				  FROM DC.FieldRelation
--				  WHERE SourceFieldID = 56
--				  AND  TargetFieldID in (SELECT FieldID FROM DC.Field WHERE DataEntityID = 10100
--										AND  FieldName not in ('LoadDT','RecSrcDataEntityID')	
--										)
--					)
--AND DataEntityID = @KeysDEID
--AND FieldName not in ('LoadDT','RecSrcDataEntityID')

--*/

--------/**********************************************************************************************************
--------KEYS FOR PKFK
--------***********************************************************************************************************/
--------DECLARE #PKFKTemp TABLE 
--------	    (StageKeysName varchar(1000)
--------		,HubID INT
--------		,HubName varchar(100)
--------		,BKFriendlyName varchar(100)
--------		,BKFieldID INT
--------		,BKFieldName varchar(100)
--------		,BKFieldDataType varchar(100)
--------		,BKFieldMaxLength INT
--------		,BKFieldPrecision INT
--------		,BKFieldScale INT
--------		,BKSourceDataEntityID INT
--------		,SchemaName varchar(100)
--------		,BKSourceDataEntityName varchar(100)
--------		,LinkName varchar(100)
--------		,ParentHubID INT
--------		,ParentHubName varchar(100)
--------		,ParentDataEntityName varchar(100)
--------		,PrimaryKeyFieldID INT
--------		,PrimaryKeyFieldName varchar(100)
--------		,PrimaryHashKeyName varchar(100)
--------		,ForeignKeyFieldID INT
--------	     )

--------INSERT INTO #PKFKTemp 
------SELECT DISTINCT  dbfd.SchemaName+'_'+[DC].[udf_ConvertSingleWordToCamelCase](deBK.DataEntityName)+'_Keys' AS StageKeysName
------				, src.SourceSchemaName +'_'+ + REPLACE(src.HubName, 'HUB_', '') +'_'+ src.SourceSystemAbbrv +'_'+ 'KEYS'
------				,h.HubID
------				,h.HubName
------				,BKFriendlyName
------				,hbkf.FieldID AS BKFieldID
------				,bkfield.FieldName AS BKFieldName
------				,bkfield.DataType  AS BKFieldDataType
------				,bkfield.MaxLength AS BKFieldMaxLength
------				,bkfield.Precision AS BKFieldPrecision
------				,bkfield.Scale AS BKFieldScale
------				,bkfield.DataEntityID AS BKSourceDataEntityID
------				,dbfd.SchemaName
------				,deBK.DataEntityName AS BKSourceDataEntityName
------				,LinkName
------				,ParentHubID
------				,parenthub.HubName AS ParentHubName
------				,RIGHT(parenthub.HubName,LEN(parenthub.HubName)-4)
------				,primarykeyfieldID AS PrimaryKeyFieldID
------				,primaryfield.fieldname AS PrimaryKeyFieldName
------				,'HK_'+ primaryfield.fieldname AS PrimaryHashKeyName
------				,foreignkeyfieldid AS ForeignKeyFieldID

------FROM dmod.hub h
------	INNER JOIN DMOD.HubBusinessKey hbk ON hbk.HubID =  h.HubID
------	INNER JOIN DMOD.HubBusinessKeyField hbkf ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
------	INNER JOIN DC.Field bkfield ON bkfield.FieldID = hbkf.fieldid
------	INNER JOIN DC.DataEntity deBK ON deBK.DataEntityID = bkfield.DataEntityID
------	INNER JOIN DC.vw_rpt_DatabaseFieldDetail dbfd ON dbfd.DataEntityID = deBK.DataEntityID
------	INNER JOIN DMOD.PKFKLink lchild ON lchild.ChildHubID = h.HubID
------	INNER JOIN DMOD.PKFKLinkField lfchild ON lfchild.PKFKLinkID = lchild.PKFKLinkID
------	INNER JOIN DMOD.Hub parenthub ON parenthub.HubID = ParentHubID
------	INNER JOIN DC.Field primaryfield ON primaryfield.FieldID = PrimaryKeyFieldID
------	INNER JOIN DC.Field foreignfield ON foreignfield.FieldID = ForeignKeyFieldID
------	INNER JOIN #SourceDataEntities_KEYS src on src.HubID = h.HubID
------WHERE h.hubid = 7
------	AND dbfd.SystemID = @SourceSystemID

--------====================================================================================================
--------DATAENTITY
--------====================================================================================================
------DECLARE @SourceDataEntityName varchar(100) = (SELECT TOP 1 StageKeysName FROM #PKFKTemp)
-------- Check if the Data Entity for the Satellites exists, otherwise insert		
------INSERT INTO DC.DataEntity
------	(     DataEntityName
------		, SchemaID
------		, CreatedDT
------	)
------SELECT	 TOP 1 @SourceDataEntityName AS KeysName
------		, @TargetSchemaID
------		, GETDATE()
------FROM	#PKFKTemp
------WHERE NOT EXISTS
------	(	SELECT	1
------		FROM	DC.DataEntity de
------		WHERE @SourceDataEntityName = de.DataEntityName
------			  AND de.SchemaID = @TargetSchemaID
------	 )


------DECLARE @KeysDEID INT = (SELECT TOP 1 DataEntityID 
------						 FROM DC.DataEntity
------						 WHERE DataEntityName = @SourceDataEntityName
------						 AND SchemaID = @TargetSchemaID)

--------====================================================================================================
--------FIELDS
--------====================================================================================================

------DECLARE #StageFields1 TABLE
------(FieldName varchar(1000)
------,DataType varchar(500)
------,[MAXLENGTH] int
------,[Precision] int
------,[Scale] int
------,DataEntityID int
------,CreatedDt datetime2(7)
------,FieldSortOrder int
------,IsActive int)

------INSERT #StageFields1 VALUES
------		('BKHash','varchar',40,0,0,@KeysDEID, GETDATE(), 1, 1),
------		('LoadDT','datetime2',8,27,7,@KeysDEID, GETDATE(), 2, 1),
------		('RecSrcDataEntityID','int',4,10,0,@KeysDEID, GETDATE(), 3, 1)
------INSERT INTO #StageFields1
------SELECT DISTINCT BKFieldName 
------			   ,BKFieldDataType
------			   ,BKFieldMaxLength
------			   ,BKFieldPrecision
------			   ,BKFieldScale
------			   ,@KeysDEID
------			   ,GETDATE()
------			   ,1000
------			   ,1
------FROM #PKFKTemp			

------INSERT INTO #StageFields1
------SELECT DISTINCT 'HK_' + PrimaryKeyFieldName 
------			   ,'varchar'
------			   ,40
------			   ,0
------			   ,0
------			   ,@KeysDEID
------			   ,GETDATE()
------			   ,2000
------			   ,1
------FROM #PKFKTemp			

------INSERT INTO #StageFields1
------SELECT DISTINCT 'LINKHK_' + ParentDataEntityName + '_' + [DC].[udf_ConvertSingleWordToCamelCase](BKSourceDataEntityName)
------			   ,'varchar'
------			   ,40
------			   ,0
------			   ,0
------			   ,@KeysDEID
------			   ,GETDATE()
------			   ,3000
------			   ,1
------FROM #PKFKTemp			

------INSERT INTO DC.Field
------(FieldName 
------,DataType 
------,[MAXLENGTH] 
------,[Precision]
------,[Scale]
------,DataEntityID
------,CreatedDt 
------,FieldSortOrder 
------,IsActive)
------SELECT   FieldName 
------		,DataType 
------		,[MAXLENGTH] 
------		,[Precision]
------		,[Scale]
------		,DataEntityID
------		,CreatedDt 
------		,RANK() over (order by FieldSortOrder, FieldName) 
------		,IsActive
------FROM #StageFields1 sf1
------WHERE NOT EXISTS (SELECT 1
------				  FROM DC.Field f
------				  WHERE sf1.DataEntityID = f.DataEntityID
------				  AND sf1.FieldName = f.FieldName	
------				  )


--------INSERT INTO DC.FieldRelation
--------(SourceFieldID
--------,TargetFieldID
--------,FieldRelationTypeID
--------,CreatedDT)
--------SELECT(SELECT [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](SourceFieldID)
--------FROM dmod.Hub hw
--------inner join dmod.HubBusinessKey_Working hkw ON
--------hw.HubID = hkw.HubID 
--------WHERE hw.HubID = @HubID)
--------,f.FieldID
--------,2
--------,GETDATE()
--------FROM DC.Field f
--------WHERE NOT EXISTS (SELECT 1
--------				  FROM DC.FieldRelation
--------				  WHERE SourceFieldID = 56
--------				  AND  TargetFieldID in (SELECT FieldID FROM DC.Field WHERE DataEntityID = 10100
--------										AND  FieldName not in ('LoadDT','RecSrcDataEntityID')	
--------										)
--------					)
--------AND DataEntityID = @KeysDEID
--------AND FieldName not in ('LoadDT','RecSrcDataEntityID')















--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************/


--OLD CODE (I THINK I AM NOT SURE) ~ FG


--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************/
--/**********************************************************************************************************/

--/**********************************************************************************************************
--KEYS FOR SAL
--***********************************************************************************************************/
--DECLARE @SALTemp TABLE
--(SameAsLinkID VARCHAR(100)
--,SameAsLinkName VARCHAR(100)
--,SourceName VARCHAR(100)
--,HubThatSatLinksToID INT
--,HubThatSatLinksToName VARCHAR(100)
--,MDMSourceDataEntityID INT
--,MDMSourceDataEntityName VARCHAR(100)
--,MDMSourceBKFieldID INT
--,MDMSourceBKName VARCHAR(100)
--,BKFiendlyName VARCHAR(100)
--,SourceFieldID INT
--,SourceFieldName VARCHAR(100)
--,SourceFieldDataType VARCHAR(100)
--,SourceFieldMaxLength INT
--,SourceFieldPrecision INT
--,SourceFieldScale INT
--,SourceFieldSortOrder INT
--,NewDataEntity INT)
--INSERT INTO @SALTemp
--SELECT SameAsLinkID
--	  ,SameAsLinkName
--	  ,RIGHT(SameAsLinkName,LEN(SameAsLinkName)-4)
--	  ,hw.HubID
--	  ,hw.HubName
--	  ,hw.SourceDataEntityID
--	  ,de.DataEntityName
--	  ,SourceFieldID
--	  ,f.FieldName
--	  ,hkw.BKFriendlyName
--	  ,f1.FieldID
--	  ,f1.FieldName
--	  ,f1.DataType
--	  ,f1.MaxLength
--	  ,f1.Precision
--	  ,f1.Scale
--	  ,f1.FieldSortOrder	  
--	  ,NULL

--FROM dmod.SameAsLink_Working salw
--INNER JOIN DMOD.Hub_Working hw ON
--hw.HubID = salw.HubID
--INNER JOIN DMOD.HubBusinessKey_Working hkw ON
--hkw.HubID = hw.HubID
--INNER JOIN DC.DataEntity de ON
--de.DataEntityID = hw.SourceDataEntityID
--INNER JOIN DC.Field f ON
--f.FieldID = hkw.SourceFieldID
--INNER JOIN DC.Field f1
--ON f1.DataEntityID = hw.SourceDataEntityID
--WHERE hw.HubID = @HubID

--SELECT * FROM @SALTemp

----====================================================================================================
----DATAENTITY
----====================================================================================================
--DECLARE @SalSourceDataEntityName varchar(100) = (SELECT DISTINCT SourceName FROM @SALTemp)
--DECLARE @SourceNameSal VARCHAR(100) = (SELECT TOP 1 SourceName FROM @SALTemp)

-- --Check if the Data Entity for the Satellites exists, otherwise insert		
--INSERT INTO DC.DataEntity
--	(     DataEntityName
--		, SchemaID
--		, CreatedDT
--	)


--SELECT	 TOP 1 'dbo_'+@SourceNameSal+'_KEYS' AS KeysName
--		, @TargetSchemaID
--		, GETDATE()
--FROM	@SALTemp st
--WHERE NOT EXISTS
--	(	SELECT	1
--		FROM	DC.DataEntity de
--		WHERE 'dbo_'+@SourceNameSal+'_KEYS' = de.DataEntityName
--			  AND de.SchemaID = @TargetSchemaID
--	 )


--DECLARE @KeysSalDEID INT = (SELECT TOP 1 DataEntityID 
--							FROM DC.DataEntity
--							WHERE DataEntityName = 'dbo_'+@SourceNameSal+'_KEYS'
--							AND SchemaID = @TargetSchemaID)
----====================================================================================================
----FIELDS
----====================================================================================================

--DECLARE @StageFields2 TABLE
--(FieldName varchar(1000)
--,DataType varchar(500)
--,[MAXLENGTH] int
--,[Precision] int
--,[Scale] int
--,DataEntityID int
--,CreatedDt datetime2(7)
--,FieldSortOrder int
--,IsActive int)

--DECLARE @BKMasterName VARCHAR(100) = (SELECT SourceFieldName
--									  FROM @SALTemp 
--									  WHERE SourceFieldName like '%MASTER%'
--										)

--DECLARE @BKSlaveName VARCHAR(100) = (SELECT SourceFieldName
--									  FROM @SALTemp 
--									  WHERE SourceFieldName like '%Slave%'
--										)

--IF(SELECT COUNT(1) FROM @SALTemp) > 0

--INSERT @StageFields2 VALUES
--		('HK_'+@SourceNameSal,'varchar',40,0,0,@KeysSalDEID, GETDATE(), 1, 1),
--		('LoadDT','datetime2',8,27,7,@KeysSalDEID, GETDATE(), 2, 1),
--		('RecSrcDataEntityID','int',4,10,0,@KeysSalDEID, GETDATE(), 3, 1),
--		('HK_'+@BKMasterName,'varchar',50,0,0,@KeysSalDEID,GETDATE(),4,1),
--		('HK_'+@BKSlaveName,'varchar',40,0,0,@KeysSalDEID,GETDATE(),5,1)


--IF(SELECT COUNT(1) FROM @SALTemp) > 0
--INSERT INTO DC.Field
--(FieldName 
--,DataType 
--,[MAXLENGTH] 
--,[Precision]
--,[Scale]
--,DataEntityID
--,CreatedDt 
--,FieldSortOrder 
--,IsActive)
--SELECT   FieldName 
--		,DataType 
--		,[MAXLENGTH] 
--		,[Precision]
--		,[Scale]
--		,DataEntityID
--		,CreatedDt 
--		,FieldSortOrder 
--		,IsActive
--FROM @StageFields2 sf2
--WHERE NOT EXISTS (SELECT 1
--				  FROM DC.Field f
--				  WHERE sf2.DataEntityID = f.DataEntityID
--				  AND sf2.FieldName = f.FieldName	
--				  )


----INSERT INTO DC.FieldRelation
----(SourceFieldID
----,TargetFieldID
----,FieldRelationTypeID
----,CreatedDT)
----SELECT(SELECT [DC].[udf_get_ODSLevelBKFieldID_FromSourceBKFieldID](SourceFieldID)
----FROM dmod.Hub_Working hw
----inner join dmod.HubBusinessKey_Working hkw ON

GO
