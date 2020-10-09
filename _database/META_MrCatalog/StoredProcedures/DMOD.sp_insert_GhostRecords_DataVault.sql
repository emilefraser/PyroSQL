SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	WORKING?
	SELECT COUNT(1) FROM DEV_DataVault.raw.HUB_Customer WHERE HK_Customer = '3FEDA0153EEE1380B496298450DC5A74324EB8C1' 
	SELECT COUNT(1) FROM DEV_DataVault.raw.SAT_Customer_D365_LVD WHERE HK_Customer = '3FEDA0153EEE1380B496298450DC5A74324EB8C1' 
	SELECT COUNT(1) FROM DEV_DataVault.raw.REF_Date WHERE HK_Date = '3FEDA0153EEE1380B496298450DC5A74324EB8C1' 
	SELECT COUNT(1) FROM [DEV_DataVault].[raw].[SAT_PurchaseOrderLine_D365_MVD] WHERE HK_PurchaseOrderLine = '3FEDA0153EEE1380B496298450DC5A74324EB8C1' 

    ? Who ? Emile Fraser
    ? Why ? Inserts Ghost Records into DataVault table for joining unknowns
    ? When ? 20120-01-20
    ? How ? 
        DECLARE @Environment VARCHAR(100) = 'PROD'
        DECLARE @sql_IsDebug BIT = 1
        EXEC DMOD.sp_insert_GhostRecords_DataVault @DatabaseEnvironmentType = @Environment, @sql_IsDebug = @sql_IsDebug
*/
CREATE    PROCEDURE [DMOD].[sp_insert_GhostRecords_DataVault] 
	@DatabaseEnvironmentType VARCHAR(50)
,   @sql_IsDebug BIT = 0
AS

SET NOCOUNT OFF


BEGIN

    -- ## Debug ##
    -- DECLARE @DatabaseEnvironmentType VARCHAR(50) = 'DEV'

    -- Variable Block
    DECLARE @DataEntityID INT
    DECLARE @TableName SYSNAME
    DECLARE @SchemaName SYSNAME
    DECLARE @DatabaseName SYSNAME
    
    DECLARE @fieldList VARCHAR(MAX)
    DECLARE @BKHashFieldName VARCHAR(MAX)
    DECLARE @GhostRecordCount INT
    DECLARE @DoesGhostRecordExists BIT

    -- DynaSQL Variable Block
    DECLARE @sql_statement NVARCHAR(MAX)    
    DECLARE @sql_parameters NVARCHAR(MAX)
    DECLARE @query NVARCHAR(MAX)
    DECLARE @sql_message NVARCHAR(MAX)
    DECLARE @sql_clrf NVARCHAR(2) = CHAR(13) + CHAR(33)
    DECLARE @sql_clrf_eos NVARCHAR(4) = REPLICATE(CHAR(13) + CHAR(33), 2 )


