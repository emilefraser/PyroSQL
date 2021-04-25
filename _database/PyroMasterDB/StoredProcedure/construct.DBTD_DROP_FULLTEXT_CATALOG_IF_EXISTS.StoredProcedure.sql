SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_FULLTEXT_CATALOG_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_FULLTEXT_CATALOG_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_FULLTEXT_CATALOG_IF_EXISTS]
(
	@v_Catalog_Name	SYSNAME,	--Full text catalog name 
	@v_Database_Name SYSNAME,	--A database where this catalog has been created
	@v_Drop_All_Indexes BIT = 0 --default value is 0, when set to 1 this procedure will drop all full text indexes that exist in this catalog
)
  AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_SQL NVARCHAR(MAX) = '',
			@v_Message VARCHAR(2000),
			@v_ParmDefinition NVARCHAR(MAX) = N' @v_InternalCatalogID INT OUTPUT, @v_Catalog_Name NVARCHAR(255)',
			@v_InternalCatalogID INT

	CREATE TABLE #DBTD_TablesWithFullTextIndexes(
		ObjectName NVARCHAR(128)
	)
	
	BEGIN TRY 

		SET @v_SQL = 
			'SELECT @v_InternalCatalogID = C.fulltext_catalog_id 
			FROM ' +@v_Database_Name+ '.SYS.FULLTEXT_CATALOGS AS C
			WHERE UPPER(C.NAME) = LTRIM(RTRIM(UPPER(@v_Catalog_Name)))'
		EXECUTE sp_executeSQL
				@v_Sql,
				@v_ParmDefinition,
				@v_InternalCatalogID = @v_InternalCatalogID OUTPUT,
				@v_Catalog_Name = @v_Catalog_Name

		IF (@v_InternalCatalogID IS NOT NULL)
		BEGIN
			IF @v_Drop_All_Indexes = 1
			BEGIN
				--get list of tables that have full text indexes assigned to the target catalog
				SET @v_SQL = 
					'INSERT INTO #DBTD_TablesWithFullTextIndexes
						(ObjectName)
						SELECT ''' + LTRIM(RTRIM(@v_Database_Name)) + '.['' + s.name + ''].['' + o.name + '']''
						FROM ' + LTRIM(RTRIM(@v_Database_Name)) + '.sys.fulltext_indexes AS i
							INNER JOIN ' + LTRIM(RTRIM(@v_Database_Name)) + '.sys.objects AS o
								ON i.object_id = o.object_id
							INNER JOIN DBTestDriven.sys.schemas AS S
								ON o.schema_id = s.schema_id;'
				EXEC DBTD_SP_EXECUTESQL @v_Database_Name, @v_SQL

				--remove related indexes
				SET @v_SQL = '' 
				SELECT @v_SQL = COALESCE(@v_SQL+ ' ', '') + 'EXEC ' + DB_NAME() + '.DBO.DBTD_DROP_FULLTEXT_INDEX_IF_EXISTS @v_Object_Name = ''' + ObjectName + ''';'
				FROM #DBTD_TablesWithFullTextIndexes
				EXEC DBTD_SP_EXECUTESQL @v_Database_Name, @v_SQL
			END 

			--and finally remove catalog
			SET @v_SQL = 'DROP FULLTEXT CATALOG ' + @v_Catalog_Name;
			EXEC DBO.DBTD_SP_EXECUTESQL	@v_Database_Name, @v_SQL
			SET @v_Message = 'Full Text Catalog [' + @v_Catalog_Name + '] has been dropped from ['+@v_Database_Name+'] database.';
			PRINT @v_Message;
			RETURN 1; 
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot find full text catalog [' + @v_Catalog_Name + '] from ['+@v_Database_Name+'] database.';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'Cannot drop [' + @v_Catalog_Name + '] full text catalog from ['+@v_Database_Name+'] database.' + ERROR_MESSAGE();
		PRINT @v_Message;
		RETURN 0; 
	END CATCH 
END;

GO
