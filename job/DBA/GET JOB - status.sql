
CREATE OR ALTER PROCEDURE [#LoggingFunction] 
	@Position      INT
,	@StepName      NVARCHAR(MAX)
,	@EntityName    NVARCHAR(MAX)
,	@Result        BIT           = NULL
,	@MessageReturn NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE 
		@sql_message_template AS NVARCHAR(MAX) = 'For {{Entity}} {{Position}} of {{StepName}} {{was StepResult}}' + CHAR(13) + CHAR(10)

	
    SET @MessageReturn = ' | ' + CONVERT(VARCHAR(30), GETDATE(), 126) + ' | '
    SET @MessageReturn += REPLACE(@sql_message_template, '{{Position}} of', CASE @Position
																			   WHEN 0 THEN 'START'
																			   WHEN 999 THEN 'END'
																			   ELSE 'Step ' + CONVERT(NVARCHAR(MAX), @Position)
																		   END)
	SET @MessageReturn = REPLACE(@MessageReturn, '{{StepName}}', @StepName)
	SET @MessageReturn = REPLACE(@MessageReturn, '{{Entity}}', @EntityName)
	SET @MessageReturn = REPLACE(@MessageReturn, '{{was StepResult}}', CASE
																		   WHEN @Position = 0 THEN ''
																		   WHEN @Result = 0 THEN 'was SUCCESSFUL'
																		   ELSE 'FAILED'
																	   END)
   
END
GO

CREATE OR ALTER PROCEDURE #sp_get_DataLineageProcedures
    @TargetEntityName_Full NVARCHAR(384)
,   @sql_IsDebug BIT = 0
,   @sql_IsExecute BIT = 0
AS  

SET XACT_ABORT, NOCOUNT ONBEGIN TRYBEGIN TRANSACTION  
    -- SQL Dynamic Variables
    DECLARE @sql_statement  NVARCHAR(MAX)
    DECLARE @sql_params NVARCHAR(MAX)
    DECLARE @sql_message NVARCHAR(MAX)
    DECLARE @sql_stepname NVARCHAR(MAX)
    DECLARE @sql_clrf AS NVARCHAR(2) = CHAR(13) + CHAR(10)
    DECLARE @sql_clrf_eos AS NVARCHAR(4) = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    DECLARE @cte_level AS INT = 0

    -- Seperating the Entity Name
    DECLARE @DatabaseName SYSNAME = PARSENAME(@TargetEntityName_Full, 3)
    DECLARE @SchemaName SYSNAME = PARSENAME(@TargetEntityName_Full, 2)
    DECLARE @DataEntityName SYSNAME= PARSENAME(@TargetEntityName_Full, 1)

    DECLARE @CurrentRow INT
    DECLARE @TotalRows INT
    DECLARE @CurrentEntityName NVARCHAR(384)
    DECLARE @CurrentEntitySourceID INT
    DECLARE @CurrentEntityDatabasePurpose NVARCHAR(100)

    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 0, @StepName = 'Jobs Creation', @EntityName = @TargetEntityName_Full, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1)
    END

    -- INTRODUCE RECURSIVE CTE
    -- Get source ect back from destination table
    ;WITH 
    target_cte AS (
        SELECT * 
        FROM DataManager.DMOD.vw_LoadConfig
        WHERE Source_DEName = @DataEntityName
        AND SourceSourceTarget_DB = @DatabaseName
    ), 
    recurse_cte AS (

        SELECT @cte_level AS LevelOfCte, *
        FROM target_cte

        UNION ALL

        SELECT @cte_level + 1 AS LevelOfCte, vlc.*
        FROM target_cte AS tcte
        INNER JOIN DataManager.DMOD.vw_LoadConfig AS vlc
        ON vlc.SourceDataEntityID = tcte.TargetDataEntityID
    )
    SELECT
          ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        , rcte.LevelOfCte AS LevelOfCte
        , rcte.LoadConfigID, rcte.LoadTypeID, rcte.LoadTypeName, rcte.DatabasePurposeCode
        , rcte.TargetDataEntityID, rcte.Target_DEName, rcte.Target_SchemaName, rcte.Target_DB
        , rcte.SourceDataEntityID, rcte.Source_DEName, rcte.Source_SchemaName, rcte.Source_DB        
    INTO 
        #Lineage_Modelling
    FROM 
        recurse_cte AS rcte
    --WHERE
    --    rcte.LevelOfCte =
    --            (SELECT MAX(LevelOfCte) FROM recurse_cte) 

    SELECT 
        *
    FROM 
        #Lineage_Modelling
                
    /*
    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 1, @StepName = 'DuplicateCheck - Created #Lineage_Model', @EntityName = @TargetEntityName_Full, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1)  WITH NOWAIT
    END


    SET @CurrentEntitySourceID = (SELECT lin.SourceDataEntityID FROM #Lineage_Modelling AS lin)

     
    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 2, @StepName = 'DuplicateCheck - Obtained the SourceDataEntityID', @EntityName = @TargetEntityName_Full, @Result = 0, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1)
    END

    SELECT
        h.HubID, f.FieldID, f.FieldName, de.DataEntityName, s.SchemaName, db.DatabaseName
    INTO
        #BKFields
    FROM 
        DataManager.DMOD.Hub AS h
    INNER JOIN 
        DataManager.DMOD.HubBusinessKey AS bk
        ON bk.HubID = h.HubID
    INNER JOIN 
        DataManager.DMOD.HubBusinessKeyField AS bkf
        ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID
    INNER JOIN 
        DataManager.DC.Field AS f
        ON f.FieldID = bkf.FieldID
    INNER JOIN 
        DataManager.DC.DataEntity AS de
        ON de.DataEntityID = f.DataEntityID
    INNER JOIN 
        DataManager.DC.[Schema] AS s
        ON s.SchemaID = de.SchemaID 
    INNER JOIN 
        DataManager.DC.[Database] AS db
        ON db.DatabaseID = s.DatabaseID
    WHERE 
        de.DataEntityID = @CurrentEntitySourceID


      
    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 3, @StepName = 'DuplicateCheck - GET Business Key(s) for the DataEntity', @EntityName = @TargetEntityName_Full, @Result = 0, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1) WITH NOWAIT
    END

    SET @sql_statement = @sql_clrf_eos
    SET @sql_statement = 'SELECT ' + @sql_clrf
    SELECT @sql_statement += '''' + @TargetEntityName_Full + '''' + ','
    SELECT @sql_statement += QUOTENAME(bkf.FieldName) + ',' FROM #BKFields AS bkf
    SET @sql_statement += 'COUNT(1) AS CNT FROM ' + @sql_clrf
    SET @sql_statement += (SELECT TOP 1 QUOTENAME(bkf.DatabaseName) + '.' +  QUOTENAME(bkf.SchemaName) + '.' + QUOTENAME(bkf.DataEntityName) FROM #BKFields AS bkf) + @sql_clrf
    SET @sql_statement += 'GROUP BY ' + @sql_clrf
    SELECT @sql_statement +=  QUOTENAME(bkf.FieldName) + ',' FROM #BKFields AS bkf
    SET @sql_statement = SUBSTRING(@sql_statement, 1, LEN(@sql_statement) - 1) + @sql_clrf
    SET @sql_statement += 'HAVING COUNT(1) > 1' + @sql_clrf_eos


    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 4, @StepName = 'DuplicateCheck - CREATE Query to identity duplicates', @EntityName = @TargetEntityName_Full, @Result = 0, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1)
    END

    RAISERROR(@sql_statement, 0, 1) WITH NOWAIT

    IF (@sql_IsExecute =1 )
        EXEC sp_executesql @stmt = @sql_statement

    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 5, @StepName = 'DuplicateCheck - EXECUTE Query to identity duplicates', @EntityName = @TargetEntityName_Full, @Result = 0, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1) WITH NOWAIT
    END

    
    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 999, @StepName = 'DuplicateCheck', @EntityName = @TargetEntityName_Full, @Result = 0, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1) WITH NOWAIT
    END

    */

