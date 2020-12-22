--CREATE PROCEDURE [dbo].[get_crossdatabase_dependencies] AS

SET NOCOUNT ON
GO

DECLARE 
	@BaseObject_Name SYSNAME = 'sales_header_invoice'
,	@BaseObject_Schema SYSNAME = 'dbo'
,	@BaseObject_Database SYSNAME = 'ODS_EMS'
,	@BaseObject_Entity SYSNAME = 'SalesInvoice'
,	@Exclude_Schemas SYSNAME = 'BALANCE'

DECLARE 
    @DatabaseID INT, 
    @DatabaseName SYSNAME,
	@rn_curr INT,
	@DatabaseList NVARCHAR(Max)

DECLARE @Databases AS TABLE (
	rn INT,
    DatabaseID INT, 
    DatabaseName SYSNAME
)

DECLARE @sql_statement NVARCHAR(MAX)
DECLARE @sql_params NVARCHAR(MAX)
DECLARE @sql_message NVARCHAR(MAX)
DECLARE @sql_clrf NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @sql_isdebug BIT = 1

INSERT INTO @Databases(rn, DatabaseID, DatabaseName)
SELECT 
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
,	db.Database_ID AS DatabaseID
,	db.name AS DatabaseName
FROM sys.databases AS db
WHERE 
	db.name IN ('ODS_EMS', 'STAGEAREA', 'DATAVAULT')
AND
	db.state <> 6 /* ignore offline DBs */
AND 
	database_id > 4; /* ignore system DBs */


DROP TABLE IF EXISTS #dependencies
CREATE TABLE #dependencies(
    referencing_database varchar(max),
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
    referenced_database varchar(max),
    referenced_schema varchar(max),
    referenced_object_name varchar(max)
)

SET @rn_curr = (SELECT MAX(rn) FROM @Databases)
SET @DatabaseList = (SELECT STRING_AGG('''' + DatabaseName + '''',',') FROM @Databases)


WHILE (@rn_curr) > 0 
BEGIN
	
	-- Curr DB
    SELECT 
		@DatabaseID = DatabaseID
	,   @DatabaseName = DatabaseName 
    FROM 
		@Databases
	WHERE
		rn = @rn_curr

	SET @sql_message = '##### DEBUG PARAMS #####' + @sql_clrf
	SET @sql_message += '@DatabaseID=' + CONVERT(NVARCHAR(MAX), @DatabaseID) + ',' + '@DatabaseID=' + @DatabaseName + @sql_clrf
	IF(@sql_isdebug = 1) 
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT

    SET @sql_statement = '
		INSERT INTO 
			#dependencies 
        SELECT 
			DB_NAME(' + convert(NVARCHAR(MAX),@DatabaseID) + '), 
			OBJECT_SCHEMA_NAME(referencing_id,'  + convert(NVARCHAR(MAX),@DatabaseID) +'), 
			OBJECT_NAME(referencing_id,' + convert(NVARCHAR(MAX),@DatabaseID) + '), 
			ISNULL(referenced_database_name, db_name(' + convert(NVARCHAR(MAX),@DatabaseID) + ')),
			referenced_schema_name,
			referenced_entity_name
		FROM ' + 
			quotename(@DatabaseName) + '.sys.sql_expression_dependencies
		WHERE
			DB_NAME(' + convert(NVARCHAR(MAX),@DatabaseID) + ') IN (' + @DatabaseList + ')
		OR 
			ISNULL(referenced_database_name, db_name(' + convert(NVARCHAR(MAX),@DatabaseID) + ')) IN (' + @DatabaseList + ')
		'

	SET @sql_params = '@DatabaseList NVARCHAR(MAX)'
	SET @sql_message = '####### DEBUG : STATEMENT #######' + @sql_clrf
	SET @sql_message += @sql_statement + @sql_clrf
    
	IF(@sql_isdebug = 1)
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	
	EXEC sp_executesql 
		@stmt = @sql_statement
	,	@params = @sql_params
	,	@DatabaseList = @DatabaseList


    SET @rn_curr -= 1
END

SET NOCOUNT OFF;

SELECT * FROM #dependencies
WHERE referenced_object_name = @BaseObject_Name
AND referenced_schema = @BaseObject_Schema
AND referenced_database = @BaseObject_Database
AND referencing_object_name LIKE '%' + @BaseObject_Entity + '%'
AND referencing_schema != @Exclude_Schemas

