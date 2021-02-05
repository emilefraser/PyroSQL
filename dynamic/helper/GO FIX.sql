--Your Script modified by adding a single line of code:
DECLARE @script NVARCHAR(MAX);--I changed from VarChar to nVarChar - you should always use nVarChar for Dynamic SQL.
SET @script = 
    '
    create table ali(id decimal(10,0));
    drop table ali;
    go
    create table ali(id decimal(10,0));
    drop table ali;
    '
    --In case you have apostrophes in your script, you must escape them for the Exec() command. - 03/14/2013 - MCR.
SET @script = 'EXEC (''' + REPLACE(REPLACE(@script, '''', ''''''), 'GO', '''); EXEC(''') + ''');'--Just add this one line.
PRINT @script --See the command used (will be truncated in Select/Print, but not when Executing).
EXEC (@script);


--Example of compiling and chaining multiple DDL statments from data in a table:
-- DDL (Data Definition Language).
--  These are statements used to create, alter, or drop data structures.
--  They MUST be run in a single Batch.
--  The "GO" keyword is a SSMS syntax for splitting up batches - it is not an SQL keyword.
DECLARE @DDL_Statements TABLE
(
  DDL nVarChar(MAX)
)
INSERT INTO @DDL_Statements (DDL)
    SELECT 'create table ali(id decimal(10,0)); drop table ali;' UNION ALL
    SELECT 'create table ali(id decimal(10,0)); drop table ali;'
DECLARE @SqlCommand nVarChar(MAX) = ''
 SELECT @SqlCommand = @SqlCommand + 'EXEC(''' + REPLACE(DS.DDL, '''', '''''') + '''); '
   FROM @DDL_Statements as DS --In case you have apostrophes in your script, you must escape them for the Exec() command. - 03/14/2013 - MCR.
PRINT @SqlCommand --See the command used (will be truncated in Select/Print, but not when Executing).
EXEC (@SqlCommand)