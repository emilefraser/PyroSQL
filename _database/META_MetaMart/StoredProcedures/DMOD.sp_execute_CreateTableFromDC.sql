SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	DECLARE @DataEntityID INT = 
	(
		SELECT DISTINCT DataEntityID
		FROM DC.vw_rpt_DatabaseFieldDetail		
		WHERE DataEntityName = 'HUB_Branch'
		AND SchemaName = 'raw'
		AND DatabaseName = 'DEV_DataVault'
	)

	DECLARE @TargetDatabaseName VARCHAR(100) = 'DEV_DataVault'

	EXEC  [DMOD].[sp_execute_CreateTableFromDC] @DataEntityID, @TargetDatabaseName

*/

CREATE   PROCEDURE [DMOD].[sp_execute_CreateTableFromDC]
	@DataEntityID INT,
	@TargetDataBaseName VARCHAR(50)
AS 
BEGIN
	DECLARE @DDLScript VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	
	EXECUTE [DMOD].[sp_ddl_CreateTableFromDC]
			@DDLScript OUTPUT,
			@DataEntityID,
			@TargetDataBaseName



	SET @DDLScript = 'USE ' + @TargetDataBaseName + CHAR(13) + CHAR(13) + @DDLScript + CHAR(13) + CHAR(13) + 'USE ' + DB_NAME()  + CHAR(13) 
	
	
	PRINT(@DDLScript)
	EXEC(@DDLScript)



END



GO
