/*
Dynamic SQL BEST PRACTICE
*/



1) Always use []s around object names (WITH QUOTENAME)


EXEC sp_msforeachdb 'USE [?];'

2) Always put EXEC in front of stored procedure calls

SELECT 'EXEC sp_spaceused ['+TABLE_SCHEMA+'.'+TABLE_NAME+'];'
FROM INFORMATION_SCHEMA.TABLES


3) Always include the Schema where appropriate

SELECT 'SELECT COUNT(1) FROM ['+TABLE_SCHEMA+'].['+TABLE_NAME+']'
FROM INFORMATION_SCHEMA.TABLES

4) End statements with semicolons;

sp_msforeachdb 'USE [?]; PRINT ''?'';'

5) Double, Triple and Quadruple check your quotes
SET @stringvar = 'It''s'


6) Format your code so that the output is formatted the way you want to read it


Dynamic SQL vest practice from DSQL v2

1) Alwyas use NVARCHAT FOR @startement, @params....


When working with very large dynamic sQL, consider using nV䅒C䡁(䵁X) for all scalar parameters involved in the construction of the command string to avoid inadvertent string truncation.

For consistency and reliability, use nV䅒C䡁(䵁X) as the data type for your dynamic sQL command strings.

2)  With SQL objects always use SYSNAME type

3) With cursors use the specification.....

4) Output to screen with:
RAISERROR(@message, 0, 1) WITH NOWAIT


When writing new dynamic sQL, be sure to print the command string often, verifying that the resulting tQL is valid, both syntactically, and logically.

5) End statements with ;

6) Use db?

7) when possible include db, schema, objevtt(table, view, proc in params)

8) exec vs sp_execsql
always use sp_execure as atandars (allowsnin and out params)



9) BEGIN TRAMSACTION ... COMMIT ...ROLLBACK

10) TRY CATCH

11) STANDARISED ERROR REPORTING.

12) LOGs of run

13) unclude qyery in output

14) USE OF QUOTED_IDENTIFIER


15) BREAKS ON ERRORS?



16) @DEBUG AND @TEST PARAMS?

ꂠꂠꂠIF @debug = 1 ꂠꂠꂠꂠꂠꂠPRINT @sql_command ꂠꂠꂠELSE ꂠꂠꂠꂠꂠꂠEXEC (@sql_command);

17) consider deterministic vs nin determinstic eddevt of fucntiosn ect

18) when variable names ect need to be abstracted to keep procs generic, comments must be vert descriptive


19) test cases at top

20) pricidet standard form of execution as example.

21) comments comments comments



22) callers should always call dynamic sql prics with best pracrice use of specified alinstead of positional parameters



23)  style code


30) write dsql same as sql





31) set ssms options for result tontext to max allowablento not trucate prints



33) use cincat concat_ws trim ltrim rtrim and + where rneeded
concat tirbs null into ''
concat_ws tirbs does teim too

34) string functiins bmnnb

charindex
substring
stuff
replace
len
replicate
translate
reverse
quotename() 
and quotestring(),
STRING_SPLIT
char UNICODE ASCII
CHARINDEX
PATINDEX
LOWER, UPPER
LEFT, RIGHT
TRIM, LTRIM, RTRIM
CONCAT CONCATWS
STUFF
STR
SPACE

SOUNDE???
The Soundex is a coded surname (last name) index based on the way a surname sounds, rather than the way it is spelled. Surnames that sound the same, but are spelled differently, like SMITH and SMYTH, have the same code and are filed together.







35) FOR CROSS DB QUEREIES EITHER

A) CREATE SYNONYM otherdbtbl FOR otherdb.dbo.tbl
B) 
SELECT @dbname = quotename(dbname) FROM ...
SELECT @sp = @dbname + '..some_sp'
EXEC @ret = @sp @par1, @par2...

c)
SELECT @dbname = quotename(dbname) FROM ...
SELECT @sql = ' SELECT ... FROM ' + @dbname + ' .dbo.otherdbtbl ' +
              ' JOIN dbo.localtbl ... '
EXEC sp_executesql @sql, @params, ...
But, if the query is complex, and most of the tables are in the remote database you can also do:

SELECT @sql = ' SELECT ... FROM dbo.othertbl ' +
              ' JOIN ' + quotename(db_name()) + '.dbo.localtbl ... '
SELECT @dbname = quotename(dbname) FROM ...
SELECT @sp_executesql = @dbname + '..sp_executesql'
EXEC @sp_executesql @sql, @params, ...

