SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
    Who? Emile Fraser
    Why? Bulk Loading/Load Testing of Stage Tables
    How? 
        
        DECLARE @Today DATETIME2(7) = (SELECT GETDATE())
        DECLARE @IsInitialLoad BIT = 1
        DECLARE @IsTestLoad BIT = 0
        DECLARE @DatabaseName VARCHAR(150) = 'DEV_Stage'
        
        EXEC [DMOD].[sp_execute_AllLoads_WhileLoop] @Today, @IsInitialLoad, @IsTestLoad, @DatabaseName
*/


CREATE    PROCEDURE [DMOD].[sp_execute_AllLoads_WhileLoop_TOBEDELETED]
    @Today VARCHAR(100), @IsInitialLoad BIT, @IsTestLoad BIT, @DatabaseName VARCHAR(150)
AS


DROP TABLE IF EXISTS #LoadErrorLog
CREATE  TABLE #LoadErrorLog
(LoadConfigID int ,TargetDatabaseName varchar(100),TargetSchemaName varchar(100), TargetDataEntityName varchar(100), ErrorMessage varchar(MAX) )


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
DECLARE @IsInitilLoad_NV NVARCHAR(1) = CONVERT(NVARCHAR(27), @IsInitialLoad)
DECLARE @IsTestLoad_NV NVARCHAR(1) = CONVERT(NVARCHAR(27), @IsTestLoad)
--SELECT @Today_NV, @IsInitialLoad,@IsTestLoad


DROP TABLE IF EXISTS ##LoadLoop 


CREATE TABLE ##LoadLoop(LoadId INT IDENTITY(1,1), LoadConfigID INT, Target_DatabaseName VARCHAR(150), Target_SchemaName VARCHAR(150), Target_DataEntityName VARCHAR(150), 
                                    LoadClassification VARCHAR(150) , LoadTypeCode VARCHAR(150))


-- Run all the Loads
--DECLARE load_cursor CURSOR FOR   
DECLARE @LoadId  INT 


INSERT INTO ##LoadLoop
SELECT 
    LoadConfigID
,    Target_DB AS Target_DatabaseName
,    Target_SchemaName AS Target_SchemaName
,    Target_DEName AS Target_DataEntityName
,    REPLACE(REPLACE(REPLACE(LoadTypeCode, DataEntityNamingSuffix, ''), 'Stage', ''), 'DataVault','') AS LoadClassification
, LoadTypeCode
FROM DMOD.vw_LoadConfig AS lc --DMOD.vw_LoadConfig AS lc
WHERE config_IsActive = 1
AND Target_DB = @DatabaseName
--AND Target_DEName <> 'DV_PurchaseOrderLine_D365_KEYS'
--AND Target_DEName <> 'DV_SalesOrderLine_D365_KEYS' 


