SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Loading/Load Testing of DV Tables
	How? 
		
		DECLARE @Today DATETIME2(7) = (SELECT GETDATE())
		DECLARE @IsTestLoad BIT = 0
		DECLARE @IsTruncateDataVaultTablesBeforeLoading BIT = 0
		DECLARE @DatabaseName VARCHAR(150) = 'DEV_DataVault'
		
		EXEC DMOD.sp_execute_AllLoads_DataVault @Today, @IsTestLoad, @DatabaseName,  @IsTruncateDataVaultTablesBeforeLoading 
*/

CREATE      PROCEDURE [DMOD].[sp_execute_AllLoads_DataVault]
	@Today VARCHAR(100), @IsTestLoad BIT, @DatabaseName VARCHAR(150), @IsTruncateDataVaultTablesBeforeLoading BIT
AS

DROP TABLE IF EXISTS #LoadErrorLog_DV
CREATE TABLE #LoadErrorLog_DV  
	(
		LoadConfigID int
		,TargetDatabaseName varchar(100)
		,TargetSchemaName varchar(100)
		,TargetDataEntityName varchar(100)
		,ErrorMessage varchar(MAX) 
	)

DECLARE @LoadConfigID INT
DECLARE @Target_DatabaseName varchar(100) 
DECLARE @Target_SchemaName varchar(100) 
DECLARE @Target_TableName varchar(100) 
DECLARE @LoadProcName VARCHAR(250)
DECLARE @LoadClassification varchar(100) 
DECLARE @LoadProcID int 
DECLARE @ProcSQL NVARCHAR(MAX)
DECLare @RC INT
DECLARE @RowsTransferred INT
DECLARE @Today_NV NVARCHAR(27) = CONVERT(NVARCHAR(27), @Today)
DECLARE @IsTestLoad_NV NVARCHAR(1) = CONVERT(NVARCHAR(27), @IsTestLoad)
--SELECT @Today_NV, @IsInitialLoad,@IsTestLoad

-- Run all the Loads
DECLARE load_cursor 
CURSOR FOR   
SELECT 
		LoadConfigID
		,Target_DB AS Target_DatabaseName
		,Target_SchemaName AS Target_SchemaName
		,Target_DEName AS Target_DataEntityName
		,REPLACE(REPLACE(REPLACE(REPLACE(LoadTypeCode, '_' + DataEntityTypeCode, ''), 'Stage', ''), 'DataVault',''), ISNULL(DataEntityNamingSuffix, ''), '') AS LoadClassification
FROM DMOD.vw_LoadConfig AS lc --DMOD.vw_LoadConfig AS lc
WHERE config_IsActive = 1
AND Target_DB = @DatabaseName


OPEN load_cursor  
  
FETCH NEXT FROM load_cursor   
INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
			PRINT('##############################################################################################################################')
			PRINT('LoadConfig: ' + CONVERT(VARCHAR, @LoadConfigID) + ' (' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_DatabaseName)) + '.' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_SchemaName)) + '.' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_TableName)) + ')'
					) 
			PRINT('##############################################################################################################################')

			-- Test if Stage Table Exists 
			IF OBJECT_ID(@Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName, N'U') IS NULL
			BEGIN
			INSERT INTO #LoadErrorLog_DV
			VALUES 
			(@LoadConfigID ,@Target_DatabaseName,@Target_SchemaName, @Target_TableName,'Either TargetDatabaseName/TargetSchemaName/TargetTableName is null')
			END

			IF OBJECT_ID(@Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName, N'U') IS NOT NULL
			BEGIN

				-- Truncate Table and Corresponding Hist Tables 
				IF (@IsTruncateDataVaultTablesBeforeLoading = 1)
				BEGIN

					DECLARE @TruncateStatement nvarchar(max) = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName
					
					EXEC  @RC = sp_executesql @TruncateStatement
					IF(@RC = 0)
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'SUCCESS')
						PRINT(@TruncateStatement)
						PRINT(CHAR(9) + CHAR(9) + 'SUCCESS!')
					END
					ELSE
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'****************** FAILURE (Does table exists?) ****************** ')
						PRINT(@TruncateStatement)
						PRINT(CHAR(9) + CHAR(9) + '****************** FAILURE (Does table exists?) ****************** ')
					END								
				END

				-- Get the Proc to Execute
				SET @ProcSQL = (SELECT DMOD.udf_get_DataVaultProcName(@LoadConfigID))
				IF (ISNULL(@ProcSQL,'') = '')
				BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! There is not a Load Procedure in DataVault for LoadConfigID: ')

					PRINT('ERROR! There is not a Load Procedure in DataVault for LoadConfigID: ' + CONVERT(VARCHAR(MAX), @LoadConfigID))
				END
				ELSE
				BEGIN
					SET @ProcSQL = 'EXEC ' + QUOTENAME(@Target_DatabaseName) + '.' + QUOTENAME(@Target_SchemaName) + '.' + @ProcSQL  + ' ' + ' @Today, @IsTestLoad'

					PRINT(@ProcSQL)

					EXECUTE @RC = sp_executesql   
						  @ProcSQL,
						  N' @Today NVARCHAR(100), @IsTestLoad  NVARCHAR(1)',  
						  @Today = @Today_NV, @IsTestLoad = @IsTestLoad
					
					IF(@RC = 0)
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! There is not a Load Procedure in Stage for LoadConfigID: ')
						PRINT(CHAR(9) + CHAR(9) + 'SUCESS!')
					END
					ELSE
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following procedure failed at runtime ')

						PRINT(CHAR(9) + CHAR(9) +'ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))
					END
				END


			END
			ELSE
			BEGIN
				INSERT INTO #LoadErrorLog_DV
				VALUES
				(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following table does not exists in the DataVault: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
				PRINT(CHAR(9) + CHAR(9) + 'ERROR! The following table does not exists in the DataVault: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
			END
		

	FETCH NEXT FROM load_cursor   
	INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification

END   

SELECT	*
FROM	#LoadErrorLog_DV le
	INNER JOIN ETL.LoadConfig lc
		ON le.LoadConfigID = lc.LoadConfigID

CLOSE load_cursor

DEALLOCATE load_cursor



GO
