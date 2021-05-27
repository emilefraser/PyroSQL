SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[ExportData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[ExportData] AS' 
END
GO

/*
	EXEC [meta].[ExportData] 'tablename'																-- Creates statement from dbo.tablename to dbo.tablename
	EXEC [meta].[ExportData] 'tablename', @include_column_list = 0										-- Omits column list in Insert Statement
	EXEC [meta].[ExportData] 'tablename', 'tablenameCopy'												-- Creates statement from dbo.tablename to dbo.tablenameCopy
	EXEC [meta].[ExportData] 'tablename', @from = "from tablename where title like '%Computer%'"		-- To generate INSERT statements for 'tablename' table for only those tablename 
	EXEC [meta].[ExportData] 'tablename', @include_timestamp = 1										-- To specify that you want to include TIMESTAMP column's data as well in the INSERT statement
	EXEC [meta].[ExportData] 'tablename', @sql_debug = 1												-- Debug Prints the process
	EXEC [meta].[ExportData] 'tablename', @schema_name_source = 'schemaname'
	EXEC [meta].[ExportData] 'iamgetable', @ommit_images = 1											-- Omit image insert
	EXEC [meta].[ExportData] mytable, @ommit_identity = 1		-										- To generate INSERT statements excluding (ommiting) IDENTITY columns
	EXEC [meta].[ExportData] mytable, @top = 10
	EXEC [meta].[ExportData] tablename, @cols_to_include = "'title','title_id','au_id'"				--  To generate INSERT statements with only those columns you want:
    EXEC [meta].[ExportData] tablename, @cols_to_exclude = "'title','title_id','au_id'"				- To generate INSERT statements by omitting certain columns:
	EXEC [meta].[ExportData] @table_name_source = 'tablename', @disable_constraints = 1
	EXEC [meta].[ExportData] @table_name_source= 'tablename', @ommit_computed_cols = 1

*/
/*
	EXEC  [meta].[meta].[ExportData] @table_name_source = 'Number', @table_name_target = 'Numbers2'
*/

ALTER PROCEDURE [meta].[ExportData] (
	@table_name_source              SYSNAME					-- The table/view for which the INSERT statements will be generated using the existing data
  , @schema_name_source				SYSNAME		 = 'dbo'	-- Schema Name Specified
  , @table_name_target				SYSNAME		 = NULL		-- Use this parameter to specify a different table name into which the data will be inserted
  , @schema_name_target				SYSNAME		 = 'dbo'
  , @include_column_list			BIT          = 1		-- Use this parameter to include/ommit column list in the generated INSERT statement
  , @from							VARCHAR(MAX) = NULL		-- Use this parameter to filter the rows based on a filter condition (using WHERE)
  , @include_timestamp				BIT          = 0		-- Specify 1 for this parameter, if you want to include the TIMESTAMP/ROWVERSION column's data in the INSERT statement
  , @sql_debug						BIT          = 0		-- If @sql_debug is set to 1, the SQL statements constructed by this procedure will be printed for later examination
  , @ommit_images					BIT          = 0		-- Use this parameter to generate INSERT statements by omitting the 'image' columns
  , @ommit_identity					BIT          = 0		-- Use this parameter to ommit the identity columns
  , @top							INT          = NULL		-- Use this parameter to generate INSERT statements only for the TOP n rows
  , @cols_to_include				VARCHAR(MAX) = NULL		-- List of columns to be included in the INSERT statement
  , @cols_to_exclude				VARCHAR(MAX) = NULL		-- List of columns to be excluded from the INSERT statement
  , @disable_constraints			BIT          = 0		-- When 1, disables foreign key constraints and enables them after the INSERT statements
  , @ommit_computed_cols			BIT          = 0		-- When 1, computed columns will not be included in the INSERT statement
  , @truncate_target_before_load	BIT			 = 0		-- When 1 will truncat target before reload
  , @return_etl						NVARCHAR(MAX) OUTPUT	-- Return VALUE
)
AS
BEGIN
	SET NOCOUNT ON;
	
	
	SET @return_etl	= ''

	
	DECLARE @crlf NVARCHAR(2)	= CHAR(13) + CHAR(10)
	DECLARE @tab NVARCHAR(1)	= CHAR(9)

	-- If schema name is null
	IF (@schema_name_source IS NULL)
	BEGIN
		SET @schema_name_source = 'dbo'
	END
	
	--Making sure user only uses either @cols_to_include or @cols_to_exclude
	IF((@cols_to_include IS NOT NULL)
	   AND (@cols_to_exclude IS NOT NULL))
	BEGIN
		RAISERROR('Use either @cols_to_include or @cols_to_exclude. Do not use both the parameters at once', 16, 1);
		RETURN -1;
		--Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END;

	--Making sure the @cols_to_include and @cols_to_exclude parameters are receiving values in proper format
	IF((@cols_to_include IS NOT NULL)
	   AND (PATINDEX('''%''', @cols_to_include) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_include property', 16, 1);
		PRINT 'Specify column names surrounded by single quotes and separated by commas';
		PRINT 'Eg: EXEC [meta].[ExportData] titles, @cols_to_include = "''title_id'',''title''"';
		RETURN -1;
		--Failure. Reason: Invalid use of @cols_to_include property
	END;

	IF((@cols_to_exclude IS NOT NULL)
	   AND (PATINDEX('''%''', @cols_to_exclude) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_exclude property', 16, 1);
		PRINT 'Specify column names surrounded by single quotes and separated by commas';
		PRINT 'Eg: EXEC [meta].[ExportData] titles, @cols_to_exclude = "''title_id'',''title''"';
		RETURN -1;
		--Failure. Reason: Invalid use of @cols_to_exclude property
	END;

	--Checking to see if the database name is specified along wih the table name
	--Your database context should be local to the table for which you want to generate INSERT statements
	--specifying the database name is not allowed

	IF(PARSENAME(@table_name_source, 3)) IS NOT NULL
	BEGIN
		RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.', 16, 1);
		RETURN -1;
		--Failure. Reason: Database name is specified along with the table name, which is not allowed
	END;

	--Checking for the existence of 'user table' or 'view'
	--This procedure is not written to work on system tables
	--To script the data in system tables, just create a view on the system tables and script the view instead

	IF @schema_name_source IS NULL
	BEGIN

		IF((OBJECT_ID(QUOTENAME('dbo') + '.' + QUOTENAME(@table_name_source), 'U') IS NULL)
		   AND (OBJECT_ID(QUOTENAME('dbo') + '.' + QUOTENAME(@table_name_source), 'V') IS NULL))
		BEGIN
			RAISERROR('User table or view not found.', 16, 1);
			PRINT 'You may see this error, if you are not the owner of this table or view. In that case use @schema_name_source parameter to specify the owner name.';
			PRINT 'Make sure you have SELECT permission on that table or view.';
			RETURN -1;
			--Failure. Reason: There is no user table or view with this name
		END;
	END;
	ELSE
	BEGIN
		IF NOT EXISTS(
						 SELECT   
							 1
						 FROM   
							 [INFORMATION_SCHEMA].[TABLES]
						 WHERE 
							 [table_name] = @table_name_source
						 AND [TABLE_SCHEMA] = @schema_name_source
						 AND ([TABLE_TYPE] = 'BASE TABLE'
					     OR [TABLE_TYPE] = 'VIEW')
		)
		BEGIN
			RAISERROR('User table or view not found.', 16, 1);
			PRINT 'You may see this error, if you are not the owner of this table. In that case use @schema_name_source parameter to specify the owner name.';
			PRINT 'Make sure you have SELECT permission on that table or view.';
			RETURN -1; --Failure. Reason: There is no user table or view with this name  
		END;
	END;

	--Variable declarations

	DECLARE 
		@Column_ID			INT					= 0
	  , @sql_truncate		NVARCHAR(MAX)		= N''
	  , @sql_column_list	NVARCHAR(MAX)		= N''
	  , @sql_column_name	SYSNAME				= N''
	  , @sql_top			NVARCHAR(MAX)
	  , @sql_insert			NVARCHAR(MAX)		= N''	
	  , @sql_datatype		SYSNAME	
	  , @sql_value			NVARCHAR(MAX)		= N''			--This is the string that will be finally executed to generate INSERT statements
	  , @sql_identity		SYSNAME				= N''			--Will contain the IDENTITY column's name in the table
	  , @sql_statement		NVARCHAR(MAX)		= N''	  

	--Variable Initialization
	SET @sql_identity = '';
	SET @Column_ID = 0;
	SET @sql_column_name = '';
	SET @sql_column_list = '';
	SET @sql_value = '';

	-- Creates truncate for traget side table
	SET @sql_truncate = IIF(@truncate_target_before_load = 1 AND @table_name_target IS NOT NULL
							, 'TRUNCATE TABLE '  + QUOTENAME(@schema_name_target) + '.' + QUOTENAME(RTRIM(@table_name_target)) + @crlf + 'GO' + @crlf
							, ''
						);

	-- Create the INSERT INTO portion
	SET @sql_insert = 'INSERT INTO ' + QUOTENAME(COALESCE(@schema_name_target, @schema_name_source)) + '.' + QUOTENAME(RTRIM(COALESCE(@table_name_target, @table_name_source)));

	-- Logic for the top N rows
	SET @sql_top = CASE
						WHEN @top IS NULL OR @top < 0
							THEN 'TOP (100) PERCENT'
							ELSE 'TOP ' + LTRIM(STR(@top))
				   END 

	--To get the first column's ID
	SELECT   
		@Column_ID = MIN([ORDINAL_POSITION])
	FROM   
		[INFORMATION_SCHEMA].[COLUMNS] (NOLOCK)
	WHERE 
		[table_name] = @table_name_source
	AND 
		[TABLE_SCHEMA] = @schema_name_source;

	--Loop through all the columns of the table, to get the column names and their data types
	WHILE @Column_ID IS NOT NULL
	BEGIN
		SELECT   
			@sql_column_name	= QUOTENAME([column_name])
		  , @sql_datatype		= [data_type]
		FROM   
			[INFORMATION_SCHEMA].[COLUMNS] (NOLOCK)
		WHERE 
			[ORDINAL_POSITION]	= @Column_ID
		AND [table_name]		= @table_name_source
		AND (@schema_name_source		 IS NULL
			OR [TABLE_SCHEMA]	= @schema_name_source
		);

		IF @cols_to_include IS NOT NULL --Selecting only user specified columns
		BEGIN
			IF CHARINDEX('''' + SUBSTRING(@sql_column_name, 2, LEN(@sql_column_name) - 2) + '''', @cols_to_include) = 0
			BEGIN
				GOTO SKIP_LOOP;
			END;
		END;

		IF @cols_to_exclude IS NOT NULL --Selecting only user specified columns
		BEGIN

			IF CHARINDEX('''' + SUBSTRING(@sql_column_name, 2, LEN(@sql_column_name) - 2) + '''', @cols_to_exclude) <> 0
			BEGIN
				GOTO SKIP_LOOP;
			END;
		END;

		--Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
		IF(
			  SELECT 
				  COLUMNPROPERTY(OBJECT_ID(QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + @table_name_source), SUBSTRING(@sql_column_name, 2, LEN(@sql_column_name) - 2),
				  'IsIdentity')
		) = 1
		BEGIN

			IF @ommit_identity = 0
			BEGIN --Determing whether to include or exclude the IDENTITY column
				SET @sql_identity = @sql_column_name;
			END;
				ELSE
			BEGIN
				GOTO SKIP_LOOP;
			END;
		END;

		--Making sure whether to output computed columns or not

		IF @ommit_computed_cols = 1
		BEGIN

			IF(
				SELECT 
					  COLUMNPROPERTY(OBJECT_ID(QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + @table_name_source), SUBSTRING(@sql_column_name, 2, LEN(@sql_column_name) - 2)
					  ,'IsComputed')) = 1
			BEGIN
				GOTO SKIP_LOOP;
			END;
		END;

		--Tables with columns of IMAGE data type are not supported for obvious reasons

		IF(@sql_datatype IN('image'))
		BEGIN

			IF(@ommit_images = 0)
			BEGIN
				RAISERROR('Tables with image columns are not supported.', 16, 1);
				PRINT 'Use @ommit_images = 1 parameter to generate INSERTs for the rest of the columns.';
				PRINT
				'DO NOT ommit Column List in the INSERT statements. If you ommit column list using @include_column_list=0, the generated INSERTs will fail.';
				RETURN -1; --Failure. Reason: There is a column with image data type
			END;
				ELSE
			BEGIN
				GOTO SKIP_LOOP;
			END;
		END;

		--Determining the data type of the column and depending on the data type, the VALUES part of
		--the INSERT statement is generated. Care is taken to handle columns with NULL values. Also
		--making sure, not to lose any data from flot, real, money, smallmomey, datetime columns

		SET @sql_value = @sql_value + CASE
												  WHEN @sql_datatype IN('char', 'varchar', 'nchar', 'nvarchar')
													  THEN 'COALESCE('''''''' + REPLACE(RTRIM(' + @sql_column_name + '),'''''''','''''''''''')+'''''''',''NULL'')'
												  WHEN @sql_datatype IN('datetime', 'smalldatetime')
													  THEN 'COALESCE('''''''' + RTRIM(CONVERT(char,' + @sql_column_name + ',109))+'''''''',''NULL'')'
												  WHEN @sql_datatype IN('uniqueidentifier')
													  THEN 'COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @sql_column_name +
													  ')),'''''''','''''''''''')+'''''''',''NULL'')'
												  WHEN @sql_datatype IN('text', 'ntext')
													  THEN 'COALESCE('''''''' + REPLACE(CONVERT(char(8000),' + @sql_column_name +
													  '),'''''''','''''''''''')+'''''''',''NULL'')'
												  WHEN @sql_datatype IN('binary', 'varbinary')
													  THEN 'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @sql_column_name + '))),''NULL'')'
												  WHEN @sql_datatype IN('timestamp', 'rowversion')
													  THEN CASE
															   WHEN @include_timestamp = 0
																   THEN '''DEFAULT'''
															   ELSE 'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @sql_column_name + '))),''NULL'')'
														   END
												  WHEN @sql_datatype IN('float', 'real', 'money', 'smallmoney')
													  THEN 'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' + @sql_column_name + ',2)' + ')),''NULL'')'
												  ELSE 'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' + @sql_column_name + ')' + ')),''NULL'')'
											  END + '+' + ''',''' + ' + ';

		--Generating the column list for the INSERT statement
		SET @sql_column_list = @sql_column_list + @sql_column_name + ',';

		SKIP_LOOP: --The label used in GOTO
		
			SELECT   
				@Column_ID = MIN([ORDINAL_POSITION])
			FROM   
				[INFORMATION_SCHEMA].[COLUMNS](NOLOCK)
			WHERE 
				[table_name] = @table_name_source
			AND [ORDINAL_POSITION] > @Column_ID
			AND (@schema_name_source IS NULL
				OR [TABLE_SCHEMA] = @schema_name_source);

		--Loop ends here!
	END;

	--To get rid of the extra characters that got concatenated during the last run through the loop
	SET @sql_column_list		= LEFT(@sql_column_list, LEN(@sql_column_list) - 1);
	SET @sql_value				= LEFT(@sql_value, LEN(@sql_value) - 6);

	IF LTRIM(@sql_column_list) = ''
	BEGIN
		RAISERROR('No columns to select. There should at least be one column to generate the output', 16, 1);
		RETURN -1;
		--Failure. Reason: Looks like all the columns are ommitted using the @cols_to_exclude parameter
	END;


	--Forming the final string that will be executed, to output the INSERT statements
	SET @sql_statement = ' 
		;WITH cte_insert AS (
			SELECT' 
			+ ' '
			+ @sql_top
			+ ' ' 
			+ @sql_column_list 
			+ ' ' 
			+ 'FROM' 
			+ ' ' 
			+	CASE 
					WHEN @schema_name_source IS NULL
						THEN QUOTENAME('dbo')
						ELSE QUOTENAME(LTRIM(RTRIM(@schema_name_source))) 
				END
			+ '.'
			+ QUOTENAME(RTRIM(@table_name_source)) 
			+ ' (NOLOCK)
			)
			SELECT @return_etl += '''
								+ CHAR(13) + CHAR(10) + CHAR(9)
								+ '(''+ ' 
								+ @sql_value + '+''), ''' 
								+ ' ' 
								+ COALESCE(@from,
											' FROM cte_insert;'
									)
			            
		
	--Determining whether to ouput any debug information
	IF @sql_debug = 1
	BEGIN
		DECLARE @topstr NVARCHAR(100) = LTRIM(STR(@top))

		RAISERROR('/*****START OF DEBUG INFORMATION*****', 0, 1) WITH NOWAIT
		RAISERROR('Truncate Statement', 0 ,1) WITH NOWAIT
		RAISERROR(@sql_truncate, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('INSERT statement:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_insert, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('Column List:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_column_list, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('Top X Rows returned:', 0, 1) WITH NOWAIT
		RAISERROR(@topstr, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('SchemaName:', 0, 1) WITH NOWAIT
		RAISERROR(@schema_name_source, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('TableName:', 0, 1) WITH NOWAIT
		RAISERROR(@table_name_source, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('Value List:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_value, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('From:', 0, 1) WITH NOWAIT
		RAISERROR(@from, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('Generated dynamic sql statement:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_statement, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
	END;

	SET @return_etl += 'SET NOCOUNT ON' + @crlf
	
	-- IDENTITY DETERMINATION
	IF(@sql_identity <> '')
	BEGIN
		SET @return_etl += 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + QUOTENAME(@table_name_source) + ' ON' + @crlf
		SET @return_etl += 'GO' + @crlf
	END;

	-- DISABLE CONSTRAINTS?
	IF @disable_constraints = 1
	   AND (OBJECT_ID(QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + @table_name_source, 'U') IS NOT NULL)
	BEGIN

		IF @schema_name_source IS NULL
		BEGIN
			SET @return_etl += 'ALTER TABLE ' + QUOTENAME(COALESCE(@table_name_target, @table_name_source)) + ' NOCHECK CONSTRAINT ALL' + @crlf;
		END;
			ELSE
		BEGIN
			SET @return_etl += 'ALTER TABLE ' + QUOTENAME(@schema_name_source) + '.' + QUOTENAME(COALESCE(@table_name_target, @table_name_source)) + ' NOCHECK CONSTRAINT ALL' + @crlf;
		END;

		SET @return_etl += 'GO'  + @crlf;
	END;

	-- ACTUAL CONSTRUCTION BEGINS
	-- TRUNCATE STATEMENT
	SET @return_etl  +=  RTRIM(@sql_truncate) + @crlf;

	-- INSERT INTO
	SET @return_etl  +=  @crlf + RTRIM(@sql_insert) + @crlf;

	-- COLUMN LIST (IsIncluded?)
	SET @return_etl += IIF(@include_column_list = 0
							, ''
							, CHAR(9) 
							  + '(' 
							  + @sql_column_list 
							  + ')' 
							  + @crlf
					)

	-- VALUES
	SET @return_etl  += 'VALUES';

	DECLARE @sql_parameter NVARCHAR(MAX) = N'@return_etl NVARCHAR(MAX) OUTPUT'

	IF @sql_debug = 1
	BEGIN
		RAISERROR('Statement Sent (@sql_statement) to sp_executesql:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_statement, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('Parameter Sent (@return_etl) to sp_executesql:', 0, 1) WITH NOWAIT
		RAISERROR(@return_etl, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
	END


	--All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes!
	EXEC sp_executesql 
				@stmt			= @sql_statement
			,	@param			= @sql_parameter
			,	@return_etl		= @return_etl OUTPUT


	-- Remove last comma
	SET @return_etl = SUBSTRING(@return_etl, 1, LEN(@return_etl) - 1)

	--SET @return_etl += @sql_statement
	SET @return_etl += @crlf;
	
	IF @sql_debug = 1
	BEGIN
		RAISERROR('Output Parameter Polulated @Value:', 0, 1) WITH NOWAIT
		RAISERROR(@sql_statement, 0, 1) WITH NOWAIT
		RAISERROR('', 0, 1) WITH NOWAIT
		RAISERROR('New Value of @return_etl:', 0, 1) WITH NOWAIT
		RAISERROR(@return_etl, 0, 1) WITH NOWAIT
	END

	IF @disable_constraints = 1
	   AND (OBJECT_ID(QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + @table_name_source, 'U') IS NOT NULL)
	BEGIN

		IF @schema_name_source IS NULL
		BEGIN
			SELECT @return_etl +=
				'ALTER TABLE ' + QUOTENAME(COALESCE(@table_name_target, @table_name_source)) + ' CHECK CONSTRAINT ALL' + @crlf;
		END;
			ELSE
		BEGIN
			SELECT @return_etl +=
				'ALTER TABLE ' + QUOTENAME(@schema_name_source) + '.' + QUOTENAME(COALESCE(@table_name_target, @table_name_source)) + ' CHECK CONSTRAINT ALL'   + @crlf;
		END;

		SELECT @return_etl +=
			'GO' + @crlf;
	END;


	IF(@sql_identity <> '')
	BEGIN
		
		SELECT @return_etl +=
			'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@schema_name_source, USER_NAME())) + '.' + QUOTENAME(@table_name_source) + ' OFF' + @crlf;

		SELECT @return_etl +=
			'GO'  + @crlf;
	END;

	SELECT @return_etl += @crlf +
		'SET NOCOUNT OFF' + @crlf;

	RETURN 0; --Success. We are done!
END;
GO