-- Gets the Ghost record according to our standard convension (EF Changed this to a schalar funcation
-- 3FEDA0153EEE1380B496298450DC5A74324EB8C1
DECLARE @GhostRecordHash VARCHAR(40)
SELECT @GhostRecordHash = DMOD.udf_get_GhostRecord_HashKey()

DECLARE @UniqueIdentifier VARCHAR(36)  = (SELECT CAST(0x0 AS UNIQUEIDENTIFIER))

-- Gets all the DataVault HUB, REF, SATS, REFSAT 
-- Assigns it to a cursror
DECLARE @ghost_cursor AS CURSOR
SET @ghost_cursor = CURSOR FOR 
SELECT
	de.DataEntityID
,	de.DataEntityName AS TableName
,	s.SchemaName AS SchemaName
,	db.DatabaseName  AS DatabaseName
FROM 
	DC.[DataEntity] AS de
INNER JOIN 
	DC.[DataEntityType] AS det
	ON det.DataEntityTypeID = de.DataEntityTypeID
INNER JOIN 
	DC.[Schema] AS s
	ON s.SchemaID = de.SchemaID
INNER JOIN 
	DC.[Database] AS db
	ON db.DatabaseID = s.DatabaseID
INNER JOIN 
	DC.[DatabasePurpose] AS dp
	ON dp.DatabasePurposeID = db.DatabasePurposeID
INNER JOIN 
	TYPE.Generic_Detail AS gd
	ON gd.DetailID = db.DatabaseEnvironmentTypeID
INNER JOIN 
	TYPE.Generic_Header	 AS gh
	ON gh.HeaderCode = 'DB_ENV'
WHERE 
	gd.DetailTypeCode = @DatabaseEnvironmentType
AND
    det.IsInsertGhostRecord = 1
AND
    de.DataEntityName NOT LIKE '%GeneralLedger%'
--AND
--	dp.DatabasePurposeCode = 'DataVault'
--AND
--	det.DataEntityTypeCode IN ('HUB', 'SATLVD', 'SATMVD', 'SATHVD',  'REF', 'REFSAT')
--TODO: KD 22 Oct 2019: This is not good practice. What if we add another type of SAT? 
--Like a TLINK SAT? Rather read from table that has a "type" filter or something that drives this list and de.DataEntityName   = 'SAT_StockTransaction_EMS_LVD' 
--DONE: @Karl whether a Vault Entity now gets a ghost records depends what the entity type is as per our DC and that Datatype's corresponding IsInsertGhostRecord Field

OPEN 
    @ghost_cursor
FETCH NEXT FROM 
    @ghost_cursor
INTO 
    @DataEntityID
,   @TableName
,   @SchemaName
,   @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN

	-- Gets THE BKHash Column Name for the table
	SET @BKHashFieldName = (
								SELECT 
									f.FieldName
								FROM 
									DC.Field AS f
								WHERE
									f.DataEntityID = @DataEntityID
								AND
									f.FieldSortOrder = 1
								AND
									ISNULL(f.IsActive, 0) = 1
							)

	-- Checks if the Gost record already exists?
	-- SET @DoesGhostRecordExists = 0
	SET @sql_statement = (		
                    'SELECT @GhostRecordCount = 
						    COUNT(1)
					FROM ' +
						QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
					WHERE ' +
						QUOTENAME(@BKHashFieldName) + ' = ' + '''' + @GhostRecordHash + ''''
		)

	-- :>Debug:> 
	-- PRINT @query
	-- :>Debug:> 
	SET @sql_parameters = N'@GhostRecordCount int OUTPUT'

	EXEC sp_executesql 
				@stmt = @sql_statement
			,	@params = @sql_parameters
			,	@GhostRecordCount = @GhostRecordCount OUTPUT



	--EXECUTE sp_executesql @query, N' @GhostRecordCount INT OUTPUT', @GhostRecordCount = @GhostRecordCount 
	
	-- :>Debug:> 
	--SELECT ISNULL(@GhostRecordCount, 0) AS GRC
	-- :>Debug:> 

	IF ISNULL(@GhostRecordCount, 0) = 0
	BEGIN
		SET @DoesGhostRecordExists = 0
	END
	ELSE IF ISNULL(@GhostRecordCount, 0) > 1 -- DUPLICATES
	BEGIN
	
		SET @query =
			(		'DELETE 
						FROM ' +
							QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
						WHERE ' +
							QUOTENAME(@BKHashFieldName) + ' = ' + '''' + @GhostRecordHash + ''''
			)
		PRINT(@query)
		EXEC(@query)


		SET @DoesGhostRecordExists = 0
	END
	ELSE
	BEGIN
		SET @DoesGhostRecordExists = 1
	END

	-- :>Debug:> 
	--SELECT @DoesGhostRecordExists AS DRE
	-- :>Debug:>
	
	IF(@DoesGhostRecordExists = 0)
	BEGIN

		-- Generates the first portion of the INSERT statement including destination table
		SET @sql_statement= ''
		SELECT @sql_statement= 'INSERT INTO ' + 
						QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
						('

		-- Gets the Fields for the INSert
		SELECT @sql_statement= @sql_statement+ QUOTENAME(f.FieldName) + ', '
		FROM 
			DC.[Field] AS f
		WHERE
			f.DataEntityID = @DataEntityID
		AND
			f.FieldName != 'LoadEndDT'
		AND
			f.FieldName != 'LastSeenDT'
		ORDER BY 
			f.FieldSortOrder

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>

		-- Closes the Field List for the Destination table
		SELECT @sql_statement= LEFT(@sql_statement, LEN(@sql_statement) - 1) + ')' + CHAR(13)

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>

		-- Starts by Inserting Ghost value to the first column
		SELECT @sql_statement= @sql_statement+ 'SELECT ' + CHAR(13) + REPLICATE(CHAR(9), 3) +  '''' + @GhostRecordHash + ''''

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>

		-- Insert the LoadDT
		SELECT @sql_statement= @sql_statement+ ', ''' + CONVERT(VARCHAR, GETDATE(), 121) + ''''
		--SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
		--SELECT NEWID()

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>

		-- Insert the RecSrcDataEntityID
		SELECT @sql_statement= @sql_statement+ ', ''' + CONVERT(VARCHAR(1), 0) + ''''

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>
		SET  @fieldList = ''
		SELECT @fieldList = @fieldList +
				CASE	WHEN SUBSTRING(f.FieldName,1,3) = 'HK_' THEN CONVERT(VARCHAR(40), '' + @GhostRecordHash + '')
                        WHEN f.FieldName = 'HashDiff' THEN CONVERT(VARCHAR(40), '' + @GhostRecordHash + '')
						WHEN dt.DataTypeClassification = 'Character' THEN '''NA'''
						WHEN dt.DataTypeClassification = 'Numeric' THEN '''0'''
						WHEN dt.DataTypeClassification = 'DateTime' THEN '''1900-01-01 00:00:00'''
						WHEN dt.DataTypeClassification = 'Binary' THEN '''0'''
						WHEN dt.DataTypeClassification = 'Identity' THEN '''' + CONVERT(VARCHAR(36), @UniqueIdentifier) + ''''
						WHEN dt.DataTypeClassification = 'Spatial' THEN '''NA'''
						WHEN dt.DataTypeClassification = 'SQL' THEN '''NA'''
						ELSE '''NA'''
				END + ', '
			FROM 
				DC.[Field] AS f
			INNER JOIN 
				DC.[DataEntity] AS de
				ON de.DataEntityID = f.DataEntityID
			INNER JOIN 
				DC.[DataType] AS dt
				ON dt.DataType = F.DataType
			WHERE
				de.DataEntityID = @DataEntityID
			AND
				f.FieldSortOrder != 1 -- HASHKEY
			AND
				f.FieldName != 'LoadEndDT'
			AND
				f.FieldName != 'LoadDT'
			AND
				f.FieldName != 'LastSeenDT'
			AND
				f.FieldName != 'RecSrcDataEntityID'
			ORDER BY 
				f.FieldSortOrder

		-- :>Debug:>
		--SeLECT @fieldList
		-- :>Debug:>

		-- Add the FieldList to the query
		SELECT @sql_statement= @sql_statement+ ', ' + @fieldList

		-- Removes trailing comma
		SELECT @sql_statement= SUBSTRING(@sql_statement, 1, LEN(@sql_statement) - 1) + CHAR(13) + CHAR(13)

		-- :>Debug:>
		-- SeLECT @sql
		-- :>Debug:>

		RAISERROR(@sql_statement, 0, 1) WITH NOWAIT
		EXEC(@sql_statement)
	END

    FETCH NEXT FROM 
        @ghost_cursor
    INTO 
        @DataEntityID
    ,   @TableName
    ,   @SchemaName
    ,   @DatabaseName

END

END

GO
