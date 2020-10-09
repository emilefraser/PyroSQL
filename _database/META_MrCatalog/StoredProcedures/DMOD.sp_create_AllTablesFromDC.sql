SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	DECLARE @TargetDatabaseName VARCHAR(150) = 'DEV_DataVault'
	EXEC DMOD.sp_create_AllTablesFromDC @TargetDatabaseName
*/
CREATE   PROCEDURE [DMOD].[sp_create_AllTablesFromDC]
	@TargetDatabaseName VARCHAR(150) 
AS

DECLARE 
	@DDLScript VARCHAR(MAX), 
	@DataEntityID INT

DECLARE ddl_cursor CURSOR FOR 
	SELECT DataEntityID
	FROM DC.DataEntity AS de
	INNER JOIN DC.[Schema] AS s
	ON s.SchemaID = de.SchemaID
	INNER JOIN DC.[Database] aS db
	ON db.DatabaseID = s.DatabaseID
	WHERE db.DatabaseName = @TargetDatabaseName

	OPEN ddl_cursor
	FETCH NEXT FROM ddl_cursor INTO @DataEntityID

	WHILE @@FETCH_STATUS = 0 
	BEGIN

	EXEC DMOD.sp_ddl_CreateTableFromDC
		@DDLScript OUTPUT,
		@DataEntityID,
		@TargetDataBaseName

	SET @DDLScript = 'USE ' + @TargetDataBaseName + CHAR(13) + CHAR(13) + @DDLScript + CHAR(13) + CHAR(13) + 'USE ' + DB_NAME()  + CHAR(13) 

	PRINT @DDLScript
	EXEC(@DDLScript)

	FETCH NEXT FROM ddl_cursor INTO @DataEntityID

	END

CLOSE ddl_cursor 
DEALLOCATE ddl_cursor

GO