36) TO DO SOMETHING IN EACH DB
Do Something in Every Database
This sounds to me like some sysadmin venture, and for sysadmin tasks dynamic SQL is usually a fair game, because neither caching nor permissions are issues. Nevertheless there is an kind of alternative: sp_MSforeachdb, demonstrated by this example:

sp_MSforeachdb 'SELECT ''?'', COUNT(*) FROM sysobjects'

OR USE SYS VIEWS TO GET DB

37) disable sp_pivot due to security concerns

DENY EXECUTE ON pivot_sp TO public


38) to determine column names at runtime

The request here is to determine the name for a column in a result set at run-time. My gut reaction, is that this should be handled client-side. But if your client is a query window is Management Studio or similar, this is kind of difficult. In any case, this is simple to do without any dynamic SQL on SQL 2005 and later:

DECLARE @mycolalias sysname
SELECT @mycolalias = 'This week''s alias'

CREATE TABLE #temp (a int NOT NULL,
                    b int NOT NULL)

INSERT #temp(a, b) SELECT 12, 17

EXEC tempdb..sp_rename '#temp.b', @mycolalias, 'COLUMN'

SELECT * FROM #temp

39) sorting columns 
Note that if the columns have different data types you cannot lump them into the same CASE expression, as the data type of a CASE expression is always one and the same. Instead, you can do this:

SELECT col1, col2, col3
FROM   dbo.tbl
ORDER  BY CASE @col1 WHEN 'col1' THEN col1 ELSE NULL END,
          CASE @col1 WHEN 'col2' THEN col2 ELSE NULL END,
          CASE @col1 WHEN 'col3' THEN col3 ELSE NULL END
If you also want to make it dynamic whether the order should be ascending or descending, add one more CASE:

SELECT col1, col2, col3
FROM   dbo.tbl
ORDER  BY CASE @sortorder
               WHEN 'ASC' THEN CASE @col1
                                    WHEN 'col1' THEN col1
                                    WHEN 'col2' THEN col2
                                    WHEN 'col3' THEN col3
                                END
               ELSE NULL
           END ASC,
           CASE @sortorder
               WHEN 'DESC' THEN CASE @col1
                                     WHEN 'col1' THEN col1
                                     WHEN 'col2' THEN col2
                                     WHEN 'col3' THEN col3
                                 END
               ELSE NULL
           END 
		   
		   
		   
		 
	40) getting top x% of results
	SELECT TOP @n FROM tbl
This is no longer an issue, since SQL 2005 added new syntax that permits a variable:

SELECT TOP(@n) col1, col2 FROM tbl
On SQL 2000, TOP does not accept variables, so you need to use dynamic SQL to use TOP. But there is an alternative:

CREATE PROCEDURE get_first_n @n int AS
SET ROWCOUNT @n
SELECT au_id, au_lname, au_fname
FROM   authors
ORDER  BY au_id
SET ROWCOUNT 0


41) for both temp adn perm linked servers

Linked Servers
This is similar to parameterising the database name, but in this case we want to access a linked server of which the name is determined at run-time.

Two of the solutions for dynamic database names apply here as well:

On SQL 2005 and later, the best solution is probably to use synonyms:
CREATE SYNONYM myremotetbl FOR Server.db.dbo.remotetbl
If you can confine the access to the linked server to a stored procedure call, you can build the SP name dynamically:
SET @sp = @server + '.db.dbo.some_sp'
EXEC @ret = @sp @par1, @par2...
If you want to join a local table with a remote table on some remote server, determined in the flux of the moment, dynamic SQL is probably the best way if you are on SQL 2000. There exists however an alternative, although it's only usable in some situations. You can use sp_addlinkedserver to define the linked server at run-time, as demonstrated by this snippet:

EXEC sp_addlinkedserver MYSRV, @srvproduct='Any',
                               @provider='SQLOLEDB', @datasrc=@@SERVERNAME
go
CREATE PROCEDURE linksrv_demo_inner WITH RECOMPILE AS
   SELECT * FROM MYSRV.master.dbo.sysdatabases
go
EXEC sp_dropserver MYSRV
go
CREATE PROCEDURE linksrv_demo @server sysname AS
   IF EXISTS (SELECT * FROM master..sysservers WHERE srvname = 'MYSRV')
      EXEC sp_dropserver MYSRV
   EXEC sp_addlinkedserver MYSRV, @srvproduct='Any',
                           @provider='SQLOLEDB', @datasrc=@server
   EXEC linksrv_demo_inner
   EXEC sp_dropserver MYSRV
