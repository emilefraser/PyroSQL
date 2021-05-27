SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_CREATE_SCHEMA_UNIT_TEST]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_CREATE_SCHEMA_UNIT_TEST] AS' 
END
GO

--************************************************************************************************
--NOTE: this procedure should run in context of the database for which script creates a unit tests
--DROP PROCEDURE DBO.DBTD_CREATE_SCHEMA_UNIT_TEST
ALTER PROCEDURE [construct].[DBTD_CREATE_SCHEMA_UNIT_TEST]
	@v_FullObjectName		SYSNAME,							--Full name should be provided int he MyDatabase.MySchema.MyObject format
	@v_UnitTestSQL			NVARCHAR(MAX) OUTPUT,
	@v_UnitTestName			NVARCHAR(128) OUTPUT,

	@v_UnitTestSuite		SYSNAME = 'DBSchemaTests',			--The name of the unit test suite 
	@v_FrameworkDatabase	SYSNAME = 'DBTestDriven',
	@v_GenerateAssertsThatCheckTableAndViewColumns BIT = 1,		--Set to 1 to check tables or views columns
	@v_GenerateAssertsThatCheckTableIndexes BIT = 1,
	@v_AutoGenMessage		VARCHAR(500) = NULL,
	@v_GenerateAssertsThatCheckParameters BIT = 1				--Set to 1 to check that parameter exist for an object that accepts parameters
  AS