COMMIT TRANSACTIONEND TRY  

BEGIN CATCH

	SELECT  
		ERROR_NUMBER() AS ErrorNumber  
    ,	ERROR_SEVERITY() AS ErrorSeverity  
    ,	ERROR_STATE() AS ErrorState  
    ,	ERROR_PROCEDURE() AS ErrorProcedure  
    ,	ERROR_LINE() AS ErrorLine  
    ,	ERROR_MESSAGE() AS ErrorMessage

    IF(@sql_IsDebug = 1)
    BEGIN
        EXEC #LoggingFunction @Position = 999, @StepName = 'DuplicateCheck', @EntityName = @TargetEntityName_Full, @Result = 1, @MessageReturn = @sql_message OUTPUT
        RAISERROR(@sql_message, 0, 1) WITH NOWAIT
    END

END CATCH  

GO

-- Main caller function
DECLARE @EntityToCheck TABLE (EntityID INT IDENTITY(1,1), FullEntityName VARCHAR(384))
DECLARE @CurrentEntityID INT = 1
DECLARE @EntityCount INT
DECLARE @CurrentEntityName SYSNAME = ''
DECLARE @sql_IsDebug BIT = 1
DECLARE @sql_IsExecute BIT = 1

INSERT INTO @EntityToCheck (FullEntityName) VALUES ('[ODS_D365].[DV].[vw_DMOD_SalesOrderLine]')

SET @EntityCount = (SELECT MAX(EntityID) AS MaxEntity FROM @EntityToCheck)

WHILE (@CurrentEntityID <= @EntityCount)
BEGIN
    SET @CurrentEntityName = (SELECT FullEntityName FROM @EntityToCheck WHERE EntityID = @CurrentEntityID)
    EXEC #sp_get_DataLineageProcedures @TargetEntityName_Full = @CurrentEntityName, @sql_IsDebug = @sql_IsDebug,  @sql_IsExecute = @sql_IsExecute


    SET @CurrentEntityID = @CurrentEntityID + 1
END
GO

DROP PROCEDURE #sp_get_DataLineageProcedures
