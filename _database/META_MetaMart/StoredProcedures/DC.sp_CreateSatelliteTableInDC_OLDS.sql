SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================

CREATE PROCEDURE [DC].[sp_CreateSatelliteTableInDC_OLDS]
(
   @HubID INT
)
AS
BEGIN




--DECLARE @HubID INT = 14

--get target database id
DECLARE @TargetDatabaseID INT = (SELECT TOP 1 db.DatabaseID
								FROM 
								[DC].[Database] db
								LEFT JOIN [DC].[DatabasePurpose] dbp
								ON db.DataBasePurposeID = dbp.DataBasePurposeID 
								WHERE dbp.DataBasePurposeCode = 'DataVault'
								AND DatabaseName like '%DataVault%')

--get target schema name
DECLARE @TargetSchemaName varchar(20) = (SELECT TOP 1 s.SchemaName
										FROM 
										[DC].[Schema] s
										LEFT JOIN [DC].[Database] db
										ON s.databaseid = db.databaseid
										LEFT JOIN [DC].[DatabasePurpose] dbp
										ON db.DataBasePurposeID = dbp.DataBasePurposeID 
										WHERE dbp.DataBasePurposeCode = 'DataVault'
										AND DatabaseName like '%DataVault%')

--get target schema id
DECLARE @TargetSchemaID INT = (SELECT TOP 1 s.SchemaID
										FROM 
										[DC].[Schema] s
										LEFT JOIN [DC].[Database] db
										ON s.databaseid = db.databaseid
										LEFT JOIN [DC].[DatabasePurpose] dbp
										ON db.DataBasePurposeID = dbp.DataBasePurposeID 
										WHERE dbp.DataBasePurposeCode = 'DataVault'
										AND DatabaseName like '%DataVault%')