DECLARE @MaxLoadLoadID INT = (SELECT MAX(LoadID) FROM ##LoadLoop)
DECLARE @CurrentLoadID INT = 1



--OPEN load_cursor  
  
--FETCH NEXT FROM load_cursor   
--INTO @LoadConfigID, @Target_DatabaseName, @Target_SchemaName, @Target_TableName, @LoadClassification
  
--WHILE @@FETCH_STATUS = 0  
WHILE (@CurrentLoadID <= @MaxLoadLoadID)
BEGIN  
            SET @LoadId  = (SELECT LoadID FROM ##LoadLoop WHERE LoadId = @CurrentLoadID)
            SET @LoadConfigID= (SELECT LoadConfigID FROM ##LoadLoop WHERE LoadId = @LoadId)
            SET @Target_DatabaseName = (SELECT Target_DatabaseName FROM ##LoadLoop WHERE LoadId = @LoadId)
            SEt @Target_SchemaName = (SELECT Target_SchemaName FROM ##LoadLoop WHERE LoadId = @LoadId)
            set @Target_TableName = (SELECT Target_DataEntityName FROM ##LoadLoop WHERE LoadId = @LoadId)
            set @LoadClassification = (SELECT LoadClassification FROM ##LoadLoop WHERE LoadId = @LoadId)




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
                INSERT INTO #LoadErrorLog
                VALUES 
                (@LoadConfigID ,@Target_DatabaseName,@Target_SchemaName, @Target_TableName,'Either TargetDatabaseName/TargetSchemaName/TargetTableName is null')
            END
 
            IF OBJECT_ID(@Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName, N'U') IS NOT NULL
            BEGIN


                -- Truncate Table and Corresponding Hist Tables 
                IF (@IsInitialLoad = 1 OR @LoadClassification = 'FullLoad')
                BEGIN


                    DECLARE @TruncateStatement nvarchar(max) = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.[' + @Target_TableName + ']'
                    
                    EXEC  @RC = sp_executesql @TruncateStatement
                    IF(@RC = 0)
                    BEGIN
                        INSERT INTO #LoadErrorLog
                        VALUES
                        (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'SUCCESS')
                        PRINT(@TruncateStatement)
                        PRINT(CHAR(9) + CHAR(9) + 'SUCCESS!')
                    END
                    ELSE
                    BEGIN
                        INSERT INTO #LoadErrorLog
                        VALUES
                        (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'****************** FAILURE (Does table exists?) ****************** ')


                        PRINT(@TruncateStatement)
                        PRINT(CHAR(9) + CHAR(9) + '****************** FAILURE (Does table exists?) ****************** ')
                    END
                    
                    SET @TruncateStatement = 'TRUNCATE TABLE ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.[' + @Target_TableName + '_Hist]'            
                    EXEC @RC =  sp_executesql @TruncateStatement
                    IF(@RC = 0)
                    BEGIN
                        INSERT INTO #LoadErrorLog
                        VALUES
                        (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'SUCCESS')


                        PRINT(@TruncateStatement)
                        PRINT(CHAR(9) + CHAR(9) + 'SUCCESS!')
                    END
                    ELSE
                    BEGIN
                        INSERT INTO #LoadErrorLog
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
                    INSERT INTO #LoadErrorLog
                    VALUES
                    (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! There is not a Load Procedure in Stage for LoadConfigID: ' + CONVERT(VARCHAR(MAX), @LoadConfigID))
                    PRINT('ERROR! There is not a Load Procedure in Stage for LoadConfigID: ' + CONVERT(VARCHAR(MAX), @LoadConfigID))
                END
                ELSE
                BEGIN
                    SET @ProcSQL = 'EXEC ' + @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL  + ' ' + ' @Today, @IsInitialLoad, @IsTestLoad'


                    PRINT(@ProcSQL)


                    EXECUTE @RC = sp_executesql   
                          @ProcSQL,
                          N' @Today NVARCHAR(100), @IsInitialLoad  NVARCHAR(1), @IsTestLoad  NVARCHAR(1)',  
                          @Today = @Today_NV, @IsInitialLoad = @IsInitialLoad, @IsTestLoad = @IsTestLoad
                    
                    IF(@RC = 0)
                    BEGIN
                        INSERT INTO #LoadErrorLog
                        VALUES
                        (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))
                        PRINT(CHAR(9) + CHAR(9) + 'SUCESS!')
                    END
                    ELSE
                    BEGIN
                        INSERT INTO #LoadErrorLog
                        VALUES
                        (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'SUCESS!')


                        PRINT(CHAR(9) + CHAR(9) +'ERROR! The following procedure failed at runtime ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @ProcSQL))
                    END
                END



            END
            ELSE
            BEGIN
                INSERT INTO #LoadErrorLog
                VALUES
                (@LoadConfigID,@Target_DatabaseName,@Target_SchemaName , @Target_TableName,'ERROR! The following table does not exists in the StageArea: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))


                PRINT(CHAR(9) + CHAR(9) + 'ERROR! The following table does not exists in the StageArea: ' + CONVERT(VARCHAR(MAX), @Target_DatabaseName + '.' + @Target_SchemaName + '.' + @Target_TableName))
            END
        


    SET @CurrentLoadID = @CurrentLoadID + 1


END   


--CLOSE load_cursor
--DEALLOCATE load_cursor
 















 


GO
