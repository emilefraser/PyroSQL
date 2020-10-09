SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-16
	Function	:	Arhiving and Disposal Identification of the Objects contained in a Database or Schema
	Description	:	This will move all identified Procedures, Functions, Views and Tables to the XXDEPRECATE and XXDISPOSE 
						
======================================================================================================================== */

-- Changelog --
/* ========================================================================================================================
	
	2020-06-06	:	Emile Fraser	:	Created	Procedure to Idendity and move the objects identified for deprecation 
											and disposal

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================
    EXEC MAINTENANCE.sp_transfer_Deprecated_Disposed @DatabaseName = NULL, @SchemaName= NULL, @ObjectName = NULL
======================================================================================================================== */
CREATE   PROCEDURE [MAINTENANCE].[sp_transfer_Deprecated_Disposed]
	@DatabaseName	SYSNAME		=	NULL
,	@SchemaName		SYSNAME		=	NULL
,	@ObjectName		SYSNAME		=	NULL
AS
BEGIN

	SET @DatabaseName  = 'DataManager'

	-- Dyna SQL Block
	DECLARE @sql_statement		NVARCHAR(MAX) 
	DECLARE @sql_parameters		NVARCHAR(MAX) 
	DECLARE @sql_message		NVARCHAR(MAX)
	DECLARE @sql_crlf			NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @sql_tab			NVARCHAR(1) = CHAR(9) 
	DECLARE @sql_isdebug		BIT = 1
	DECLARE @sql_isexecute		BIT = 1
	DECLARE @deprecate_cursor	CURSOR
	DECLARE @dispose_cursor		CURSOR
	DECLARE @current_pattern	NVARCHAR(500) 
	DECLARE @object_name		SYSNAME
	DECLARE @schema_name		SYSNAME



	-- Create the temp tables to hold the regex patterns to deprecate & dispose
	DECLARE @DeprecatePattern TABLE (
			DeprecatePatternID	SMALLINT IDENTITY(1,1) PRIMARY KEY CLUSTERED
		,	DeprecatePattern	NVARCHAR(500)
	)

	DECLARE @DisposePattern TABLE (
			DisposePatternID	SMALLINT IDENTITY(1,1)  PRIMARY KEY CLUSTERED
		,	DisposePattern		NVARCHAR(500)
	)

	-- INSERTS Deprecate and Dispose Patterns
	INSERT INTO @DeprecatePattern (DeprecatePattern)
	VALUES 
		('[_]20'),
		('[_]Backup'),
		('[_]BU'),
		('[_]EF'),
		('[_]FS'),
		('[_]testing')

		-- INSERTS Deprecate and Dispose Patterns
	INSERT INTO @DisposePattern (DisposePattern)
	VALUES 
		('[_]ToDelete')
	
	-- First check that XXDEPRECATE AND XXDISPOSE EXISTS 
	IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'XXDEPRECATE' )
	BEGIN
		EXEC ( 'CREATE SCHEMA XXDEPRECATE' ) 
	END
	
	IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = 'XXDISPOSE' )
	BEGIN
		EXEC ( 'CREATE SCHEMA XXDISPOSE' )
	END

	IF ( @sql_isdebug = 1 ) 
		RAISERROR('Schemas have been created', 0 , 1) WITH NOWAIT

	-- Now Loop though Iterations and move the items to relevant schemas 
	DECLARE @loopcounter SMALLINT = 1
	WHILE (@loopcounter <= (SELECT COUNT(DeprecatePatternID) FROM @DeprecatePattern))
	BEGIN

		IF ( @sql_isdebug = 1 ) 
		BEGIN
			SET @sql_message = 'Loop ' + CONVERT(VARCHAR(4), @loopcounter) + ' of the DEPRECATE cleanup'
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		END

		--SELECT DISTINCT type from sys.objects

		SET @current_pattern = (SELECT DeprecatePattern FROM @DeprecatePattern 
									WHERE DeprecatePatternID = @loopcounter)
	
		SELECT @loopcounter, @current_pattern

		SET @deprecate_cursor = CURSOR FOR 		
		SELECT 
			o.name, SCHEMA_NAME(o.schema_id) 
		FROM
			sys.objects AS o
		WHERE 
			o.name LIKE '%' + @current_pattern + '%'
		AND 
			SCHEMA_NAME(o.schema_id)  != 'XXDEPRECATE'
		AND
			SCHEMA_NAME(o.schema_id)  != 'XXDISPOSE'
		AND
			o.is_ms_shipped = 0
		AND
			o.type IN ('T', 'V', 'FN', 'P', 'U', 'IF', 'TF')

		OPEN @deprecate_cursor
		FETCH NEXT FROM @deprecate_cursor
		INTO @object_name, @schema_name

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			
			SELECT @object_name, @schema_name

			SET @sql_statement = '
			ALTER SCHEMA 
				[XXDEPRECATE]
			TRANSFER ' + @sql_crlf + @sql_tab + 
				QUOTENAME(@schema_name) + '.' + QUOTENAME(@object_name)

			IF ( @sql_isdebug = 1 )
				RAISERROR(@sql_statement, 0, 1) WITH NOWAIT

			IF ( @sql_isexecute = 1 )
				EXEC sp_executesql @stmt = @sql_statement

			FETCH NEXT FROM  @deprecate_cursor
			INTO @object_name, @schema_name

		END

		-- Increment the Counter
		SET @loopcounter += 1

	END

	-- Now of the Dispose items
	SET @loopcounter = 1
	WHILE (@loopcounter <= (SELECT COUNT(DisposePatternID) FROM @DisposePattern))
	BEGIN
	
	IF ( @sql_isdebug = 1 ) 
		BEGIN
			SET @sql_message = 'Loop ' + CONVERT(VARCHAR(4), @loopcounter) + ' of the DISPOSE cleanup'
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		END

		SET @current_pattern = (SELECT DisposePattern FROM @DisposePattern 
									WHERE DisposePatternID = @loopcounter)

		SELECT @loopcounter, @current_pattern
										
		SET @Dispose_cursor = CURSOR FOR 
		SELECT 
			o.name, SCHEMA_NAME(o.schema_id) 
		FROM
			sys.objects AS o
		WHERE 
			o.name LIKE '%' + @current_pattern + '%'
		AND 
			SCHEMA_NAME(o.schema_id)  != 'XXDISPOSE'
		AND
			o.is_ms_shipped = 0
		AND
			o.type IN ('T', 'V', 'FN', 'P', 'U', 'IF', 'TF')

		OPEN @dispose_cursor
		FETCH NEXT FROM  @dispose_cursor
		INTO @object_name, @schema_name

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			
			SET @sql_statement = '
			ALTER SCHEMA 
				[XXDISPOSE]
			TRANSFER ' + @sql_crlf + @sql_tab + 
				QUOTENAME(@schema_name) + '.' + QUOTENAME(@object_name)

			IF ( @sql_isdebug = 1 )
				RAISERROR(@sql_statement, 0, 1) WITH NOWAIT

			IF ( @sql_isexecute = 1 )
				EXEC sp_executesql @stmt = @sql_statement

			FETCH NEXT FROM  @dispose_cursor
			INTO @object_name, @schema_name

		END

		-- Increment the Counter
		SET @loopcounter += 1

	END

END
GO
