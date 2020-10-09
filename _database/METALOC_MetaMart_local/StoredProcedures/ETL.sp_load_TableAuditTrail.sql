SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [ETL].[sp_load_TableAuditTrail]
(
	@db varchar(100)
	,@schema varchar(100)
	,@table varchar(100)
)
AS
BEGIN
	DECLARE
		@dbschema varchar(300)
		,@htable varchar(100)
		,@fields varchar(max)
		,@vfields varchar(max)
		,@hashfield varchar(max)
		,@sql nvarchar(max)
		,@Error varchar(500)


	SET @htable=@table+'_Hist'
	SET @dbschema=@db+'.'+@schema

	--//	get field list
	SELECT 
		@fields=[FieldList]
	FROM 
		[DataManager_Local].[ETL].[LoadConfig] (NOLOCK)
	WHERE
		[TargetDatabaseName]=@db
		AND [TargetSchemaName]=@schema
		AND [TargetDataEntityName]=@table

	--//	set hash definition
	SET @hashfield='CONVERT(CHAR(64),HASHBYTES(''SHA2_256'','+REPLACE(REPLACE(REPLACE(@fields,',','+''|''+'),'[','CONVERT(varchar(max),ISNULL(['),']','],''''),121)')+'),2)'

	--//	create hist components
	BEGIN TRY
		--	create HASH - ADD HASH_ROW char(64) NULL;
		SET @sql=N'IF NOT EXISTS(SELECT 1 FROM '+@db+'.INFORMATION_SCHEMA.COLUMNS (NOLOCK) WHERE TABLE_CATALOG='''+@db+''' AND TABLE_SCHEMA='''+@schema+''' AND TABLE_NAME='''+@table+''' AND COLUMN_NAME=''HASH_ROW'') '
		+N'BEGIN ALTER TABLE '+@dbschema+'.'+@table+' ADD HASH_ROW AS '+@hashfield+';END';  
		EXEC sp_executesql @sql;

		--//	update hash/index
		SET @sql=N'/*UPDATE '+@dbschema+'.'+@table+' SET [HASH_ROW]='+@hashfield+' WHERE [HASH_ROW] IS NULL*/'
			+N';IF NOT EXISTS(SELECT 1 FROM '+@db+'.sys.indexes WITH (NOLOCK) WHERE object_id=OBJECT_ID('''+@dbschema+'.'+@table+''') AND [name]=''IX_'+@table+'_CC'')'
			+N'BEGIN CREATE CLUSTERED COLUMNSTORE INDEX [IX_'+@table+'_CC] ON '+@dbschema+'.'+@table+' WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0); END ';
		EXEC sp_executesql @sql

		--	Hist table
		SET @sql=N'IF OBJECT_ID('''+@dbschema+'.'+@htable+''') IS NULL BEGIN SELECT *,CreatedDT=GETDATE(), ModifiedDT=CAST(''1900-01-01'' AS datetime),IsDeleted=CAST(''0'' AS BIT) INTO '+@dbschema+'.'+@htable+' FROM '+ @dbschema+'.'+@table+' (NOLOCK) WHERE 1=2'
			+';CREATE NONCLUSTERED INDEX [IX_'+@htable+'_HASH] ON '+@dbschema+'.'+@htable+' ([HASH_ROW]) INCLUDE([ModifiedDT],[IsDeleted],[CreatedDT])'
			+';CREATE CLUSTERED COLUMNSTORE INDEX [IX_'+@htable+'_CC] ON '+@dbschema+'.'+@htable+' WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0); END';
		EXEC sp_executesql @sql

		--	Update IsDeleted/ModifiedDT
		SET @sql=N'USE ['+@db+'];'+CHAR(10)+
			N'UPDATE s'+CHAR(10)+
			N'SET IsDeleted=1, ModifiedDT=GETDATE()'+CHAR(10)+
			N'FROM '+@dbschema+'.'+@htable+' s (NOLOCK) LEFT OUTER JOIN '+@dbschema+'.'+@table+' h (NOLOCK) ON h.HASH_ROW=s.HASH_ROW WHERE h.HASH_ROW IS NULL AND s.IsDeleted=0;';
		EXEC sp_executesql @sql

		--	Hist records
		SET @vfields=@fields+',[HASH_ROW],CreatedDT=GETDATE(),ModifiedDT=NULL,IsDeleted=0'
		SET @fields=@fields+',[HASH_ROW],[CreatedDT],[ModifiedDT],[IsDeleted]'
		SET @sql=N'USE ['+@db+']; IF EXISTS (SELECT TOP 1 1 FROM '+@db+'.INFORMATION_SCHEMA.COLUMNS (NOLOCK) WHERE TABLE_CATALOG='''+@db+''' AND TABLE_SCHEMA='''+@schema+''' AND TABLE_NAME='''+@htable+''' AND COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA+''.''+TABLE_NAME), COLUMN_NAME, ''isidentity'')=1) SET IDENTITY_INSERT '+@dbschema+'.'+@htable+' ON;'+CHAR(10)+
			N'INSERT '+@dbschema+'.'+@htable+'('+@fields+')'+CHAR(10)+
			N'SELECT '+REPLACE(@vfields,'[','s.[')+CHAR(10)+
			N'FROM '+@dbschema+'.'+@table+' s (NOLOCK) LEFT OUTER JOIN '+@dbschema+'.'+@htable+' h (NOLOCK) ON h.HASH_ROW=s.HASH_ROW WHERE h.HASH_ROW IS NULL;'
		EXEC sp_executesql @sql


		RETURN 0
	END TRY
	BEGIN CATCH
		SET @Error=CONVERT(varchar(500), ERROR_MESSAGE())
		RAISERROR(@Error,10,1)
		RETURN 1
	END CATCH
END

GO
