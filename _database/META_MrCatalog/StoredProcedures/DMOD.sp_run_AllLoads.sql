SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	Who? Emile Fraser
	Why? Bulk Loading/Load Testing of Stage Tables
	How? 
		
		DECLARE @Author VARCHAR(100) = 'Emile Fraser'
		DECLARE @IsInitialLoad BIT = 1
		DECLARE @IsTestLoad BIT = 1
		
		EXEC DMOD.sp_run_AllLoads @Author, @IsInitialLoad, @IsTestLoad
*/

CREATE   PROCEDURE [DMOD].[sp_run_AllLoads]
	@Author VARCHAR(100), @IsInitialLoad BIT, @IsTestLoad BIT
AS

DECLARE @LoadConfigID INT
DECLARE @Target_DatabaseName varchar(100) 
DECLARE @Target_SchemaName varchar(100) 
DECLARE @Target_TableName varchar(100) 
DECLARE @LoadProcName VARCHAR(250)
DECLARE @LoadClassification varchar(100) 
DECLARE @LoadProcID int 
DECLARE @ProcSQL NVARCHAR(MAX)
DECLare @RC INT
DECLARE @Today NVARCHAR(MAX) = '2019-07-14 00:00:00.0000000'

-- Run all the Loads
DECLARE load_cursor CURSOR FOR   
SELECT 
	LoadConfigID
,	Target_DB AS Target_DatabaseName
,	Target_SchemaName AS Target_SchemaName
,	Target_DEName AS Target_DataEntityName
,	REPLACE(REPLACE(LoadTypeCode, DataEntityNamingPrefix, ''), 'Stage', '') AS LoadClassification
FROM DMOD.vw_LoadConfig_Backup_20190912_850_DONOTDELETE AS lc --DMOD.vw_LoadConfig AS lc
WHERE config_IsActive = 1
AND Target_DB <> 'DEV_DataVault'
AND LoadConfigID = 25


OPEN load_cursor  
  
FETCH NEXT FROM load_cursor   
INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
			PRINT('Currently Running LoadConfigID: ' + CONVERT(VARCHAR, @LoadConfigID))
			PRINT('Loading: ' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_DatabaseName)) + '.' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_SchemaName)) + '.' 
					+ CONVERT(VARCHAR, QUOTENAME(@Target_TableName))
					) 

			-- Test if Stage Table Exists 
			IF OBJECT_ID(@Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName, N'U') IS NOT NULL
			BEGIN

				-- Truncate Table and Corresponding Hist Tables 
				IF (@IsInitialLoad = 1 OR @LoadClassification = 'FullLoad')
				BEGIN

					DECLARE @TruncateStatement nvarchar(max) = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName
					PRINT(@TruncateStatement)
					EXEC sp_executesql @TruncateStatement

					SET @TruncateStatement = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName + '_Hist'
					PRINT(@TruncateStatement)
					EXEC sp_executesql @TruncateStatement
				END

				-- Get the Proc to Execute
				SET @ProcSQL = (SELECT DMOD.udf_get_StageAreaProcName(@LoadConfigID))
				IF (ISNULL(@ProcSQL,'') = '')
				BEGIN
					PRINT('ERROR! There is not a Load Procedure in Stage for LoadConfigID: ' + CONVERT(VARCHAR, @LoadConfigID))
				END
				ELSE
				BEGIN
					SET @ProcSQL = 'EXEC ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL  + ' ' + ' @Today, @IsInitialLoad, @IsTestLoad'
					PRINT(@ProcSQL)

					EXECUTE sp_executesql   
						  @ProcSQL,
						  N' @Today NVARCHAR(100), @IsInitialLoad  NVARCHAR(1), @IsTestLoad  NVARCHAR(1)',  
						  @Today = @Today, @IsInitialLoad = @IsInitialLoad, @IsTestLoad = @IsTestLoad


					EXECUTE @RC = sp_executesql @ProcSQL					
					IF(@RC = 0)
					BEGIN
						PRINT(CONVERT(VARCHAR, @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL) + ' ran successfully.')
					END
					ELSE
					BEGIN
						PRINT('ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR, @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))
					END
				END


			END
			ELSE
			BEGIN
				PRINT('ERROR! The following table does not exists in the StageArea: ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName)
			END
		

	FETCH NEXT FROM load_cursor   
	INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification

END   

CLOSE load_cursor
DEALLOCATE load_cursor

GO
