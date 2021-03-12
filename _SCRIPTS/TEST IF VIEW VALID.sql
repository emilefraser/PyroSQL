--sp_describe_undeclared_parameters
--    @tsql = N'SELECT object_id, name, type_desc FROM sys.indexes;'
----Will correctly throw an error ("SET NOEXEC" and "SET PARSEONLY" do not throw an error in this case):

--sp_describe_undeclared_parameters 
--  @tsql = N'SELECT object_id, name, type_desc FROM sys.indexes;SELECT object_id, name, type_desc FROM sys.NOTaTABLE;'

--  select top 1 

--    select * from sys.objects where is_ms_shipped = 0
--EXEC sys.dm_exec_describe_first_result_set_for_object   
DECLARE @RC INT
DECLARE @sql_statement NVARCHAR(MAX)
DECLARE @name_schema NVARCHAR(MAX)
DECLARE @name_view NVARCHAR(MAX)
DECLARE @fake int
DECLARE @sql_parameter NVARCHAR(MAX)

DROP TABLE IF EXISTS 
	##InfoMart_Register
SELECT --TOP 15
	o.object_id
,	o.type
,	o.type_desc
,	v.name AS name_view
,	o.schema_id
,	s.name AS name_schema
,	v.create_date
,	v.modify_date
,	convert(bit, 0) AS IsActive
,	convert(bit, 0) AS IsUsed
,	convert(float, 0) AS trustworthy_index 
--INTO 
--	##InfoMart_Register
from 
	sys.objects AS o
inner join 
	sys.views AS v
ON 
	v.object_id = o.object_id
INNER JOIN 
	sys.schemas AS s
ON 
	s.schema_id = o.schema_id
where 
	o.is_ms_shipped = 0
AND 
	s.name = 'dbo'
And
	o.type = 'v'
AND
	SUBSTRING(o.name , 1,8) != 'vw_pres_'

--SELECT * FROM ##InfoMart_Register
declare @curs_register CURSOR 

SET @curs_register =  CURSOR FOR
select name_schema, name_view FROM ##InfoMart_Register

OPEN @curs_register
FETCH NEXT FROM @curs_register
INTO @name_schema, @name_view

DECLARE @TEST NVARCHAR(MAX) = 'FMTONLY'

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @sql_statement = 'SET ' + @TEST + ' ON' + CHAR(13)
	SET @sql_statement += 'SELECT @fake = COUNT(1) FROM ' + QUOTENAME(@name_schema) + '.' + QUOTENAME(@name_view) + CHAR(13)
	SET @sql_statement += 'SET ' + @TEST + ' OFF' + CHAR(13)  + CHAR(13)

	SET @sql_parameter = '@fake INT'

--SET NOEXEC ON
	EXEC @RC = sp_executesql  @stmt = @sql_statement, @sql_param = @sql_parameter,  @fake = @fake
	--SET NOEXEC OFF

	IF(@RC != 0)
		SELECT QUOTENAME(@name_schema) + '.' + QUOTENAME(@name_view), @RC

	FETCH NEXT FROM @curs_register
	INTO @name_schema, @name_view


END
SELECT
    definition,
    uses_ansi_nulls,
    uses_quoted_identifier,
    is_schema_bound
FROM
    sys.sql_modules


--SET NOEXEC ON
--SET PARSEONLY OFF
--SET FMTONLY 
--SET NOCOUNT

