SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Generation of DLTs for Stage Tables
	How? 

		DECLARE @Author VARCHAR(100) = 'Emile Fraser'
		EXEC DataManager.DMOD.[sp_generate_All_DynamicLoadTemplates_Vault] @Author, 'PROD', 0

		DECLARE @Author VARCHAR(100) = 'Frans Germishuizen'
		EXEC DataManager.DMOD.[sp_generate_All_DynamicLoadTemplates_Vault] @Author, 'DEV', 0

*/

CREATE PROC  [DMOD].[sp_generate_All_DynamicLoadTemplates_Vault] 
	  @Author VARCHAR(100) 
	, @Environment varchar(10) -- DEV, QA, PROD
	, @IsDebug BIT

AS

-- MASTER VARIABLE BLOCK
--DECLARE @Author VARCHAR(100) = 'Frans Germishuizen'
DECLARE @Target_TableName VARCHAR(100);
DECLARE @LoadProcID INT;
DECLARE @ProcSQL NVARCHAR(MAX);
DECLARE	@RC INT
	,	@message VARCHAR(MAX)
DECLARE @loadconfigid INT
		, @loadtypeid INT
		, @LoadTypeCode VARCHAR(250)
		, @LoadTypeName VARCHAR(250)
		, @source_dataentityid INT
		, @source_dataentityname VARCHAR(250)
		, @source_schemaname VARCHAR(50)
		, @target_dataentityid INT
		, @target_dataentityname VARCHAR(250)
		, @target_schemaname VARCHAR(50);

CREATE TABLE #ErrorLog
(
	ID int IDENTITY(1,1)  NOT NULL
	, LoadConfigID varchar(50)
	, Result varchar(100)
	, ErrorText varchar(max)
)

-- KEYS
DECLARE load_cursor_keys 
CURSOR FOR 

SELECT lc.LoadConfigID, 
        lc.LoadTypeID, 
		lc.LoadTypeCode,
        lc.SourceDataEntityID AS SourceDataEntityID, 
        lc.Source_DEName AS SourceDataEntityName,
        lc.Target_SchemaName,
		lc.Target_DEName AS TargetDataEntityName
FROM DataManager.DMOD.vw_LoadConfig AS lc
	INNER JOIN DataManager.DC.DataEntityType AS de
		ON de.DataEntityTypeID = lc.DataEntityTypeID
