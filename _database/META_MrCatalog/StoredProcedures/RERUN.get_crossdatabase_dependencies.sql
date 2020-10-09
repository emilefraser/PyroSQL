SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE RERUN.[get_crossdatabase_dependencies] AS

SET NOCOUNT ON;

CREATE TABLE #databases(
    database_id int, 
    database_name sysname
);

INSERT INTO #databases(database_id, database_name)
SELECT database_id, [name]
FROM sys.databases
WHERE 1 = 1
    AND [state] <> 6 /* ignore offline DBs */
    AND database_id > 4  /* ignore system DBs */
	AND name IN ('ODS_EMS','STAGEAREA','DATAVAULT');

DECLARE 
    @database_id int, 
    @database_name sysname, 
    @sql varchar(max);

CREATE TABLE #dependencies(
    referencing_database varchar(max),
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
    referenced_server varchar(max),
    referenced_database varchar(max),
    referenced_schema varchar(max),
    referenced_object_name varchar(max)
);

WHILE (SELECT COUNT(*) FROM #databases) > 0 BEGIN
    SELECT TOP 1 @database_id = database_id, 
                 @database_name = database_name 
    FROM #databases;

    SET @sql = 'INSERT INTO #dependencies select 
        DB_NAME(' + convert(varchar,@database_id) + '), 
        OBJECT_SCHEMA_NAME(referencing_id,' 
            + convert(varchar,@database_id) +'), 
        OBJECT_NAME(referencing_id,' + convert(varchar,@database_id) + '), 
        referenced_server_name,
        ISNULL(referenced_database_name, db_name(' 
             + convert(varchar,@database_id) + ')),
        referenced_schema_name,
        referenced_entity_name
    FROM ' + quotename(@database_name) + '.sys.sql_expression_dependencies';

    EXEC(@sql);

    DELETE FROM #databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF;

SELECT * FROM #dependencies where referenced_object_name = 'sp_StageFullLoad_KEYS_EMS_dbo_StockTransaction_EMS_KEYS'


;WITH cte_dependency
AS (

	SELECT 
		0 AS n,
		referencing_database, referencing_schema, referencing_object_name,
		referenced_database, referenced_schema, referenced_object_name
	FROM #dependencies
	WHERE referenced_object_name = 'lsales_header_invoice'

	UNION ALL 
	
	SELECT 
		n + 1 AS n,
		d.referencing_database, d.referencing_schema, d.referencing_object_name,
		d.referenced_database, d.referenced_schema, d.referenced_object_name
	FROM #dependencies d
	INNER JOIN cte_dependency aS cd
	ON cd.referencing_object_name = d.referenced_object_name
)
SELECT 
	*
FROM 
	cte_dependency



-- EXEC RERUN.[get_crossdatabase_dependencies]
GO