go
EXEC linksrv_demo 'Server1'
EXEC linksrv_demo 'Server2

42) for openquery and openrowset

DECLARE @remotesql nvarchar(4000),
        @localsql  nvarchar(4000),
        @state     char(2)

SELECT @state = 'CA'
SELECT @remotesql = 'SELECT * FROM pubs.dbo.authors WHERE state = ' +
                     dbo.quotestring(@state)
SELECT @localsql  = 'SELECT * FROM OPENQUERY(MYSRV, ' +
                     dbo.quotestring(@remotesql) + ')'

PRINT @localsql
EXEC (@localsql)
The built-in function quotename() is usually not useful here, as the SQL statement easily can exceed the
 limit of 129 characters for the input parameter to quotename().
 
 While general_select still is a poor idea as a stored procedure, here is nevertheless a version that summarises some good coding virtues for dynamic SQL:


43) DSQL FORM

CREATE PROCEDURE general_select @tblname nvarchar(128),
                                @key     varchar(10),
                                @debug   bit = 0 AS
DECLARE @sql nvarchar(4000)
SET @sql = 'SELECT col1, col2, col3
            FROM dbo.' + quotename(@tblname) + '
            WHERE keycol = @key'
IF @debug = 1 PRINT @sql
EXEC sp_executesql @sql, N'@key varchar(10)', @key = @key
I'm using sp_executesql rather than EXEC().
I'm prefixing the table name with dbo.
I'm wrapping @tblname in quotename().
There is a @debug parameter.





44) FOR TRUE BLUE ARRAYS PASSED USE THIS TO UNBUNDLE THEM
f you are an older version of SQL Server, it is almost as simple. The only difference is that there is no built-in function, but you need to add one yourself. Here is a simple one:

CREATE FUNCTION intlist_to_tbl (@list nvarchar(MAX))
   RETURNS @tbl TABLE (number int NOT NULL) AS
BEGIN
   DECLARE @pos        int,
           @nextpos    int,
           @valuelen   int

   SELECT @pos = 0, @nextpos = 1

   WHILE @nextpos > 0
   BEGIN
      SELECT @nextpos = charindex(',', @list, @pos + 1)
      SELECT @valuelen = CASE WHEN @nextpos > 0
                              THEN @nextpos
                              ELSE len(@list) + 1
                         END - @pos - 1
      INSERT @tbl (number)
         VALUES (convert(int, substring(@list, @pos + 1, @valuelen)))
      SELECT @pos = @nextpos
   END
   RETURN
END
It is not the most efficient list-to-table function out there, but if you are only passing a few values from a multi-select checkbox, it is perfectly adequate. Here is an example how you would use it:

SELECT ...
FROM   tbl 
WHERE  col IN (SELECT number FROM intlist_to_tbl('1,2,3,4'))
You may note that I have designed this function to return int rather than string to save you from the need to use convert, and I have no parameter for the delimiter, but only deal with comma since this is by far the most common delimiter.

What I have said so far should be good for the vast majority of the cases where you want to use a list of values to pull data from an SQL Server table.

Still there are situations where the solutions above will not meet your needs:

You need a different delimiter than comma (and you are not on SQL 2016, so you cannot use string_split).
You have a list of something else than numbers.
You need to know the position of the values in the list.
You are not permitted to add functions in the database (and you are not on SQL 2016 to use string_split).
You have very long lists, say over 1000 values. In that case, you want something more efficient than intlist_to_tbl.


45) IF THE CURSOR DOESS NOT HAVE TO BE GLOBALLL, USE CURSOR VARIABLE INSTEAD
There is however a way to use locally-scoped cursors with dynamic SQL. Anthony Faull pointed out to me that you can achieve this with cursor variables, as in this example:

DECLARE @my_cur CURSOR
EXEC sp_executesql
     N'SET @my_cur = CURSOR STATIC FOR
       SELECT name FROM dbo.sysobjects;
       OPEN @my_cur',
     N'@my_cur cursor OUTPUT', @my_cur OUTPUT
FETCH NEXT FROM @my_cur









45) DYNAMIC SQL TOOLBOX 

GENEIC FORMS OF STATEMENTS FROM MS WEBSITE
DO SEARCH REPLACE ON THEM

--> STATIC TO PARAMITISED

WITH ##





