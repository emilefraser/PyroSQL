SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-01-31
	Function	:	Creates a CRUD for any table
	Description	:	This is my method on handling cruds, this will handle inserts, updates and deletes
				
			-- Features:
			-- 
			-- 
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-04-01	:	RJ Oosthuizen did the initial version on this

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	EXEC [MASTER].[sp_create_CrudProcedure]

======================================================================================================================== */
CREATE   PROCEDURE dbo.[sp_create_CrudProcedure](
    @TargetDatabaseName		SYSNAME 
,	@TargetSchemaName		SYSNAME 
,	@TargetTableName		SYSNAME
,	@CrudType				NVARCHAR(100) -- Either Insert, InsertUpdate, InsertDelete, InsertUpdateDelete, DeleteUpdate AND IsDelete or IsSoftDelete
)
AS

BEGIN
	
	-- Dynamic Parameters needed
	DECLARE 
		@sql_statement	NVARCHAR(MAX)
	,	@sql_message	NVARCHAR(MAX)
	,	@sql_parameter	NVARCHAR(MAX)
	,	@sql_crlf		NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_crlf2		NVARCHAR(4) = REPLICATE(CHAR(13) + CHAR(10), 2)
	,	@sql_tab		NVARCHAR(1) = CHAR(9)
	,	@sql_continue	BIT = 1		
	,	@sql_debug		BIT = 1
	,	@sql_execute	BIT = 1

	-- Parameters to chek what crud to be fired
	DECLARE 
		@IsCreate BIT
	,	@IsInsert BIT 
	,	@IsUpdate BIT
	,	@IsHardDelete BIT
	,	@IsSoftDelete BIT

	-- Parameters relating tot the table we will try to crud
	DECLARE 
		@PrimaryKeyColumn			NVARCHAR(MAX)
	,	@UniqueConstraintColumn		NVARCHAR(MAX)
	,	@NonNullableColumn			NVARCHAR(MAX)
	,	@UniqueIndexColumn			NVARCHAR(MAX)
	,	@IdentityColumn				NVARCHAR(MAX)


	-- Parameters to hold the CRUD-portion that will be executed 


	-- Firstly check that Database, Schema and TargetTable is valid
	SET @sql_statement = N'
		IF NOT EXISTS (
			SELECT 1 FROM sys.databases WHERE name = ''' + @TargetDatabaseName + '''
		)
		OR NOT EXISTS (
			SELECT 1 FROM ' + QUOTENAME(@TargetDatabaseName) + '.' + 'sys.schemas WHERE name = = ''' + @TargetSchemaName + '''
		)
		OR NOT EXISTS (
			SELECT 1 FROM ' + QUOTENAME(@TargetDatabaseName) + '.' + 'sys.tables AS t 
			INNER JOIN '    + QUOTENAME(@TargetDatabaseName) + '.' + 'sys.schemas AS s
			ON s.schema_id = t.schema_id 
			WHERE t.name = ''' + @TargetTableName + '''
			AND s.name = ''' + @TargetSchemaName + '''
		)
		BEGIN
			SET @sql_continue = 0
		END
	'

	SET @sql_parameter = N'@sql_continue BIT OUTPUT'
	SET @sql_message = @sql_statement + @sql_crlf2 + 'Parameters:' + @sql_crlf + @sql_parameter

	IF ( @sql_debug = 1 )
	BEGIN
		RAISERROR ( @sql_message, 0, 1) WITH NOWAIT
	END

	IF ( @sql_execute = 1)
	BEGIN
		EXEC sp_executesql 
			@stmt = @sql_statement
		,	@param = @sql_parameter
		,	@sql_continue = @sql_continue OUTPUT
	END

	-- CheckExistance of different Types in the CrudType
	--SET @IsCreate = IIF(CHARINDEX(@CrudType, 'Create') > 0, 1, 0)
	SET @IsInsert = IIF(CHARINDEX(@CrudType, 'Insert') > 0, 1, 0)
	SET @IsUpdate = IIF(CHARINDEX(@CrudType, 'Update') > 0, 1, 0)

	SET @IsSoftDelete = IIF(CHARINDEX(@CrudType, 'SoftDelete') > 0, 1, 0)
	IF ( @IsSoftDelete = 0)
	BEGIN
		SET @IsHardDelete = IIF(CHARINDEX(@CrudType, 'Delete') > 0, 1, 0)
	END


	IF ( @IsCreate = 0 AND @IsInsert = 0 AND @IsUpdate = 0 AND @IsSoftDelete = 0 AND @IsHardDelete = 0 )
	BEGIN
		SET @sql_continue = 0
	END


	-- DO INITIAL VALIDITY TEST OF THE SPECIFICATIONS 
	IF ( @sql_continue = 0)
	BEGIN
		SET @sql_statement = 'One of the parameters that was sent is invalid, please review them and try again'
		RAISERROR ( @sql_statement, 0, 50001) WITH NOWAIT
		RETURN 50001
	END
	ELSE
	BEGIN


		-- TODO : Get this info
		/* 
		DECLARE 
		@PrimaryKeyColumn			NVARCHAR(MAX)
	,	@UniqueConstraintColumn		NVARCHAR(MAX)
	,	@NonNullableColumn			NVARCHAR(MAX)
	,	@UniqueIndexColumn			NVARCHAR(MAX)
	,	@IdentityColumn				NVARCHAR(MAX)
	*/
		SELECT 1


		--SELECT 
		--	 [MsMaster].[sys].[key_constraints]
		--FROM 
			


	END







	/*
--gets the table name of the provided dataentityid
DECLARE @InTable VARCHAR(20) = (SELECT TOP 1 DataEntityName 
									FROM dc.dataentity
									WHERE dataentityid = @DataEntityID)
--gets the schema name of the provided dataentityid
DECLARE @Schema VARCHAR(20) =  (SELECT TOP 1 SchemaName 
									FROM dc.[Schema] s
									JOIN dc.[DataEntity]de ON
										de.SchemaID = s.SchemaID
									WHERE dataentityid = @DataEntityID)

--proc name creation
DECLARE @SpName VARCHAR(100) = '[APP].[sp_CRUD_' + DMOD.udf_Split_On_Upper_Case(@InTable)  + ']' 
Set @SpName = REPLACE(@SpName, ' ', '_') -- string containing the right formatted name

--insert statement
DECLARE @InsertStatement VARCHAR(MAX) = (
	SELECT o.list
    FROM    DC.DataEntity de
	CROSS APPLY
		(SELECT
            FieldName + ', '
		    FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
		FOR XML PATH('')) o (list)
	LEFT JOIN
		DC.Field f
	ON  f.DataEntityID = de.DataEntityID
	AND f.IsPrimaryKey  = 1

	WHERE de.DataEntityID = @DataEntityID
) -- gets all fields

SET @InsertStatement = replace(@InsertStatement, '&#x0D;', '')
SET @InsertStatement = replace(@InsertStatement, @PrimaryKeyColumn, '') -- remove primary key column
SET @InsertStatement = replace(@InsertStatement, 'UpdatedDT,', '') -- remove updateddt column
SET @InsertStatement = ltrim(@InsertStatement)
SET @InsertStatement = substring(@InsertStatement, 2, len(@InsertStatement)) -- remove first comma after primary key column
SET @InsertStatement = rtrim(@InsertStatement)
SET @InsertStatement = reverse(substring(reverse(@InsertStatement), 2, len(@InsertStatement))) -- remove last comma

DECLARE @InsertStatementValues VARCHAR(MAX) = (
	SELECT o.list
    FROM    DC.DataEntity de
	CROSS APPLY
		(SELECT
            '@' + FieldName + ', '
		    FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
		FOR XML PATH('')) o (list)
	LEFT JOIN
		DC.Field f
	ON  f.DataEntityID = de.DataEntityID
	AND f.IsPrimaryKey  = 1

	WHERE de.DataEntityID = @DataEntityID
) -- gets all the fields and changes them to variables

SET @InsertStatementValues = replace(@InsertStatementValues, '&#x0D;', '')
SET @InsertStatementValues = replace(@InsertStatementValues, @PrimaryKeyColumn, '') -- remove primary key column value
SET @InsertStatementValues = replace(@InsertStatementValues, '@IsActive', '1') -- replace @isactive with value 1
SET @InsertStatementValues = replace(@InsertStatementValues, '@UpdatedDT,', '') -- remove @updateddt value
SET @InsertStatementValues = replace(@InsertStatementValues, '@CreatedDT', '@TransactionDT') -- replace @createddt with @transactiondt value
SET @InsertStatementValues = ltrim(@InsertStatementValues)
SET @InsertStatementValues = substring(@InsertStatementValues, 3, len(@InsertStatementValues)) -- remove first comma after primary key column
SET @InsertStatementValues = rtrim(@InsertStatementValues)
SET @InsertStatementValues = reverse(substring(reverse(@InsertStatementValues), 2, len(@InsertStatementValues))) -- remove last column

SET @InsertStatement = '(' + @InsertStatement + ')' + CHAR(10) + CHAR(13) + 'VALUES(' + @InsertStatementValues + ')' -- format create string correctly


--update statement
DECLARE @UpdateStatement VARCHAR(MAX) = (
	SELECT o.list
    FROM    DC.DataEntity de
	CROSS APPLY
		(SELECT
            FieldName + ' = ' + '@' + FieldName + ',' + CHAR(10) + CHAR(13)
		    FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
		FOR XML PATH('')) o (list)
	LEFT JOIN
		DC.Field f
	ON  f.DataEntityID = de.DataEntityID
	AND f.IsPrimaryKey  = 1

	WHERE de.DataEntityID = @DataEntityID
) -- gets all the fields and formats for update statement var = @var

SET @UpdateStatement = replace(@UpdateStatement, '&#x0D;', '')
SET @UpdateStatement = replace(@UpdateStatement, @PrimaryKeyColumn + ' = @' + @PrimaryKeyColumn + ',', '') -- remove primary key column
SET @UpdateStatement = replace(@UpdateStatement,  'CreatedDT = @CreatedDT,','') -- remove createddt
SET @UpdateStatement = replace(@UpdateStatement,  'UpdatedDT = @UpdatedDT,','') -- remove updateddt (already in template)
SET @UpdateStatement = replace(@UpdateStatement,  'IsActive = @IsActive,','') -- remove isactive

SET @UpdateStatement = 'SET ' + @UpdateStatement -- format correctly

--declare parameters
DECLARE @InsertParameters VARCHAR(MAX)
SET @InsertParameters = (SELECT  o.list 
		  	 FROM    DC.DataEntity de
			 CROSS APPLY
				(SELECT 
					'@'+FieldName+' ' + 
					DataType + CASE DataType
						WHEN 'int' THEN ''
						WHEN 'smallint' THEN ''
						WHEN 'decimal' THEN '(' + cast([precision] AS VARCHAR) + ', ' + CAST([scale] AS VARCHAR) + ')'
						ELSE coalesce('('+CASE WHEN [MaxLength] = -1 THEN 'MAX' ELSE cast([MaxLength] AS VARCHAR) END +')','') END +
						',' + CHAR(10) + CHAR(13)
		 

				  FROM DC.Field f WHERE f.DataEntityID = de.DataEntityID
				  FOR XML PATH('')
				    ) o (list)
					LEFT JOIN DC.Field f ON
					f.DataEntityID = de.DataEntityID
					   AND f.IsPrimaryKey  = 1

				  WHERE de.DataEntityID = @DataEntityID
	
				) -- gets fieldname + field type

--remove primary key
--SET @InsertParameters = trim(@InsertParameters)
--SET @InsertParameters = substring(@InsertParameters, 0, charindex('@' + @PrimaryKeyColumn, @InsertParameters))
--+ substring(@InsertParameters, charindex(',', @InsertParameters,  charindex('@' + @PrimaryKeyColumn, @InsertParameters)) + 1, len(@InsertParameters))
--remove unique key
--SET @InsertParameters = trim(@InsertParameters)
--SET @InsertParameters = substring(@InsertParameters, 0, charindex('@' + @UniqueBusinessKeyColumn, @InsertParameters))
--+ substring(@InsertParameters, charindex(',', @InsertParameters,  charindex('@' + @UniqueBusinessKeyColumn, @InsertParameters)) + 1, len(@InsertParameters))
--remove createddt
SET @InsertParameters = trim(@InsertParameters)
SET @InsertParameters = substring(@InsertParameters, 0, charindex('@CreatedDT', @InsertParameters))
+ substring(@InsertParameters, charindex(',', @InsertParameters,  charindex('@CreatedDT', @InsertParameters)) + 1, len(@InsertParameters))

--remove updateddt
SET @InsertParameters = trim(@InsertParameters)
SET @InsertParameters = substring(@InsertParameters, 0, charindex('@UpdatedDT', @InsertParameters))
+ substring(@InsertParameters, charindex(',', @InsertParameters,  charindex('@UpdatedDT', @InsertParameters)) + 1, len(@InsertParameters))

--remove isactive
SET @InsertParameters = trim(@InsertParameters)
SET @InsertParameters = substring(@InsertParameters, 0, charindex('@IsActive', @InsertParameters))
+ substring(@InsertParameters, charindex(',', @InsertParameters,  charindex('@IsActive', @InsertParameters)) + 1, len(@InsertParameters))

SET @InsertParameters = trim(@InsertParameters) --format correctly

--CRUD template content
DECLARE @Content VARCHAR(MAX) = 
'SET ANSI_NULLS ON' + CHAR(10) + CHAR(13) +
'GO' + CHAR(10) + CHAR(13) +
'SET QUOTED_IDENTIFIER ON' + CHAR(10) + CHAR(13) +
'GO' + CHAR(10) + CHAR(13) +
'CREATE PROCEDURE SpNameReplace(' + CHAR(10) + CHAR(13) +
	'--all table fields, remove the ones you dont need' + CHAR(10) + CHAR(13) +
    ' InsertParametersReplace ' + CHAR(10) + CHAR(13) +
	'-- required params, please do not remove' + CHAR(10) + CHAR(13) +
	'@TransactionPerson varchar(80), -- who actioned' + CHAR(10) + CHAR(13) +
    '@MasterEntity varchar(50), -- from where actioned' + CHAR(10) + CHAR(13) +
    '@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"' + CHAR(10) + CHAR(13) +
    ')' + CHAR(10) + CHAR(13) +
'AS' + CHAR(10) + CHAR(13) +

'BEGIN' + CHAR(10) + CHAR(13) +

    'DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction' + CHAR(10) + CHAR(13) +
    'DECLARE @isActive bit -- indicate soft delete' + CHAR(10) + CHAR(13) +
    'DECLARE @JSONData varchar(max) = null -- to store in audit table' + CHAR(10) + CHAR(13) +
    'DECLARE @PrimaryKeyID int = null -- primary key value for the table' + CHAR(10) + CHAR(13) +
    'DECLARE @TableName VARCHAR(50) = ''TableNameReplace'' -- table name' + CHAR(10) + CHAR(13) +
    
    '--create record' + CHAR(10) + CHAR(13) +
    'IF @TransactionAction = ''Create''' + CHAR(10) + CHAR(13) +
        'BEGIN' + CHAR(10) + CHAR(13) +
            '--check if record exists' + CHAR(10) + CHAR(13) +
            'IF EXISTS (SELECT 1 FROM TableNameReplace WHERE  @UniqueBusinessKeyColumnReplace = UniqueBusinessKeyColumnReplace)' + CHAR(10) + CHAR(13) +
	            'BEGIN' + CHAR(10) + CHAR(13) +
		        'SELECT ''Already Exist''' + CHAR(10) + CHAR(13) +
	            'END' + CHAR(10) + CHAR(13) +
	        'ELSE' + CHAR(10) + CHAR(13) +
    	        'BEGIN' + CHAR(10) + CHAR(13) +
                    '--Insert new record' + CHAR(10) + CHAR(13) +
                    '--remove fields not needed, keep CreatedDT and IsActive' + CHAR(10) + CHAR(13) +
	                'INSERT INTO TableNameReplace InsertStatementReplace' + CHAR(10) + CHAR(13) +
                'END' + CHAR(10) + CHAR(13) +
        'END' + CHAR(10) + CHAR(13) +

    '--update record' + CHAR(10) + CHAR(13) +
    'IF @TransactionAction = ''Update''' + CHAR(10) + CHAR(13) +
        'BEGIN' + CHAR(10) + CHAR(13) +
            '--check if record exists' + CHAR(10) + CHAR(13) +
    		'IF EXISTS (SELECT 1 FROM TableNameReplace WHERE  @UniqueBusinessKeyColumnReplace = UniqueBusinessKeyColumnReplace)' + CHAR(10) + CHAR(13) +
                'BEGIN' + CHAR(10) + CHAR(13) +
                    '--update existing record' + CHAR(10) + CHAR(13) +
                    'UPDATE TableNameReplace ' + CHAR(10) + CHAR(13) +
                    '--remove fields not needed, keep UpdatedDT' + CHAR(10) + CHAR(13) +
                    'UpdateStatementReplace ' + CHAR(10) + CHAR(13) +
					'UpdatedDT = @TransactionDT' + CHAR(10) + CHAR(13) +
			        'WHERE UniqueBusinessKeyColumnReplace = @UniqueBusinessKeyColumnReplace' + CHAR(10) + CHAR(13) +
                'END' + CHAR(10) + CHAR(13) +
        'END' + CHAR(10) + CHAR(13) +
    '--delete record' + CHAR(10) + CHAR(13) +
    'IF @TransactionAction = ''Delete''' + CHAR(10) + CHAR(13) +
        'BEGIN' + CHAR(10) + CHAR(13) +
            '--set record status inactive = 0 (soft delete record)' + CHAR(10) + CHAR(13) +
            'Update TableNameReplace ' + CHAR(10) + CHAR(13) +
	        'SET IsActive = 0, ' + CHAR(10) + CHAR(13) +
            'UpdatedDT = @TransactionDT' + CHAR(10) + CHAR(13) +
		    'WHERE UniqueBusinessKeyColumnReplace = @UniqueBusinessKeyColumnReplace' + CHAR(10) + CHAR(13) +
        'END' + CHAR(10) + CHAR(13) +
        

	'--capture json data (get primary key value to store in audit table)' + CHAR(10) + CHAR(13) +
    'SET @PrimaryKeyID = (SELECT PrimaryKeyColumnReplace FROM TableNameReplace WHERE UniqueBusinessKeyColumnReplace = @UniqueBusinessKeyColumnReplace)' + CHAR(10) + CHAR(13) +
    'SET @JSONData = (SELECT *' + CHAR(10) + CHAR(13) +
                     'FROM TableNameReplace ' + CHAR(10) + CHAR(13) +
                     'WHERE UniqueBusinessKeyColumnReplace = @UniqueBusinessKeyColumnReplace' + CHAR(10) + CHAR(13) +
                     'FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )' + CHAR(10) + CHAR(13) +

    '--call sp to store json audit data in table' + CHAR(10) + CHAR(13) +
    'EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,' + CHAR(10) + CHAR(13) +
                                    '@TransactionAction = @TransactionAction,' + CHAR(10) + CHAR(13) +
                                    '@MasterEntity = @MasterEntity,' + CHAR(10) + CHAR(13) +
                                    '@JSONData = @JSONData,' + CHAR(10) + CHAR(13) +
                                    '@TransactionDT = @TransactionDT,' + CHAR(10) + CHAR(13) +
                                    '@PrimaryKeyID = @PrimaryKeyID,' + CHAR(10) + CHAR(13) +
                                    '@TableName = @TableName' + CHAR(10) + CHAR(13) +

'END' + CHAR(10) + CHAR(13)

SET @Content = REPLACE(@Content, 'SpNameReplace', @SpName) -- insert sp header name
SET @Content = REPLACE(@Content, 'TableNameReplace', @Schema + '.' + @InTable) -- insert table name
SET @Content = REPLACE(@Content, 'UniqueBusinessKeyColumnReplace', @UniqueBusinessKeyColumn) -- insert unique business key column
SET @Content = REPLACE(@Content, 'PrimaryKeyColumnReplace', @PrimaryKeyColumn) -- insert primary key id
SET @Content = REPLACE(@Content, 'InsertStatementReplace', @InsertStatement) -- insert insert statement fields + values
SET @Content = REPLACE(@Content, 'UpdateStatementReplace', @UpdateStatement) -- insert update statement fields + values
SET @Content = REPLACE(@Content, 'InsertParametersReplace', @InsertParameters) -- insert parameters
SET @Content = replace(@Content, '&#x0D;', '')
*/
--select @Content
END

GO
