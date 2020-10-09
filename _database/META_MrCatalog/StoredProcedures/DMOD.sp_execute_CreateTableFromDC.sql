SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	DECLARE @DataEntityID INT = 
	(
		SELECT DISTINCT DataEntityID
		FROM DC.vw_rpt_DatabaseFieldDetail		
		WHERE
		DataEntityName = 'SAT_Stock_D365_LVD' AND SchemaName = 'raw'
		AND DatabaseName = 'DataVault'
	)

	DECLARE @TargetDatabaseName VARCHAR(100) = 'StageArea'
    DECLARE @IsDropAndRecreateTable BIT = 1

	EXEC  [DMOD].[sp_execute_CreateTableFromDC] @DataEntityID, @TargetDatabaseName, @IsDropAndRecreateTable

*/

CREATE   PROCEDURE [DMOD].[sp_execute_CreateTableFromDC]
	@DataEntityID INT,
	@TargetDataBaseName VARCHAR(50),
    @IsDropAndRecreateTable BIT = 0
AS 
BEGIN
	DECLARE @DDLScript VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
    DECLARE @sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
    DECLARE @sql_eos NVARCHAR(4) = REPLICATE(CHAR(13), 2)
	
	EXECUTE [DMOD].[sp_ddl_CreateTableFromDC]
			@DDLScript = @DDLScript OUTPUT,
			@DataEntityID = @DataEntityID,
			@TargetDataBaseName = @TargetDataBaseName,
            @IsDropAndRecreateTable = @IsDropAndRecreateTable



	SET @DDLScript = 'USE ' + @TargetDataBaseName + @sql_eos + @DDLScript + @sql_eos + 'USE ' + DB_NAME() + @sql_eos
	
	
	PRINT(@DDLScript)
	EXEC(@DDLScript)



END



GO