WHERE 1=1
	AND de.IsAllowedInRawVault = 1
	AND lc.config_IsActive = 1
	AND lc.loadtype_IsActive = 1 
	AND lc.Source_DEName = 'DV_Stock_D365_LVD'
		
			OPEN load_cursor_keys

			FETCH NEXT FROM load_cursor_keys 
			INTO @loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname
			
			WHILE @@FETCH_STATUS = 0
				BEGIN

				-- Get Final Table Name
				SET @Target_TableName = QUOTENAME(@target_dataentityname);
				--SELECT @Target_TableName

				SET @message = ('Generating Load Proc for LoadConfig = ' + CONVERT(VARCHAR, @LoadConfigID) + ' (' + @source_dataentityname + ' to ' + @target_dataentityname + ')')
				PRINT(@message)

				-- Generate DLT
				EXECUTE @RC = DMOD.sp_generate_ddl_LoadStoredProcs 
						@LoadConfigID, 
						@Author,
						@IsDebug

				IF(@RC = 0)
				BEGIN
					SET @message = ('Load Proc for SUCCESSFULLY GENERATED for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
					PRINT(CHAR(9) + @message)
				END
				ELSE
				BEGIN 
					SET @message = ('ERROR GENERATING KEYS Load Proc for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
					PRINT(@message)
					PRINT(@@ERROR)
				END
		
			--GET DLT GENERATED PROCID
			SET @LoadProcID = (SELECT LoadProcID fROM DataManager.DMOD.LoadProcExports  WHERE LoadConfigID = @LoadConfigID AND IsLastRun = 1)

			DECLARE @sqlProc_Validate NVARCHAR(MAX)
			DECLARE @sqlProc_Deploy NVARCHAR(MAX) = (SELECT PScript FROM DataManager.DMOD.LoadProcExports WHERE LoadProcID = @LoadProcID)
			
			
			PRINT('Deploying Load Proc to DataVault for LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))

			DECLARE @db sysname --= N'DEV_StageArea'; --TODO: Make this dynamic with parameters 

			SELECT	@db = d.DatabaseName
					--, dp.DatabasePurposeCode
					--, dp.DatabasePurposeName
					--, env.DetailTypeCode AS DatabaseEnvironmentCode
			FROM	DC.[Database] d
				INNER JOIN [DC].tvf_get_DatabasesWithPurpose('DataVault') dp
					ON d.DatabasePurposeID = dp.DatabasePurposeID
						AND d.DatabaseID = dp.DatabaseID
				INNER JOIN TYPE.tvf_GenericDetailTypes('DB_ENV') env
					ON env.DetailID = d.DatabaseEnvironmentTypeID
			WHERE	env.DetailTypeCode = @Environment

			--print(@db)
			

			DECLARE @exec_Deploy nvarchar(max) = QUOTENAME(@db) + N'.sys.sp_executesql'
			DECLARE @exec_validation nvarchar(max) = QUOTENAME(@db) + N'.sys.sp_executesql'
					--@sql  nvarchar(max) = N'SELECT DB_NAME();';
					--PRINT(@exec_Deploy)
					--PRINT(@exec_validation)
			--PRINT QUOTENAME(@db) + N'.sys.sp_executesql'

			--PRINT @sqlProc2

			BEGIN TRY
				
				--SELECT @exec_Deploy, @sqlProc_Deploy
				
			    EXEC @exec_Deploy @sqlProc_Deploy
				--SELECT @sqlProc_Deploy

				--TODO:UPDATE FUNCTION TO RETURN VAULT PROC NAME
				DECLARE @ProcName varchar(200) = (Select [DMOD].[udf_get_DataVaultProcName](@LoadConfigID))

				SET @sqlProc_Validate = 'SELECT	name
										 FROM	['+ @db +'].sys.procedures p
										 WHERE	QUOTENAME(p.name) = ''' + @ProcName +''''
				
				--PRINT @sqlProc_Validate

				DROP TABLE IF EXISTS #Exec
				CREATE TABLE #Exec
				(
					Result varchar(100)
				)
				
				INSERT INTO #Exec (Result)
				EXEC @exec_validation @sqlProc_Validate

				IF ((SELECT count(1) FROM #Exec) > 0)
				BEGIN
					INSERT INTO #ErrorLog (LoadConfigID, Result, ErrorText)
					SELECT @LoadConfigID, 'Success', NULL

					PRINT('SUCCESSFULLY DEPLOYED LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
				END
				ELSE
					BEGIN
						INSERT INTO #ErrorLog (LoadConfigID, Result, ErrorText)
						SELECT @LoadConfigID, 'Failed - Proc not Found', NULL

						PRINT('DEPLOYMENT FAILED LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))
					END

			END TRY
			BEGIN CATCH
			
				INSERT INTO #ErrorLog (LoadConfigID, Result, ErrorText)
				SELECT @LoadConfigID, 'Failed - Deployment', ERROR_MESSAGE()

				
				PRINT('DEPLOYMENT FAILED LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID))

			END CATCH
			--SET @sqlProc = 'USE DEV_StageArea' + CHAR(13) --+ 'GO' + CHAR(13)
			--PRINT(@sqlProc)
			--EXEC(@sqlProc)


			--SET @sqlProc = @sqlProc2		
			----PRINT(@sqlProc)
			--PRINT(@sqlProc)
			--EXEC(@sqlProc)

			--SET @sqlProc = 'USE DataManager'
			--PRINT(@sqlProc)
			--EXEC(@sqlProc) 



		   FETCH NEXT FROM load_cursor_keys 
		   INTO @loadconfigid, @loadtypeid, @LoadTypeCode, @source_dataentityid, @source_dataentityname, @target_schemaname, @target_dataentityname

		END

	CLOSE load_cursor_keys
	DEALLOCATE load_cursor_keys

SELECT	*
FROM	#ErrorLog er
	inner JOIN DMOD.vw_LoadConfig lc
		ON er.LoadConfigID = lc.LoadConfigID

GO
