SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Loading/Load Testing of DV Tables
	How? 

		DECLARE @Today DATETIME2(7) = (SELECT GETDATE())
		DECLARE @IsInitialLoad BIT = 1
		DECLARE @IsTestLoad BIT = 0
		DECLARE @DatabaseName VARCHAR(150) = 'StageArea'
		
		EXEC DMOD.sp_execute_AllLoads_StageArea @Today, @IsInitialLoad, @IsTestLoad, @DatabaseName
*/

CREATE     PROCEDURE [DMOD].[sp_execute_Ensamble_StageArea]
	@Today VARCHAR(100), @IsInitialLoad BIT, @IsTestLoad BIT, @DatabaseName VARCHAR(150)
	, @EnsableSourceName  VARCHAR(150)
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
DECLARE @IsInitialLoad_NV NVARCHAR(1) = CONVERT(NVARCHAR(27), @IsInitialLoad)
DECLARE @IsTestLoad_NV NVARCHAR(1) = CONVERT(NVARCHAR(27), @IsTestLoad)
--SELECT @Today_NV, @IsInitialLoad,@IsTestLoad


DECLARE @DatabasePurpose VARCHAR(50) = (SELECT DatabasePurposeName FROM DC.[Database] AS db INNER JOIN 
											DC.[DatabasePurpose] AS dp ON dp.DatabasePurposeID = db.DatabasePurposeID
												WHERE db.DatabaseName = @DatabaseName)

-- Run all the Loads
DECLARE load_cursor 
CURSOR FOR   
SELECT 
		LoadConfigID
		,Target_DB AS Target_DatabaseName
		,Target_SchemaName AS Target_SchemaName
		,Target_DEName AS Target_DataEntityName
		,REPLACE(REPLACE(REPLACE(REPLACE(LoadTypeCode, '_' + DataEntityTypeCode, ''), 'Stage', ''), 'StageArea',''), ISNULL(DataEntityNamingSuffix, ''), '') AS LoadClassification
FROM DMOD.vw_LoadConfig AS lc
WHERE config_IsActive = 1
AND Source_DEName = @EnsableSourceName
AND Target_DB = @DatabaseName

ORDER BY Target_DataEntityName

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
				IF (@IsInitialLoad = 1)
				BEGIN

					DECLARE @TruncateStatement nvarchar(max) = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName
					PRINT(@TruncateStatement)
					EXEC  @RC = sp_executesql @TruncateStatement

		
					IF(@RC = 0)
					BEGIN
		

						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'Truncate Table SUCCESS')				

						PRINT(@TruncateStatement)
						PRINT(CHAR(9) + CHAR(9) + 'Truncate Table SUCCESS')
					END
					ELSE
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'****************** FAILURE (Does table exists?) ****************** ')
						PRINT(@TruncateStatement)
						PRINT(CHAR(9) + CHAR(9) + '****************** FAILURE (Does table exists?) ****************** ')
					END		
					

					SET @TruncateStatement = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName + '_Hist'
					PRINT(@TruncateStatement)
					EXEC  @RC = sp_executesql @TruncateStatement
					IF(@RC = 0)
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'Truncate Table Hist SUCCESS')
						PRINT(@TruncateStatement)
						PRINT(CHAR(9) + CHAR(9) + 'Truncate Table Hist SUCCESS')
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
				SET @ProcSQL = (SELECT DMOD.udf_get_StageAreaProcName(@LoadConfigID))
				IF (ISNULL(@ProcSQL,'') = '')
				BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! There is not a Load Procedure in StageArea for LoadConfigID: ' + CONVERT(VARCHAR(MAX), @LoadConfigID))

					PRINT('ERROR! There is not a Load Procedure in StageArea for LoadConfigID: ' + CONVERT(VARCHAR(MAX), @LoadConfigID))
				END
				ELSE
				BEGIN
					SET @ProcSQL = 'EXEC ' + QUOTENAME(@Target_DatabaseName) + '.' + QUOTENAME(@Target_SchemaName) + '.' + @ProcSQL  + ' ' + ' @Today, @IsInitialLoad, @IsTestLoad'
					PRINT(@ProcSQL)

					EXECUTE @RC = sp_executesql   
						  @ProcSQL,
						  N' @Today NVARCHAR(100), @IsInitialLoad NVARCHAR(1), @IsTestLoad  NVARCHAR(1)',  
						  @Today = @Today_NV, @IsInitialLoad = @IsInitialLoad, @IsTestLoad = @IsTestLoad

					
					IF(@RC = 0)
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'Table Load SUCESS!')
						PRINT(CHAR(9) + CHAR(9) + 'Table Load SUCESS!')
					END
					ELSE
					BEGIN
						INSERT INTO #LoadErrorLog_DV
						VALUES
						(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))

						PRINT(CHAR(9) + CHAR(9) +'ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))
					END
				END


			END
			ELSE
			BEGIN
				INSERT INTO #LoadErrorLog_DV
				VALUES
				(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following table does not exists in the StageArea: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
				PRINT(CHAR(9) + CHAR(9) + 'ERROR! The following table does not exists in the StageArea: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
			END
		

	FETCH NEXT FROM load_cursor   
	INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification
	
	INSERT INTO #LoadErrorLog_DV
	VALUES
	(@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'Filter SUCCESS! - ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
END   

SELECT	*
FROM	#LoadErrorLog_DV le
	INNER JOIN DMOD.LoadConfig lc
		ON le.LoadConfigID = lc.LoadConfigID

CLOSE load_cursor

DEALLOCATE load_cursor

GO
