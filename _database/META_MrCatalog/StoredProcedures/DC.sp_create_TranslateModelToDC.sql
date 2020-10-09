SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-09-09
-- Description:	Kick off the unified process to translate the model in the DMOD tables into the DC tables.
-- =============================================

/*
Sample Execution

select	*
from	DC.[Database]

-- STAGE PROD = 11
-- VAULT PROD = 12

EXECUTE [DC].[sp_create_TranslateModelToDC]  11, 12

*/


CREATE PROCEDURE [DC].[sp_create_TranslateModelToDC] 
	@Target_Stage_DatabaseID INT
	, @Target_Vault_DatabaseID INT
AS
--BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--declare		@Target_Stage_DatabaseID INT = 3
	--			, @Target_Vault_DatabaseID INT = 8

	/*
	-- Wait for dealy added to make sure the person selected the correct target database
	-- and gives them time to stop the procedure before it start running
	-- because it is destructive and will delete the objects in the DC, in the target database

	select	'Are you sure this is the correct Target Stage & Vault Databases that you want to delete and then translate into?'

	select	DatabaseName AS Stage_DatabaseName
	from	DC.[Database] d	
	WHERE	d.DatabaseID = @Target_Stage_DatabaseID

	select	DatabaseName AS Vault_DatabaseName
	from	DC.[Database] d	
	WHERE	d.DatabaseID = @Target_Vault_DatabaseID

	select	'If it is, this procedure will continue in 20 seconds, else, you have 20 seconds to stop this procedure.'
	GO

	waitfor delay '00:00:20'

	select	'Processing starting...'
	*/


	-- Validate that the target database that were passed in are valid stage and vault db's
	DECLARE @ValidStage varchar(50)
			, @ValidVault varchar(50)

	--declare		@Target_Stage_DatabaseID INT = 2
	--			, @Target_Vault_DatabaseID INT = 8

	SELECT	@ValidStage	= dp.DatabasePurposeCode
	FROM	DC.[Database] d
		INNER JOIN DC.DatabasePurpose dp 
			ON d.DatabasePurposeID = dp.DatabasePurposeID
	WHERE	d.DatabaseID = @Target_Stage_DatabaseID

	SELECT	@ValidVault	= dp.DatabasePurposeCode
	FROM	DC.[Database] d
		INNER JOIN DC.DatabasePurpose dp 
			ON d.DatabasePurposeID = dp.DatabasePurposeID
	WHERE	d.DatabaseID = @Target_Vault_DatabaseID

	IF (@ValidStage <> 'StageArea' OR @ValidVault <> 'DataVault') 
		BEGIN
			PRINT 'The stage or vault target database id''s supplied are not valid'

			SELECT 'The stage or vault target database id''s supplied are not valid'

			SELECT	'Stage Database Selected'
					, dp.DatabasePurposeCode, d.DatabaseName
			FROM	DC.[Database] d
				INNER JOIN DC.DatabasePurpose dp 
					ON d.DatabasePurposeID = dp.DatabasePurposeID
			WHERE	d.DatabaseID = @Target_Stage_DatabaseID

			SELECT	'Vault Database Selected'
					, dp.DatabasePurposeCode, d.DatabaseName
			FROM	DC.[Database] d
				INNER JOIN DC.DatabasePurpose dp 
					ON d.DatabasePurposeID = dp.DatabasePurposeID
			WHERE	d.DatabaseID = @Target_Vault_DatabaseID
		END
	ELSE
		BEGIN
		--================================================================================================================
		--Delete all the objects from the 
		--================================================================================================================

		------------------------------------------------------------------------------------------------------------------
		-- Delete all Schema's, DataEntities and Fields
		-----------------------------------------------------------------------------------------------------------------
		delete
		from	DC.Field
		where	DataEntityID IN (
									select	DataEntityID
									from	DC.DataEntity
									where	SchemaID IN (
															select	SchemaID
															from	DC.[Schema]
															where	DatabaseID IN (	select	DatabaseID
																					from	DC.[Database]
																					where	Databaseid IN (@Target_Stage_DatabaseID, @Target_Vault_DatabaseID)
																				  )
														)
								)
	
		delete
		from	DC.DataEntity
		where	SchemaID IN (
								select	SchemaID
								from	DC.[Schema]
								where	DatabaseID IN (	select	DatabaseID
														from	DC.[Database]
														where	Databaseid IN (@Target_Stage_DatabaseID, @Target_Vault_DatabaseID)
													  )
							)
		delete
		from	DC.[Schema]
		where	DatabaseID IN (	select	DatabaseID
								from	DC.[Database]
								where	Databaseid IN (@Target_Stage_DatabaseID, @Target_Vault_DatabaseID)
							  )

		-----------------------------------------------------------------------------------------------------------------
		--Delete all invalid field relations
		-----------------------------------------------------------------------------------------------------------------
		DELETE fr FROM DC.FieldRelation fr LEFT JOIN DC.Field f ON f.FieldID = fr.SourceFieldID WHERE f.FieldID IS NULL
		DELETE fr FROM DC.FieldRelation fr LEFT JOIN DC.Field f ON f.FieldID = fr.TargetFieldID WHERE f.FieldID IS NULL

		--================================================================================================================
		--Translate the DMOD into the DC
		--================================================================================================================

		PRINT 'Translation process starting'

		DECLARE @HubID INT
				, @HubName varchar(100)
  
		DECLARE cursor_DCTranslate CURSOR FOR
			SELECT	HubID
			FROM	DMOD.Hub h
			WHERE	h.IsActive = 1
			ORDER BY HubID;  
  
		OPEN cursor_DCTranslate  
  
		FETCH NEXT FROM cursor_DCTranslate   
		INTO @HubID 
  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
		
			SELECT	@HubName = h.HubName
			FROM	DMOD.Hub h
			WHERE	h.HubID	= @HubID

			-- Create Stage in DC
			PRINT 'Starting STAGE Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

				EXECUTE [DC].[sp_CreateStageTableInDC] @HubID, @Target_Stage_DatabaseID

			PRINT 'Completed STAGE Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

			-- Create Hub in DC
			PRINT 'Starting HUB Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

				EXECUTE [DC].[sp_CreateHubTableInDC] @HubID, @Target_Vault_DatabaseID

			PRINT 'Completed HUB Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

			-- Create Satellite in DC
			PRINT 'Starting Satellite Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

				EXECUTE [DC].[sp_CreateSatelliteTableInDC] @HubID, @Target_Vault_DatabaseID

			PRINT 'Completed Satellite Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

			-- Create PKFK in DC
			PRINT 'Starting PKFK Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

				EXECUTE [DC].[sp_CreatePKFKLinkTableInDC] @HubID, @Target_Vault_DatabaseID

			PRINT 'Completed PKFK Translation... ' + Convert(varchar(50), @HubID) + ' - ' + Convert(varchar(50), @HubName)

			-- Create HLINK in DC (NOT READY YET)
			----EXECUTE [DC].[sp_CreateHierarchicalLinkTableInDC] @HubID, @TargetDatabaseID

			-- Create Many-to-Many in DC (NOT READY YET)
			----EXECUTE [DC].[sp_CreateManyToManyLinkTableInDC] @HubID, @TargetDatabaseID

			-- Create Same as link in DC (NOT READY YET)
			----EXECUTE [DC].[sp_CreateSameAsLinkStageTableInDC] @HubID, @TargetDatabaseID
			----EXECUTE [DC].[sp_CreateSameAsLinkVaultTableInDC] @HubID, @TargetDatabaseID
		
			-- Create Transactional Link in DC (NOT READY YET)
			----EXECUTE [DC].[sp_CreateTLinkTableInDC] @HubID, @TargetDatabaseID
			----EXECUTE [DC].[sp_CreateTransactionalLinkSatelliteTableInDC] @HubID, @TargetDatabaseID
		
			FETCH NEXT FROM cursor_DCTranslate   
			INTO @HubID 
		END   

		CLOSE cursor_DCTranslate;  
		DEALLOCATE cursor_DCTranslate;

		PRINT 'Translation process complete!'
		PRINT '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
		PRINT '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	END

	PRINT 'Load Configuration Genartion started...'

	EXECUTE [DMOD].[sp_Generate_LoadConfig]
	
	PRINT 'Load Configuration Genartion process complete!'
--END


GO
