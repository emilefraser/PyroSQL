
GO
CREATE PROC [dbo].[sp_CompareDb]
(
	@SourceDB SYSNAME,
	@TargetDb SYSNAME
)
AS
BEGIN
/*
	DECLARE @SourceDB SYSNAME='DB1',@TargetDb SYSNAME='DB2'
*/
	SET NOCOUNT ON;
	SET ANSI_WARNINGS ON;
	SET ANSI_NULLS ON;   

	DECLARE @sqlStr VARCHAR(8000)
	SET @SourceDB = RTRIM(LTRIM(@SourceDB))
	IF DB_ID(@SourceDB) IS NULL 
	BEGIN
		PRINT 'Error: Unable to find the database '+ @SourceDB +'!!!'
		RETURN
	END

	SET @TargetDb = RTRIM(LTRIM(@TargetDb))
	IF DB_ID(@SourceDB) IS NULL 
	BEGIN
		PRINT 'Error: Unable to find the database '+ @TargetDb +'!!!'
		RETURN
	END
	
	PRINT Replicate('-', Len(@SourceDB) + Len(@TargetDb) + 25); 
	PRINT 'Comparing databases ' + @SourceDB + ' and ' + @TargetDb; 
	PRINT Replicate('-', Len(@SourceDB) + Len(@TargetDb) + 25);
     
	----------------------------------------------------------------------------------------- 
	-- Create temp tables needed to hold the db structure 
	----------------------------------------------------------------------------------------- 	
	
	IF OBJECT_ID('TEMPDB..#TABLIST_SOURCE')IS NOT NULL
		DROP TABLE #TABLIST_SOURCE;
	IF OBJECT_ID('TEMPDB..#TABLIST_TARGET') IS NOT NULL
		DROP TABLE #TABLIST_TARGET;
	IF OBJECT_ID('TEMPDB..#IDXLIST_SOURCE') IS NOT NULL
		DROP TABLE #IDXLIST_SOURCE
	IF OBJECT_ID('TEMPDB..#IDXLIST_TARGET') IS NOT NULL
		DROP TABLE #IDXLIST_TARGET
	IF OBJECT_ID('TEMPDB..#FKLIST_SOURCE') IS NOT NULL
		DROP TABLE #FKLIST_SOURCE
	IF OBJECT_ID('TEMPDB..#FKLIST_TARGET') IS NOT NULL
		DROP TABLE #FKLIST_TARGET
	IF OBJECT_ID('TEMPDB..#TAB_RESULTS') IS NOT NULL
		DROP TABLE #TAB_RESULTS
	IF OBJECT_ID('TEMPDB..#IDX_RESULTS') IS NOT NULL
		DROP TABLE #IDX_RESULTS
	IF OBJECT_ID('TEMPDB..#FK_RESULTS') IS NOT NULL
		DROP TABLE #FK_RESULTS

	CREATE TABLE #TABLIST_SOURCE
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15)
	)

	CREATE TABLE #TABLIST_TARGET
	(
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15)
	)

	CREATE TABLE #IDXLIST_SOURCE (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLE_NAME SYSNAME,
		IDX_NAME SYSNAME,
		IDX_TYPE VARCHAR(20),
		IS_PRIMARY_KEY VARCHAR(10),
		IS_UNIQUE VARCHAR(10),
		IDX_COLUMNS VARCHAR(1000),
		IDX_INCLUDED_COLUMNS VARCHAR(1000)
	);

	CREATE TABLE #IDXLIST_TARGET (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLE_NAME SYSNAME,
		IDX_NAME SYSNAME,
		IDX_TYPE VARCHAR(20),
		IS_PRIMARY_KEY VARCHAR(10),
		IS_UNIQUE VARCHAR(10),
		IDX_COLUMNS VARCHAR(1000),
		IDX_INCLUDED_COLUMNS VARCHAR(1000)
	);

	CREATE TABLE #FKLIST_SOURCE (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		FK_NAME SYSNAME,
		FK_TABLE SYSNAME,
		FK_COLUMNS VARCHAR(1000),
		PK_TABLE SYSNAME,
		PK_COLUMNS VARCHAR(1000)
	);

	CREATE TABLE #FKLIST_TARGET (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		FK_NAME SYSNAME,
		FK_TABLE SYSNAME,
		FK_COLUMNS VARCHAR(1000),
		PK_TABLE SYSNAME,
		PK_COLUMNS VARCHAR(1000)
	);

	CREATE TABLE #TAB_RESULTS (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLENAME SYSNAME,
		COLUMNNAME SYSNAME,
		DATATYPE SYSNAME,
		NULLABLE VARCHAR(15),
		REASON VARCHAR(150)
	);

	CREATE TABLE #IDX_RESULTS (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		TABLE_NAME SYSNAME,
		IDX_NAME SYSNAME,
		IDX_TYPE VARCHAR(20),
		IS_PRIMARY_KEY VARCHAR(10),
		IS_UNIQUE VARCHAR(10),
		IDX_COLUMNS VARCHAR(1000),
		IDX_INCLUDED_COLUMNS VARCHAR(1000),
		REASON VARCHAR(150)
	);

	CREATE TABLE #FK_RESULTS (
		ID INT IDENTITY (1, 1),
		DATABASENAME SYSNAME,
		FK_NAME SYSNAME,
		FK_TABLE SYSNAME,
		FK_COLUMNS VARCHAR(1000),
		PK_TABLE SYSNAME,
		PK_COLUMNS VARCHAR(1000),
		REASON VARCHAR(150)
	);

	PRINT 'Getting table and column list!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	BEGIN
	INSERT INTO #TABLIST_SOURCE (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE)
	EXEC ('SELECT ''' + @SourceDB + ''', T.TABLE_NAME TABLENAME, 
				 C.COLUMN_NAME COLUMNNAME,
				 TY.name + case when TY.name IN (''char'',''varchar'',''nvarchar'') THEN	
					''(''+CASE WHEN C.CHARACTER_MAXIMUM_LENGTH>0 THEN CAST(C.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) ELSE ''max''END+'')''
					ELSE	
						''''
					END
					DATATYPE,
					CASE WHEN C.is_nullable=''NO'' THEN	
						''NOT NULL'' 
						ELSE
						''NULL''
					END NULLABLE
						FROM ' + @SourceDB + '.INFORMATION_SCHEMA.TABLES T 
							INNER JOIN  ' + @SourceDB + '.INFORMATION_SCHEMA.COLUMNS C
								ON T.TABLE_NAME=C.TABLE_NAME
								and T.TABLE_CATALOG=C.TABLE_CATALOG
								and T.TABLE_SCHEMA=C.TABLE_SCHEMA
							 INNER JOIN ' + @SourceDB + '.sys.types TY
							ON C.DATA_TYPE =TY.name		
							ORDER BY TABLENAME, COLUMNNAME,C.ORDINAL_POSITION');

	INSERT INTO #TABLIST_TARGET (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE)
	EXEC ('SELECT ''' + @TargetDB + ''', T.TABLE_NAME TABLENAME, 
				 C.COLUMN_NAME COLUMNNAME,
				 TY.name + case when TY.name IN (''char'',''varchar'',''nvarchar'') THEN	
					''(''+CASE WHEN C.CHARACTER_MAXIMUM_LENGTH>0 THEN CAST(C.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) ELSE ''max''END+'')''
					ELSE	
						''''
					END
					DATATYPE,
					CASE WHEN C.is_nullable=''NO'' THEN	
						''NOT NULL'' 
						ELSE
						''NULL''
					END NULLABLE
						FROM ' + @TargetDB + '.INFORMATION_SCHEMA.TABLES T 
							INNER JOIN  ' + @TargetDB + '.INFORMATION_SCHEMA.COLUMNS C
								ON T.TABLE_NAME=C.TABLE_NAME
								and T.TABLE_CATALOG=C.TABLE_CATALOG
								and T.TABLE_SCHEMA=C.TABLE_SCHEMA
							 INNER JOIN ' + @TargetDB + '.sys.types TY
							ON C.DATA_TYPE =TY.name		
							ORDER BY TABLENAME, COLUMNNAME,C.ORDINAL_POSITION');


	PRINT 'Getting index list!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	INSERT INTO #IDXLIST_SOURCE (DATABASENAME, TABLE_NAME, IDX_NAME, IDX_TYPE, IS_PRIMARY_KEY, IS_UNIQUE, IDX_COLUMNS, IDX_INCLUDED_COLUMNS)
	EXEC ('WITH CTE AS ( 
						 SELECT      ic.index_id + ic.object_id AS IndexId,t.name AS TableName 
												 ,i.name AS IndexName
												 ,case when ic.is_included_column =0 then
														c.name end AS ColumnName
												,case when ic.is_included_column =1 then
														c.name end AS IncludedColumn
														,i.type_desc,ic.key_ordinal 
												 ,i.is_primary_key,i.is_unique 
						 FROM  ' + @SourceDB + '.sys.indexes i 
						 INNER JOIN ' + @SourceDB + '.sys.index_columns ic 
										 ON  i.index_id    =   ic.index_id 
										 AND i.object_id   =   ic.object_id 
						 INNER JOIN ' + @SourceDB + '.sys.columns c 
										 ON  ic.column_id  =   c.column_id 
										 AND i.object_id   =   c.object_id 
						 INNER JOIN (SELECT object_id,name FROM ' + @SourceDB + '.sys.tables  union SELECT object_id,name FROM ' + @SourceDB + '.sys.views)t 
										 ON  i.object_id = t.object_id 
	) 
	SELECT ''' + @SourceDB + ''',c.TableName TABLE_NAME,c.IndexName INDEX_NAME,c.type_desc INDEX_TYPE ,c.is_primary_key IS_PRIMARY_KEY,c.is_unique IS_UNIQUE
				 ,STUFF( ( SELECT '',''+ a.ColumnName FROM CTE a WHERE c.IndexId = a.IndexId ORDER BY key_ordinal FOR XML PATH('''')),1 ,1, '''') AS COLUMNS
				 ,STUFF( ( SELECT '',''+ a.IncludedColumn FROM CTE a WHERE c.IndexId = a.IndexId ORDER BY key_ordinal,IncludedColumn FOR XML PATH('''')),1 ,1, '''') AS INCLUDED_COLUMNS
	FROM   CTE c 
	GROUP  BY c.IndexId,c.TableName,c.IndexName,c.type_desc,c.is_primary_key,c.is_unique 
	ORDER  BY c.TableName ASC,c.is_primary_key DESC; ');


	INSERT INTO #IDXLIST_TARGET (DATABASENAME, TABLE_NAME, IDX_NAME, IDX_TYPE, IS_PRIMARY_KEY, IS_UNIQUE, IDX_COLUMNS, IDX_INCLUDED_COLUMNS)
	EXEC ('WITH CTE AS ( 
						 SELECT      ic.index_id + ic.object_id AS IndexId,t.name AS TableName 
												 ,i.name AS IndexName
												 ,case when ic.is_included_column =0 then
														c.name end AS ColumnName
												,case when ic.is_included_column =1 then
														c.name end AS IncludedColumn
														,i.type_desc 
												 ,i.is_primary_key,i.is_unique,ic.key_ordinal 
						 FROM  ' + @TargetDB + '.sys.indexes i 
						 INNER JOIN ' + @TargetDB + '.sys.index_columns ic 
										 ON  i.index_id    =   ic.index_id 
										 AND i.object_id   =   ic.object_id 
						 INNER JOIN ' + @TargetDB + '.sys.columns c 
										 ON  ic.column_id  =   c.column_id 
										 AND i.object_id   =   c.object_id 
							INNER JOIN (SELECT object_id,name FROM ' + @TargetDB + '.sys.tables  union SELECT object_id,name FROM ' + @TargetDB + '.sys.views)t 
										 ON  i.object_id = t.object_id 
	) 
	SELECT ''' + @TargetDB + ''',c.TableName,c.IndexName,c.type_desc,c.is_primary_key,c.is_unique 
				 ,STUFF( ( SELECT '',''+ a.ColumnName FROM CTE a WHERE c.IndexId = a.IndexId ORDER BY key_ordinal FOR XML PATH('''')),1 ,1, '''') AS Columns 
				 ,STUFF( ( SELECT '',''+ a.IncludedColumn FROM CTE a WHERE c.IndexId = a.IndexId ORDER BY key_ordinal,IncludedColumn FOR XML PATH('''')),1 ,1, '''') AS IncludedColumns 
	FROM   CTE c 
	GROUP  BY c.IndexId,c.TableName,c.IndexName,c.type_desc,c.is_primary_key,c.is_unique 
	ORDER  BY c.TableName ASC,c.is_primary_key DESC; ');


	PRINT 'Getting foreign key list!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	INSERT INTO #FKLIST_SOURCE (DATABASENAME, FK_NAME, FK_TABLE, FK_COLUMNS, PK_TABLE, PK_COLUMNS)
	EXEC ('With CTE
					AS
				(select OBJECT_NAME(FK.parent_object_id,db_id(''' + @SourceDB + ''')) PK_TABLE,	 
							C1.name PK_COLUMN,
				object_name(FK.referenced_object_id,db_id(''' + @SourceDB + '''))FK_TABLE,
				C2.name FK_COLUMN,
				FK.name	 FK_NAME
	from
			' + @SourceDB + '.sys.foreign_keys FK
				inner join 
			' + @SourceDB + '.sys.foreign_key_columns FKC
				on FK.object_id=FKC.constraint_object_id
				inner join 
			' + @SourceDB + '.sys.columns C1 
				on FKC.parent_column_id=C1.column_id
				and FKC.parent_object_id=C1.object_id
				inner join 
			' + @SourceDB + '.sys.columns C2
				on FKC.referenced_column_id=C2.column_id
				and FKC.referenced_object_id=C2.object_id							
		)
	SELECT ''' + @SourceDB + ''',C.FK_NAME,
				 C.FK_TABLE,			 STUFF( ( SELECT '',''+ A.FK_COLUMN FROM CTE a WHERE c.FK_NAME = a.FK_NAME and C.FK_TABLE=a.FK_TABLE FOR XML PATH('''')),1 ,1, '''') AS FK_COLUMNS,
				 C.PK_TABLE,			 			 
				 STUFF( ( SELECT '',''+ A.PK_Column FROM CTE a WHERE c.FK_NAME = a.FK_NAME and C.PK_TABLE=a.PK_TABLE FOR XML PATH('''')),1 ,1, '''') AS PK_COLUMNS 
	FROM CTE C
	group by C.FK_NAME,
				 C.FK_TABLE,			 
				 C.PK_TABLE')

	INSERT INTO #FKLIST_TARGET (DATABASENAME, FK_NAME, FK_TABLE, FK_COLUMNS, PK_TABLE, PK_COLUMNS)
	EXEC ('
			With CTE
	AS
	(select OBJECT_NAME(FK.parent_object_id,db_id(''' + @TargetDB + ''')) PK_TABLE,	 
				C1.name PK_COLUMN,
				object_name(FK.referenced_object_id,db_id(''' + @TargetDB + '''))FK_TABLE,
				C2.name FK_COLUMN,
				FK.name	 FK_NAME
	from
			' + @TargetDB + '.sys.foreign_keys FK
				inner join 
			' + @TargetDB + '.sys.foreign_key_columns FKC
				on FK.object_id=FKC.constraint_object_id
				inner join 
			' + @TargetDB + '.sys.columns C1 
				on FKC.parent_column_id=C1.column_id
				and FKC.parent_object_id=C1.object_id
				inner join 
			' + @TargetDB + '.sys.columns C2
				on FKC.referenced_column_id=C2.column_id
				and FKC.referenced_object_id=C2.object_id							
		)
	SELECT ''' + @TargetDB + ''',C.FK_NAME,
				 C.FK_TABLE,			 STUFF( ( SELECT '',''+ A.FK_COLUMN FROM CTE a WHERE c.FK_NAME = a.FK_NAME and C.FK_TABLE=a.FK_TABLE FOR XML PATH('''')),1 ,1, '''') AS FK_COLUMNS,
				 C.PK_TABLE,			 			 
				 STUFF( ( SELECT '',''+ A.PK_Column FROM CTE a WHERE c.FK_NAME = a.FK_NAME and C.PK_TABLE=a.PK_TABLE FOR XML PATH('''')),1 ,1, '''') AS PK_COLUMNS 
	FROM CTE C
	group by C.FK_NAME,
				 C.FK_TABLE,			 
				 C.PK_TABLE')
	END;

	PRINT 'Print column mismatches!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	INSERT INTO #TAB_RESULTS (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE
			EXCEPT
			SELECT
				TS.TABLENAME,
				TS.COLUMNNAME,
				TS.DATATYPE,
				TS.NULLABLE
			FROM #TABLIST_SOURCE TS
			INNER JOIN #TABLIST_TARGET TT
				ON TS.TABLENAME = TT.TABLENAME
				AND TS.COLUMNNAME = TT.COLUMNNAME) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Missing Column' AS Reason) Tab2
		UNION ALL
		SELECT
			@TargetDb AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET
			EXCEPT
			SELECT
				TT.TABLENAME,
				TT.COLUMNNAME,
				TT.DATATYPE,
				TT.NULLABLE
			FROM #TABLIST_TARGET TT
			INNER JOIN #TABLIST_SOURCE TS
				ON TS.TABLENAME = TT.TABLENAME
				AND TS.COLUMNNAME = TT.COLUMNNAME) TAB_MATCH
		CROSS JOIN (SELECT
				'Missing column ' AS Reason) Tab2

	--NON MATCHING COLUMNS
	INSERT INTO #TAB_RESULTS (DATABASENAME, TABLENAME, COLUMNNAME, DATATYPE, NULLABLE, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TS.TABLENAME,
					TS.COLUMNNAME,
					TS.DATATYPE,
					TS.NULLABLE
				FROM #TABLIST_SOURCE TS
				INNER JOIN #TABLIST_TARGET TT
					ON TS.TABLENAME = TT.TABLENAME
					AND TS.COLUMNNAME = TT.COLUMNNAME) T
			EXCEPT
			(SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE
			INTERSECT
			SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET)) TT1
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) t

		UNION ALL

		SELECT
			@TargetDb AS DATABASENAME,
			TABLENAME,
			COLUMNNAME,
			DATATYPE,
			NULLABLE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TT.TABLENAME,
					TT.COLUMNNAME,
					TT.DATATYPE,
					TT.NULLABLE
				FROM #TABLIST_TARGET TT
				INNER JOIN #TABLIST_SOURCE TS
					ON TS.TABLENAME = TT.TABLENAME
					AND TS.COLUMNNAME = TT.COLUMNNAME) T
			EXCEPT
			(SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_TARGET
			INTERSECT
			SELECT
				TABLENAME,
				COLUMNNAME,
				DATATYPE,
				NULLABLE
			FROM #TABLIST_SOURCE)) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) T;

	PRINT 'Print index mismatches!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);


	INSERT INTO #IDX_RESULTS (DATABASENAME, TABLE_NAME, IDX_NAME, IDX_COLUMNS, IDX_INCLUDED_COLUMNS, IS_PRIMARY_KEY, IS_UNIQUE, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			TABLE_NAME,
			IDX_NAME,
			IDX_COLUMNS,
			IDX_INCLUDED_COLUMNS,
			IS_PRIMARY_KEY,
			IS_UNIQUE,
			REASON
		FROM (SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_SOURCE
			EXCEPT
			SELECT
				TS.TABLE_NAME,
				TS.IDX_NAME,
				TS.IDX_COLUMNS,
				TS.IDX_INCLUDED_COLUMNS,
				TS.IS_PRIMARY_KEY,
				TS.IS_UNIQUE
			FROM #IDXLIST_SOURCE TS
			INNER JOIN #IDXLIST_TARGET TT
				ON TS.TABLE_NAME = TT.TABLE_NAME
				AND TS.IDX_NAME = TT.IDX_NAME) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Missing Index n' AS Reason) Tab2
		UNION ALL
		SELECT
			@TargetDb AS DATABASENAME,
			TABLE_NAME,
			IDX_NAME,
			IDX_COLUMNS,
			IDX_INCLUDED_COLUMNS,
			IS_PRIMARY_KEY,
			IS_UNIQUE,
			REASON
		FROM (SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_TARGET
			EXCEPT
			SELECT
				TT.TABLE_NAME,
				TT.IDX_NAME,
				TT.IDX_COLUMNS,
				TT.IDX_INCLUDED_COLUMNS,
				TT.IS_PRIMARY_KEY,
				TT.IS_UNIQUE
			FROM #IDXLIST_TARGET TT
			INNER JOIN #IDXLIST_SOURCE TS
				ON TS.TABLE_NAME = TT.TABLE_NAME
				AND TS.IDX_NAME = TT.IDX_NAME) TAB_MATCH
		CROSS JOIN (SELECT
				'Missing index ' AS Reason) Tab2

	--NON MATCHING INDEX
	INSERT INTO #IDX_RESULTS (DATABASENAME, TABLE_NAME, IDX_NAME, IDX_COLUMNS, IDX_INCLUDED_COLUMNS, IS_PRIMARY_KEY, IS_UNIQUE, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			TABLE_NAME,
			IDX_NAME,
			IDX_COLUMNS,
			IDX_INCLUDED_COLUMNS,
			IS_PRIMARY_KEY,
			IS_UNIQUE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TS.TABLE_NAME,
					TS.IDX_NAME,
					TS.IDX_COLUMNS,
					TS.IDX_INCLUDED_COLUMNS,
					TS.IS_PRIMARY_KEY,
					TS.IS_UNIQUE
				FROM #IDXLIST_SOURCE TS
				INNER JOIN #IDXLIST_TARGET TT
					ON TS.TABLE_NAME = TT.TABLE_NAME
					AND TS.IDX_NAME = TT.IDX_NAME) T
			EXCEPT
			(SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_SOURCE
			INTERSECT
			SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_TARGET)) TT1
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) t

		UNION ALL

		SELECT
			@TargetDb AS DATABASENAME,
			TABLE_NAME,
			IDX_NAME,
			IDX_COLUMNS,
			IDX_INCLUDED_COLUMNS,
			IS_PRIMARY_KEY,
			IS_UNIQUE,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TT.TABLE_NAME,
					TT.IDX_NAME,
					TT.IDX_COLUMNS,
					TT.IDX_INCLUDED_COLUMNS,
					TT.IS_PRIMARY_KEY,
					TT.IS_UNIQUE
				FROM #IDXLIST_TARGET TT
				INNER JOIN #IDXLIST_SOURCE TS
					ON TS.TABLE_NAME = TT.TABLE_NAME
					AND TS.IDX_NAME = TT.IDX_NAME) T
			EXCEPT
			(SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_TARGET
			INTERSECT
			SELECT
				TABLE_NAME,
				IDX_NAME,
				IDX_COLUMNS,
				IDX_INCLUDED_COLUMNS,
				IS_PRIMARY_KEY,
				IS_UNIQUE
			FROM #IDXLIST_SOURCE)) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) T;


	PRINT 'Print key mismatches!';
	PRINT REPLICATE('-', LEN(@SourceDB) + LEN(@TargetDb) + 25);

	INSERT INTO #FK_RESULTS (DATABASENAME, FK_NAME, FK_TABLE, FK_COLUMNS, PK_TABLE, PK_COLUMNS, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			FK_NAME,
			FK_TABLE,
			FK_COLUMNS,
			PK_TABLE,
			PK_COLUMNS,
			REASON
		FROM (SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_SOURCE
			EXCEPT
			SELECT
				TS.FK_NAME,
				TS.FK_TABLE,
				TS.FK_COLUMNS,
				TS.PK_TABLE,
				TS.PK_COLUMNS
			FROM #FKLIST_SOURCE TS
			INNER JOIN #FKLIST_TARGET TT
				ON TS.FK_NAME = TT.FK_NAME) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Missing Index n' AS Reason) Tab2

		UNION ALL

		SELECT
			@TargetDb AS DATABASENAME,
			FK_NAME,
			FK_TABLE,
			FK_COLUMNS,
			PK_TABLE,
			PK_COLUMNS,
			REASON
		FROM (SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_TARGET
			EXCEPT
			SELECT
				TT.FK_NAME,
				TT.FK_TABLE,
				TT.FK_COLUMNS,
				TT.PK_TABLE,
				TT.PK_COLUMNS
			FROM #FKLIST_TARGET TT
			INNER JOIN #FKLIST_SOURCE TS
				ON TS.FK_NAME = TT.FK_NAME) TAB_MATCH
		CROSS JOIN (SELECT
				'Missing key' AS Reason) Tab2


	--NON MATCHING Keys
	INSERT INTO #FK_RESULTS (DATABASENAME, FK_NAME, FK_TABLE, FK_COLUMNS, PK_TABLE, PK_COLUMNS, REASON)
		SELECT
			@SourceDB AS DATABASENAME,
			FK_NAME,
			FK_TABLE,
			FK_COLUMNS,
			PK_TABLE,
			PK_COLUMNS,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TS.FK_NAME,
					TS.FK_TABLE,
					TS.FK_COLUMNS,
					TS.PK_TABLE,
					TS.PK_COLUMNS
				FROM #FKLIST_SOURCE TS
				INNER JOIN #FKLIST_TARGET TT
					ON TS.FK_NAME = TT.FK_NAME) T
			EXCEPT
			(SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_SOURCE
			INTERSECT
			SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_TARGET)) TT1
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) t

		UNION ALL

		SELECT
			@TargetDb AS DATABASENAME,
			FK_NAME,
			FK_TABLE,
			FK_COLUMNS,
			PK_TABLE,
			PK_COLUMNS,
			REASON
		FROM (SELECT
				*
			FROM (SELECT
					TT.FK_NAME,
					TT.FK_TABLE,
					TT.FK_COLUMNS,
					TT.PK_TABLE,
					TT.PK_COLUMNS
				FROM #FKLIST_TARGET TT
				INNER JOIN #FKLIST_SOURCE TS
					ON TS.FK_NAME = TT.FK_NAME) T
			EXCEPT
			(SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_TARGET
			INTERSECT
			SELECT
				FK_NAME,
				FK_TABLE,
				FK_COLUMNS,
				PK_TABLE,
				PK_COLUMNS
			FROM #FKLIST_SOURCE)) TAB_NONMATCH
		CROSS JOIN (SELECT
				'Definition not matching' AS REASON) T;

	--Print Final Results	

	SELECT
		*
	FROM #TAB_RESULTS
	SELECT
		*
	FROM #IDX_RESULTS
	SELECT
		*
	FROM #FK_RESULTS
END
GO