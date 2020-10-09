SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [ETL].[sp_load_TableAuditTrail_Control]
AS
BEGIN

	DECLARE
		@db varchar(100)
		,@schema varchar(100)
		,@table varchar(100)
		,@ID int
		,@rows int
		,@return int


	--//	get tables
	DROP TABLE IF EXISTS #AuditTables
	CREATE TABLE #AuditTables([ID] int identity(1,1), [db] varchar(100), [schema] varchar(100), [table] varchar(100) primary key clustered([ID]))
	INSERT #AuditTables([db],[schema],[table])
	SELECT TargetDatabaseName,TargetSchemaName,TargetDataEntityName
	FROM ETL.LoadTableAuditTrailConfig (NOLOCK)
	WHERE Active=1
	SET @rows=@@ROWCOUNT

	--//	exec audit trail
	SET @ID=1
	WHILE @ID<=@rows
	BEGIN
		SELECT
			@db=[db]
			,@schema=[schema]
			,@table=[table]
		FROM #AuditTables (NOLOCK)
		WHERE [ID]=@ID

		--SELECT @db,@schema,@table
		EXEC @return=[ETL].[sp_load_TableAuditTrail] @db, @schema, @table

		IF (@return=1) SET @ID=@rows+1; --error-exit
		ELSE SET @ID=@ID+1;

		SET @db=NULL; SET @schema=NULL; SET @table=NULL;
	END
END


GO
