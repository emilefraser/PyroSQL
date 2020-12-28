USE DMgrDev_DataEnvDEV_StageArea

---- GET THE TABLES THAT NEED TO RUN THROUGH TO DV
--SELECT * 
--FROM ODS_XT900.sys.tables AS t
--INNER JOIN ODS_XT900.sys.schemas AS s
--ON s.schema_id = t.schema_id
--WHERE t.name = 'SITE'

--sp_depends 'dbo.SITE'

DROP TABLE IF EXISTS ##databases
CREATE TABLE ##databases(
    database_id int, 
    database_name sysname
);

-- ignore systems databases
INSERT INTO ##databases(database_id, database_name)
SELECT database_id, name FROM sys.databases
WHERE database_id > 4;	

DECLARE 
    @database_id int, 
    @database_name sysname, 
    @sql varchar(max);

DROP TABLE IF EXISTS ##dependencies

CREATE TABLE ##dependencies(
    referencing_database varchar(max),
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
    referenced_server varchar(max),
    referenced_database varchar(max),
    referenced_schema varchar(max),
    referenced_object_name varchar(max)
);

WHILE (SELECT COUNT(*) FROM ##databases) > 0 BEGIN
    SELECT TOP 1 @database_id = database_id, 
                 @database_name = database_name 
    FROM ##databases;

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

    DELETE FROM ##databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF;

SELECT * FROM ##dependencies;