BEGIN
	SET NOCOUNT ON
	DECLARE @v_sql_AutoGenMessage	NVARCHAR(250) = ISNULL('/*'+ ISNULL(@v_AutoGenMessage, CAST(NEWID() AS VARCHAR(50)))+'*/','') 
	DECLARE @v_sql_EndOfLine		NVARCHAR(10) = ' ' + CHAR(10), --CHAR(13) --CHAR(10) + CHAR(13)
			@v_sql_Tab				NVARCHAR(10) = CHAR(9)
	DECLARE	@v_sql_CommentSeparator NVARCHAR(500) = '/**************************************************************************************************/' + @v_sql_EndOfLine,
			@v_sql_UnitTestPREFIX	NVARCHAR(MAX) = 'UT_'+@v_UnitTestSuite+'_'	
	DECLARE @v_sql_USE_DATABASE		NVARCHAR(MAX) = @v_sql_CommentSeparator + 'USE ' + @v_FrameworkDatabase + @v_sql_EndOfLine + 'GO' + @v_sql_EndOfLine + @v_sql_EndOfLine
	DECLARE @v_sql_UnitTestCREATE	NVARCHAR(MAX) = ISNULL(@v_sql_AutoGenMessage + @v_sql_EndOfLine, '') + 'CREATE PROCEDURE '
	DECLARE @v_sql_UnitTestBEGIN	NVARCHAR(MAX) = @v_sql_EndOfLine + @v_sql_Tab + '(@v_Debug BIT = 0) ' + @v_sql_EndOfLine 
													+ 'AS ' + @v_sql_EndOfLine 
													+ 'BEGIN ' + @v_sql_EndOfLine 
													+ @v_sql_Tab + 'EXEC DBTD_UNIT_TEST '''+@v_UnitTestSuite+''';' + @v_sql_EndOfLine
													+ @v_sql_Tab + 'EXEC DBTD_USE_TRANSACTION ''Just in case''' + @v_sql_EndOfLine 
	DECLARE @v_sql_UnitTestEND		NVARCHAR(MAX) = @v_sql_EndOfLine + 'END' + @v_sql_EndOfLine +'GO'+@v_sql_EndOfLine 

	DECLARE @v_sql_FullObjectName	NVARCHAR(128),
			@v_ObjectID				BIGINT,
			@v_ObjectType			VARCHAR(128), 
			@v_SQL					NVARCHAR(MAX) = '',
			@v_AssertsSQL			NVARCHAR(MAX) = '',
			@v_DependentObjectsAssertsSQL NVARCHAR(MAX) = '',
			@v_Server				NVARCHAR(2000),
			@v_Database				NVARCHAR(2000),
			@v_Schema				NVARCHAR(2000),
			@v_CorrectedName		NVARCHAR(2000),
			@v_Object				NVARCHAR(2000),
			@v_ObjectTypeDesc		NVARCHAR(128),
			@v_Has_DependentObjects BIT = 0,
			@v_Has_AssertsForColumns BIT = 0,
			@v_Has_AssertsForIndexes BIT = 0,
			@v_TheUnitTestName		NVARCHAR(128) = ''

	CREATE TABLE #ObjectRelatedInformation(
		ObjectID			BIGINT,
		ObjectName			NVARCHAR(128),
		ObjectType			NVARCHAR(128),
		ObjectTypeDesc		NVARCHAR(128),
		IsNullable			BIT,
		IsUniqueConstraint	BIT,
		ObjectDefinition	NVARCHAR(MAX)
	)

	EXEC DBTD_SPLIT_FOUR_PART_OBJECT_NAME 
		@v_FullObjectName, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_sql_FullObjectName OUTPUT,
		@v_CorrectTempTablesLocation = 1;

	SET @v_TheUnitTestName = '[' + @v_sql_UnitTestPREFIX + UPPER(REPLACE(REPLACE(@v_Schema, '[',''),']','')) + '_' + REPLACE(REPLACE(@v_Object, '[',''),']','') + ']'
	SET @v_ObjectID = OBJECT_ID(@v_sql_FullObjectName);
	SET @v_SQL = 'INSERT INTO #ObjectRelatedInformation(ObjectType,ObjectTypeDesc) SELECT [type], type_desc FROM sys.objects WHERE object_id = ' + CAST(@v_ObjectID AS VARCHAR(50))
	EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

	SELECT 
		TOP 1 
		@v_ObjectType = ObjectType,
		@v_ObjectTypeDesc = ObjectTypeDesc
	FROM #ObjectRelatedInformation

	--**** PART 1 - Get Generic assersions ************************************************************************************************************************************************************
	SET @v_AssertsSQL = 
			CASE 
				--TODO:
				--PC	CLR_STORED_PROCEDURE
				--IT	INTERNAL_TABLE
				--SQ	SERVICE_QUEUE
				--IF	SQL_INLINE_TABLE_VALUED_FUNCTION
				--TT	TYPE_TABLE
				WHEN @v_ObjectType = 'U' THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_TABLE_EXISTS '''	+ @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
				WHEN @v_ObjectType = 'V' THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_VIEW_EXISTS '''	+ @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
				WHEN @v_ObjectType = 'P' THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_PROC_EXISTS '''	+ @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
				WHEN @v_ObjectType IN ('TF','FN','FS', 'FT', 'AF', 'IF') THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_FUNC_EXISTS  ''' + @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
				WHEN @v_ObjectType = 'SN' THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_SYNONYM_EXISTS  '''+ @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
				ELSE @v_sql_Tab + 'EXEC DBTD_ASSERT_OBJECT_EXISTS '''			+ @v_sql_FullObjectName + ''', ''Cannot find '+@v_ObjectTypeDesc+' object in the '+@v_Database+' database'';' + @v_sql_EndOfLine
			END
		
	--**** PART 2 - Get clildren objects asserts for the given object ************************************************************************************************************************************************************
	TRUNCATE TABLE #ObjectRelatedInformation
	SET @v_SQL = 'INSERT INTO #ObjectRelatedInformation(ObjectID,ObjectName,ObjectType,ObjectTypeDesc) SELECT object_id, name, [type], type_desc FROM sys.objects WHERE parent_object_id = ' + CAST(@v_ObjectID AS VARCHAR(50))
	EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

	SET @v_SQL = 'UPDATE o SET o.ObjectDefinition = dc.[definition] FROM #ObjectRelatedInformation AS o INNER JOIN sys.default_constraints AS dc ON o.ObjectID = dc.object_id WHERE o.ObjectType = ''D'''
	EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

	SET @v_DependentObjectsAssertsSQL = ''
	SELECT 
		@v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
									+ COALESCE( 
											CASE
												--TODO: 
												--C 	CHECK_CONSTRAINT
												--D 	!!!! DEFAULT_CONSTRAINT - TODO: we have everything to get this simplemented
												WHEN ObjectType = 'D' THEN @v_sql_Tab + ' EXEC DBTD_ASSERT_DEFAULT_CONSTRAINT @v_DefaultConstrant=''' + ObjectName + ''', @v_TableName=''' + @v_sql_FullObjectName + ''', '
																			+ '@v_DefaultConstrantDefinition=''' + REPLACE(ObjectDefinition, '''','''''') + ''','
																			+ '@v_UserMessage=''Cannot find ' + UPPER(ObjectTypeDesc) + ' in the ' + @v_Database + ' database''; ' + @v_sql_EndOfLine

												--F 	FOREIGN_KEY_CONSTRAINT
												--IT	INTERNAL_TABLE
												--PK	PRIMARY_KEY_CONSTRAINT
												--UQ	UNIQUE_CONSTRAINT
												WHEN ObjectType = 'TR' THEN @v_sql_Tab + ' EXEC DBTD_ASSERT_TRIGGER_EXISTS ''[' + REPLACE(REPLACE(@v_Database,'[',''),']','') + '].[' + REPLACE(REPLACE(@v_Schema,'[',''),']','') + '].['			
																			+ REPLACE(REPLACE(ObjectName,'[',''),']','') + ']'', ''Cannot find ' 				  	
																			+ UPPER(ObjectTypeDesc) + ' in the '
																			+ @v_Database + ' database''; ' + @v_sql_EndOfLine
											END, '')
	FROM #ObjectRelatedInformation

	--Add asserts for depended objects
	IF @v_DependentObjectsAssertsSQL IS NOT NULL AND LTRIM(RTRIM(@v_DependentObjectsAssertsSQL)) != ''
	BEGIN
		SET @v_Has_DependentObjects = 1
		SET @v_AssertsSQL = @v_AssertsSQL + @v_sql_EndOfLine + @v_sql_Tab + '/*Check Related Objects*/' + @v_sql_EndOfLine + @v_DependentObjectsAssertsSQL 
		SET @v_DependentObjectsAssertsSQL = '' --Reset value
	END

	--**** PART 3 - For tables and view check their columns ************************************************************************************************************************************************************
	IF	@v_ObjectType IN ('U','V') AND @v_GenerateAssertsThatCheckTableAndViewColumns = 1
	BEGIN
		TRUNCATE TABLE #ObjectRelatedInformation
		SET @v_SQL = 
			'INSERT INTO #ObjectRelatedInformation(ObjectID, ObjectName, ObjectType, ObjectTypeDesc, IsNullable) 
			 SELECT c.column_id, c.name, t.name, '''', c.is_nullable
			 FROM '+@v_Database+'.sys.columns c
			 INNER JOIN '+@v_Database+'.sys.types t
				ON c.user_type_id = t.user_type_id
			 WHERE c.object_id = ' + CAST(@v_ObjectID AS VARCHAR(50))
		EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

		SELECT 
			@v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
				+ COALESCE( CASE
								WHEN @v_ObjectType = 'V'
									THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_COLUMN_EXISTS '''	+ @v_sql_FullObjectName + ''', '''+ObjectName+''', ''Cannot find column ['+ObjectName+'] in the '+@v_sql_FullObjectName+''';' + @v_sql_EndOfLine
								WHEN @v_ObjectType = 'U'
									THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_COLUMN_EXISTS '''	+ @v_sql_FullObjectName + ''', '''+ObjectName+''', ''Cannot find column ['+ObjectName+'] in the '+@v_sql_FullObjectName+''';' + @v_sql_EndOfLine 
											+ @v_sql_Tab + 'EXEC DBTD_ASSERT_COLUMN_TYPE '''	+ @v_sql_FullObjectName + ''', '''+ObjectName+''', ''' + ObjectType + ''', ''Column ['+ObjectName+'] does not have expected type of ['+ObjectType+'] in the '+@v_sql_FullObjectName+' table'';' + @v_sql_EndOfLine
											+ @v_sql_Tab + 'EXEC '
													+ CASE
														WHEN IsNullable = 0 THEN 'DBTD_ASSERT_COLUMN_IS_NOT_NULLABLE'
														ELSE 'DBTD_ASSERT_COLUMN_IS_NULLABLE'
													END
													+ ' ''' + @v_sql_FullObjectName + ''', '''+ObjectName+''', ''Column ['+ObjectName+'] NULLABILITY criteria does not match expectations in the '+@v_sql_FullObjectName+' table'';' + @v_sql_EndOfLine 
							END	
						, '')
		FROM #ObjectRelatedInformation
		ORDER BY ObjectID ASC --consistency

		SELECT @v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
			+ @v_sql_EndOfLine + @v_sql_Tab + '/*Check number of columns in the TABLE*/' + @v_sql_EndOfLine
			+ @v_sql_Tab + 'EXEC DBTD_ASSERT_IS_EXPECTED_COUNT ' + CAST(COUNT(*) AS VARCHAR(50)) + ', ''' + @v_Database + '.sys.columns'', '' object_id = OBJECT_ID(''''' + @v_sql_FullObjectName + ''''') '', ''We expecting only '+ CAST(COUNT(*) AS VARCHAR(50)) +' coulumns, seems like table had an extra column added.''  '
			+ @v_sql_EndOfLine 
		FROM #ObjectRelatedInformation

		--Add asserts for coluns
		IF	@v_DependentObjectsAssertsSQL IS NOT NULL AND LTRIM(RTRIM(@v_DependentObjectsAssertsSQL)) != '' AND @v_GenerateAssertsThatCheckTableAndViewColumns = 1
		BEGIN
			SET @v_AssertsSQL = @v_AssertsSQL + @v_sql_EndOfLine + @v_sql_Tab + '/*Check TABLE Columns*/' + @v_sql_EndOfLine + @v_DependentObjectsAssertsSQL 
			SET @v_DependentObjectsAssertsSQL = ''
			SET @v_Has_AssertsForColumns = 1
		END
	END

	--**** PART 4 - Checks that parameter exist for an object that accepts parameters **********************************************************************************************************************************
	TRUNCATE TABLE #ObjectRelatedInformation
	SET @v_SQL = 
		'INSERT INTO #ObjectRelatedInformation(ObjectID,ObjectName) 
			SELECT p.parameter_id, p.name
			FROM '+@v_Database+'.sys.parameters p
			WHERE name != '''' 
				AND name IS NOT NULL
				AND object_id = ' + CAST(@v_ObjectID AS VARCHAR(50))
	EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

	IF	EXISTS (SELECT TOP 1 * FROM #ObjectRelatedInformation) AND @v_GenerateAssertsThatCheckParameters = 1
	BEGIN
		SET @v_DependentObjectsAssertsSQL = ''
		SELECT 
			@v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
				+ COALESCE( @v_sql_Tab + 'EXEC DBTD_ASSERT_PARAMETER_EXISTS @v_ObjectName='''	+ @v_sql_FullObjectName + ''', @v_ParameterName='''+ObjectName+''', @v_UserMessage=''Cannot find parameter ['+ObjectName+'] for the '+@v_sql_FullObjectName+''';' + @v_sql_EndOfLine
						, '')
		FROM #ObjectRelatedInformation
		ORDER BY ObjectID ASC --consistency


		SELECT @v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
			+ @v_sql_EndOfLine + @v_sql_Tab + '/*Check number of PARAMETERS*/' + @v_sql_EndOfLine
			+ @v_sql_Tab + 'EXEC DBTD_ASSERT_IS_EXPECTED_COUNT ' + CAST(COUNT(*) AS VARCHAR(50)) + ', ''' + @v_Database + '.sys.parameters'', '' name != '''' AND name IS NOT NULL AND object_id = OBJECT_ID(''''' + @v_sql_FullObjectName + ''''') '', ''We expecting only '+ CAST(COUNT(*) AS VARCHAR(50)) +' PARAMETERS, seems like we found extra.''  '
			+ @v_sql_EndOfLine 
		FROM #ObjectRelatedInformation

		--Add asserts for coluns
		IF	@v_DependentObjectsAssertsSQL IS NOT NULL AND LTRIM(RTRIM(@v_DependentObjectsAssertsSQL)) != '' AND @v_GenerateAssertsThatCheckParameters = 1
		BEGIN
			SET @v_AssertsSQL = @v_AssertsSQL + @v_sql_EndOfLine + @v_sql_Tab + '/*Check OBJECT Parameters*/' + @v_sql_EndOfLine + @v_DependentObjectsAssertsSQL 
			SET @v_DependentObjectsAssertsSQL = ''
		END
	END

	--**** PART 5 - For tables check their indexes ************************************************************************************************************************************************************
	IF	@v_ObjectType IN ('U') AND @v_GenerateAssertsThatCheckTableIndexes = 1
	BEGIN
		TRUNCATE TABLE #ObjectRelatedInformation
		SET @v_SQL = 
			'INSERT INTO #ObjectRelatedInformation(ObjectName,ObjectType,ObjectTypeDesc, IsUniqueConstraint) 
			 SELECT i.name, CAST(i.type AS VARCHAR), '''', i.is_unique_constraint
			 FROM sys.indexes i
			 WHERE i.name IS NOT NULL
				AND i.object_id = ' + CAST(@v_ObjectID AS VARCHAR(50))
		EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL; 

		SELECT 
			@v_DependentObjectsAssertsSQL = @v_DependentObjectsAssertsSQL
				+ COALESCE( 
							@v_sql_Tab + 'EXEC DBTD_ASSERT_INDEX_EXISTS '''+ObjectName+''', ''' + @v_sql_FullObjectName + ''', ''Cannot find index ['+ObjectName+'] for the '+@v_sql_FullObjectName+' table'';' + @v_sql_EndOfLine		
							+ CASE 
									WHEN ObjectType = '1' --IsClusteredAssertNeeded
										THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_INDEX_CLUSTERED '''+ObjectName+''', ''' + @v_sql_FullObjectName + ''', ''Index ['+ObjectName+'] expected to be CLUSTERED for the '+@v_sql_FullObjectName+' table'';' + @v_sql_EndOfLine		
									ELSE '' 
								END 
							+ CASE 
									WHEN IsUniqueConstraint = 1 --IsUniqueAssertNeeded
										THEN @v_sql_Tab + 'EXEC DBTD_ASSERT_INDEX_UNIQUE '''+ObjectName+''', ''' + @v_sql_FullObjectName + ''', ''Index ['+ObjectName+'] expected to be UNIQUE for the '+@v_sql_FullObjectName+' table'';' + @v_sql_EndOfLine		
									ELSE ''
								END
						, '')
		FROM #ObjectRelatedInformation

		--Add asserts for indexes
		IF	@v_DependentObjectsAssertsSQL IS NOT NULL AND LTRIM(RTRIM(@v_DependentObjectsAssertsSQL)) != '' AND @v_GenerateAssertsThatCheckTableIndexes = 1
		BEGIN
			SET @v_AssertsSQL = @v_AssertsSQL + @v_sql_EndOfLine + @v_sql_Tab + '/*Check Table Indexes*/' + @v_sql_EndOfLine + @v_DependentObjectsAssertsSQL 
			SET @v_Has_AssertsForIndexes = 1
			SET @v_DependentObjectsAssertsSQL = ''
		END
	END

	--**** PART 10 - Assemble the Unit Test ************************************************************************************************************************************************************
	IF LTRIM(RTRIM(@v_AssertsSQL)) != '' AND @v_AssertsSQL IS NOT NULL
	BEGIN 
		SET @v_UnitTestSQL = 
				@v_sql_USE_DATABASE 
				+ @v_sql_CommentSeparator 
				+ 'EXEC DBTD_DROP_PROC_IF_EXISTS '''+@v_TheUnitTestName+''', '''';' + @v_sql_EndOfLine
				+ 'GO' + @v_sql_EndOfLine + @v_sql_EndOfLine
				+ @v_sql_UnitTestCREATE + @v_TheUnitTestName
				+ @v_sql_UnitTestBEGIN	
				+ @v_AssertsSQL
				+ @v_sql_UnitTestEND	
		SET @v_UnitTestName = @v_TheUnitTestName
	END 
	ELSE BEGIN
		SET @v_UnitTestSQL = NULL
		SET @v_UnitTestName = NULL
	END
END

GO