--create raw schema if not exists
If(@TargetSchemaName IS NULL)
	BEGIN
		INSERT INTO DC.[Schema] 
			(
				SchemaName
				, DatabaseID
				, DBSchemaID
				, CreatedDT
			)
		SELECT	'raw'
				, @TargetDatabaseID
				, NULL
				, GETDATE()

		-- Get newly inserted SchemaID
		SET @TargetSchemaID = @@IDENTITY
	END
			
			--DECLARE @HubID INT = 14
			--declare temp table for all bk friendly names
			DECLARE @BKFriendlyNames Table
			(
				BKFieldID INT,
				BKDataEntityID INT,
				SchemaID INT,
				DatabaseID INT,
				SystemID INT,
				BKFriendlyName Varchar(200)
			)

				--add all bk field details and system id 
				INSERT INTO @BKFriendlyNames(BKFriendlyName, BKFieldID, BKDataEntityID, SchemaID, DatabaseID, SystemID)
				SELECT hbk.BKFriendlyName, 
				hbkf.FieldID,
				f.DataentityID,
				de.SchemaID,
				s.DatabaseID,
				CASE
					WHEN s.SystemID IS NULL
					THEN db.SystemID
					ELSE s.SystemID
				END

				FROM dmod.HubBusinessKey hbk
				LEFT JOIN dmod.HubBusinessKeyField hbkf
				ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
				LEFT JOIN DC.Field f
				ON f.FieldID = hbkf.FieldID
				LEFT JOIN DC.DataEntity de
				ON de.DataEntityID = f.DataEntityID
				LEFT JOIN DC.[Schema] s
				ON s.SchemaID = de.SchemaID
				LEFT JOIN DC.[Database] db
				ON db.DatabaseID = s.DatabaseID
				WHERE HubID = @hubid

				--TEST
				--select * from @bkfriendlynames

			
				
			--GET TARGET(stage) DATAENTITY LIST FOR ALL SATELLITES WHEN A HUBID IS PROVIDED and DMOD SAT Name	
			DECLARE @StageSatelliteDetail Table
			(
				SatelliteID INT,
				SatelliteName varchar(200),
				SatelliteFieldID INT,
				SatelliteTargetFieldID INT,
				SatelliteTargetDataEntityID INT,
				SatteliteVaultDataEntityID INT,
				SystemID INT,
				BKFriendlyName varchar(200)
			)

				--insert into temp table, sat id, sat name, source field id, stage field id, stage data entity id
				INSERT INTO @StageSatelliteDetail(SatelliteID, SatelliteName, SatelliteFieldID, SatelliteTargetFieldID, SatelliteTargetDataEntityID, SystemID)
				SELECT 
				s.SatelliteID, 
				s.SatelliteName, 
				(SELECT TOP (1) sf.FieldID FROM DMOD.SatelliteField sf WHERE s.SatelliteID = sf.SatelliteID) AS [SatelliteFieldID],

				--(SELECT  fr2.TargetFieldID from DC.FieldRelation fr
				--LEFT JOIN 
				--			(
				--				select fr.targetFieldID, fr.sourcefieldid
				--				from	DC.FieldRelation fr
				--					inner join DC.Field f on f.FieldID = fr.TargetFieldID
				--				--where	f.FieldName not like '%HashDiff%'
				--			) fr2 on fr.TargetFieldID = fr2.SourceFieldID
				--WHERE fr.SourceFieldID = (SELECT TOP (1) sf.FieldID FROM DMOD.SatelliteField sf WHERE s.SatelliteID = sf.SatelliteID)) AS [SatelliteTargetFieldID],
				[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID] ((SELECT TOP (1) sf.FieldID FROM DMOD.SatelliteField sf WHERE s.SatelliteID = sf.SatelliteID), s.SatelliteDataVelocityTypeID) AS [SatelliteTargetFieldID],

				--(SELECT TOP (1) DataEntityID FROM DC.Field WHERE FieldID = (SELECT fr2.TargetFieldID from DC.FieldRelation fr
				--LEFT JOIN 
				--			(
				--				select fr.targetFieldID, fr.sourcefieldid
				--				from	DC.FieldRelation fr
				--					inner join DC.Field f on f.FieldID = fr.TargetFieldID
				--				where	f.FieldName not like '%HashDiff%'
				--			) fr2 on fr.TargetFieldID = fr2.SourceFieldID
				--WHERE fr.SourceFieldID = (SELECT TOP (1) sf.FieldID FROM DMOD.SatelliteField sf WHERE s.SatelliteID = sf.SatelliteID))) AS [SatelliteTargetDataEntityID],

				[DC].[udf_get_StageLevelBKDataEntityID_FromSourceBKFieldID] ((SELECT TOP (1) sf.FieldID FROM DMOD.SatelliteField sf WHERE s.SatelliteID = sf.SatelliteID), s.SatelliteDataVelocityTypeID) AS [SatelliteTargetDataEntityID],

				CASE 
					WHEN (SELECT SystemID
							FROM DC.[Schema]
							WHERE SchemaID = (SELECT SchemaID 
									FROM DC.DataEntity 
									WHERE DataEntityID  = (SELECT TOP (1) DataEntityID 
															FROM dc.field 
															WHERE FieldID = ((SELECT TOP (1) sf.FieldID 
																			FROM DMOD.SatelliteField sf
																			WHERE s.SatelliteID = sf.SatelliteID))))) IS NULL
					THEN 
					(SELECT SystemID from DC.[Database]
					where DatabaseID = 
					(SELECT DatabaseID
							FROM DC.[Schema]
							WHERE SchemaID = (SELECT SchemaID 
									FROM DC.DataEntity 
									WHERE DataEntityID  = (SELECT TOP (1) DataEntityID 
															FROM DC.Field
															WHERE FieldID = ((SELECT TOP (1) sf.FieldID 
																			FROM DMOD.SatelliteField sf 
																			WHERE s.SatelliteID = sf.SatelliteID))))))
					ELSE
					(SELECT SystemID
							FROM DC.[Schema]
							WHERE SchemaID = (SELECT SchemaID 
									FROM DC.DataEntity 
									WHERE DataEntityID  = (SELECT TOP (1) DataEntityID 
															FROM dc.field 
															WHERE FieldID = ((SELECT TOP (1) sf.FieldID 
																			FROM DMOD.SatelliteField sf
																			WHERE s.SatelliteID = sf.SatelliteID)))))
					 
				END
				
				FROM DMOD.Satellite s
				WHERE hubid = @HubID
				

					
				--insert bkfriendly names into the sat name
				UPDATE ssd
				SET ssd.BKFriendlyName = bkfn.BKFriendlyName
				FROM @StageSatelliteDetail ssd 
				LEFT JOIN @BKFriendlyNames bkfn
				ON bkfn.SystemID = ssd.SystemID
				WHERE bkfn.bkfriendlyname IS NOT NULL

				--TEST
				--select * from @StageSatelliteDetail
				
				
				--SELECT * FROM DC.DataEntity
				--WHERE DataEntityName = 'SAT_Zone_XT_LVD'

				--DATA ENTITY
				--create vault data entity if they do not exist
				INSERT INTO DC.DataEntity(DataEntityname, SchemaID, CreatedDT, IsActive)
				SELECT ssd.satelliteName, @TargetSchemaID, getdate(), 1
				FROM @StageSatelliteDetail ssd
				WHERE NOT EXISTS
				(
					SELECT DataEntityName FROM DC.DataEntity AS de
					WHERE de.DataEntityName = ssd.SatelliteName

				)

				


				
				--update temp table with newly added dataentities into datavault
				UPDATE @StageSatelliteDetail
				SET SatteliteVaultDataEntityID = de.DataEntityID
				FROM DC.DataEntity de
				LEFT JOIN
				@StageSatelliteDetail ssd
				ON ssd.SatelliteName = DE.DataEntityName
				WHERE SchemaID = @TargetSchemaID
				
				--TEST
				--select * from @StageSatelliteDetail
				
				
				--create datavault fields if they do not exist
                insert into dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
                select replace(f.fieldname,'BKHash', 'HK_' + IsNull(ssd.BKFriendlyName, 'NoBKFriendlyName')), f.datatype, f.[maxlength], f.[precision], f.[scale]
				,ISNULL( f.isprimarykey, 0) ASisprimarykey , ISNULL(f.isforeignkey,0) AS isforeignkey
				, 1 AS FieldSortOrder, GETDATE() AS CreatedDT, 1 AS IsActive
				, ssd.SatteliteVaultDataEntityID
                from dc.field f
                left join @StageSatelliteDetail ssd
                on f.dataentityid = ssd.SatelliteTargetDataEntityID
                left join dc.field f1 on f1.fieldname = replace(f.fieldname,'BKHash', 'HK_' + IsNull(ssd.BKFriendlyName, 'NoBKFriendlyName')) 
				AND f1.dataentityID = ssd.SatteliteVaultDataEntityID
                where ssd.satellitetargetdataentityid is not null
                and f1.dataentityid is null
                and f.fieldname = 'bkhash'
               

			     --create hk_ field if not exist
                insert into dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
                select 'LoadDT' AS FieldName, f.datatype, f.[maxlength], f.[precision], f.[scale]
				,ISNULL( f.isprimarykey, 0) ASisprimarykey , ISNULL(f.isforeignkey,0) AS isforeignkey
				, 2 AS FieldSortOrder, GETDATE() AS CreatedDT, 1 AS IsActive
				, ssd.SatteliteVaultDataEntityID
                from dc.field f
                inner join @StageSatelliteDetail ssd
                on f.dataentityid = ssd.SatelliteTargetDataEntityID
                left join dc.field f1 on f1.fieldname = f.fieldname AND f1.dataentityID = ssd.SatteliteVaultDataEntityID
                where ssd.satellitetargetdataentityid is not null
              and f1.dataentityid is null
               and f.fieldname = 'LoadDT'

			   -- create LoadEndDT
			    insert into dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
			    select 'LoadEndDT' AS FieldName, 'datetime2' AS datatype, 8 AS [maxlength], 27 AS [precision], 7 AS [scale]
				,0 as isprimarykey, 0 as isforeignkey
			   , 3 AS FieldSortOrder
			   , GETDATE() AS [CreatedDT], 1 AS IsActive   
			   , ssd.SatteliteVaultDataEntityID
                from @StageSatelliteDetail ssd
        
			     --create hk_ field if not exist
                insert into  dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
                select 'RecSrcDataEntityID' AS FieldName, f.datatype, f.[maxlength], f.[precision], f.[scale]
				,ISNULL( f.isprimarykey, 0) ASisprimarykey , ISNULL(f.isforeignkey,0) AS isforeignkey
				, 4 AS FieldSortOrder, GETDATE() AS CreatedDT, 1 AS IsActive
				, ssd.SatteliteVaultDataEntityID
                from dc.field f
                inner join @StageSatelliteDetail ssd
                on f.dataentityid = ssd.SatelliteTargetDataEntityID
                left join dc.field f1 on f1.fieldname = f.fieldname AND f1.dataentityID = ssd.SatteliteVaultDataEntityID
                where ssd.satellitetargetdataentityid is not null
               and f1.dataentityid is null
               and f.fieldname = 'RecSrcDataEntityID'


			     --create hk_ field if not exist
                 insert into  dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
                select 'HashDiff' AS FieldName, f.datatype, f.[maxlength], f.[precision], f.[scale]
				,ISNULL( f.isprimarykey, 0) ASisprimarykey , ISNULL(f.isforeignkey,0) AS isforeignkey
				, 5 AS FieldSortOrder, GETDATE() AS CreatedDT, 1 AS IsActive
				, ssd.SatteliteVaultDataEntityID
                from dc.field f
                inner join @StageSatelliteDetail ssd
                on f.dataentityid = ssd.SatelliteTargetDataEntityID
                left join dc.field f1 on f1.fieldname = f.fieldname AND f1.dataentityID = ssd.SatteliteVaultDataEntityID
                where ssd.satellitetargetdataentityid is not null
               and f1.dataentityid is null
               and f.fieldname = 'HashDiff'

			   --create hk_ field if not exist
                insert into  dc.field(fieldname, datatype, [maxlength], [precision], [scale], isprimarykey, isforeignkey, FieldSortOrder, CreatedDT, IsActive, dataentityid)
                select f.FieldName AS FieldName, f.datatype, f.[maxlength], f.[precision], f.[scale]
				,ISNULL( f.isprimarykey, 0) ASisprimarykey , ISNULL(f.isforeignkey,0) AS isforeignkey
				, f.FieldSortOrder + 1 AS FieldSortOrder, GETDATE() AS CreatedDT, 1 AS IsActive
				, ssd.SatteliteVaultDataEntityID
                from dc.field f
                inner join @StageSatelliteDetail ssd
                on f.dataentityid = ssd.SatelliteTargetDataEntityID
                left join dc.field f1 on f1.fieldname = f.fieldname AND f1.dataentityID = ssd.SatteliteVaultDataEntityID
                where ssd.satellitetargetdataentityid is not null
               and f1.dataentityid is null
               and f.fieldname NOT IN ('bkhash', 'HashDiff', 'LoadDT', 'RecSrcDataEntityID', 'LoadEndDT')
                

				

                --create linieage from stage to datavault
				-- needs to be refined for an insert and too not duplicate so left join again
                insert into dc.fieldrelation(SourceFieldID, TargetFieldID, FieldRelationTypeID, TransformDescription, CreatedDT, ModifiedDT, IsActive)
                select f.fieldID, f1.fieldID, 2, NULL, getdate(), NULL, 1 from 
                dc.field f
                left join @StageSatelliteDetail ssd on ssd.SatelliteTargetDataEntityID = f.dataentityid
                left join dc.field f1 on f1.dataentityid = ssd.SatteliteVaultDataEntityID and f.fieldname = f1.fieldname 
                left join dc.fieldrelation fr on fr.SourceFieldID = f.fieldID and fr.TargetFieldID = f1.fieldID 
                --where f1.dataentityid is not null 
                where ssd.SatelliteTargetDataEntityID is not null
                and f1.fieldname is not null
                and fr.SourceFieldID is null

 
                --create linieage from stage to datavault for hk_ field
                insert into dc.fieldrelation(SourceFieldID, TargetFieldID, FieldRelationTypeID, TransformDescription, CreatedDT, ModifiedDT, IsActive)
                select f.fieldID, f1.fieldID, 2, NULL, getdate(), NULL, 1 from  
                dc.field f
                left join @StageSatelliteDetail ssd on ssd.SatelliteTargetDataEntityID = f.dataentityid
                left join dc.field f1 on f1.dataentityid = ssd.SatteliteVaultDataEntityID and replace(f.fieldname,'BKHash', 'HK_' + IsNull(ssd.BKFriendlyName, 'NoBKFriendlyName')) = f1.fieldname 
                left join dc.fieldrelation fr on fr.SourceFieldID = f.fieldID and fr.TargetFieldID = f1.fieldID 
                --where f1.dataentityid is not null 
                where ssd.SatelliteTargetDataEntityID is not null
                and f.fieldname = 'bkhash'
                and fr.SourceFieldID is null

END

GO
