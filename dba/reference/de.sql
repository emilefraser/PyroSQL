SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'TempDB..#TablesInDependencyOrder') IS NOT NULL
  DROP PROCEDURE #TablesInDependencyOrder
GO
 
Create PROCEDURE #TablesInDependencyOrder
/**
summary:  
  For the table(s) you specify, this routine returns a table containing all the related tables 
  in the current database, their schema, object_ID, and their
  dependency level. 
  You would use this for deleting the data from tables or BCPing in the data.
 
Author: Phil Factor
Revision: 1.0 First cut
Created: 25th september 2015
example:
    - 
      Declare @tables Table( TheObject_ID INT NOT null,
      TheName SYSNAME NOT null,TheSchema SYSNAME NOT null,
      HasIdentityColumn INT NOT null,TheOrder INT NOT null)
      insert into @tables  
         Execute #TablesInDependencyOrder
      Select * from @Tables
 
 
returns: 
        TheObject_ID INT,--the tables' object ID
        TheName SYSNAME, --the name of the table
        TheSchema SYSNAME, --the schema where it lives
        TheOrder INT) --Order by this column
**/
 
AS
SET NOCOUNT ON;
DECLARE @Rowcount INT, @ii INT
CREATE TABLE #tables (
  TheObject_ID INT,--the tables' object ID
  TheName SYSNAME, --the name of the table
  TheSchema SYSNAME, --the schema where it lives
  TheOrder INT DEFAULT 0) --we update this later to impose an order
 
/* We'll use a SQL 'set-based'  form of the topological sort. Firstly
we will read in all the desired tables identifying
the start nodes as level 1 These "start nodes" have no incoming edges
at least one such node must exist in an acyclic graph*/
 
INSERT  INTO #tables (Theobject_ID, TheName, TheSchema, TheOrder)
  SELECT  DISTINCT 
      TheTable.OBJECT_ID, TheTable.NAME, 
      object_schema_name(TheTable.OBJECT_ID) AS [Schema],
      CASE WHEN --referenced.parent_object_ID IS NULL AND
               referencing.parent_object_ID IS NULL THEN 1 ELSE 0 END AS TheOrder
    FROM  sys.tables TheTable
    -- LEFT OUTER JOIN sys.foreign_Keys referenced
    -- ON referenced.referenced_Object_ID = TheTable.object_ID
    LEFT OUTER JOIN sys.foreign_Keys referencing
     ON referencing.parent_Object_ID = TheTable.object_ID
SElECT @Rowcount=100,@ii=2
--and then do tables successively as they become 'safe'
 
WHILE @Rowcount > 0
  BEGIN
  UPDATE  #tables
  SET   TheOrder = @ii
  WHERE   #tables.TheObject_ID IN (
      SELECT  parent.TheObject_ID
      FROM  #tables parent
          INNER JOIN sys.foreign_Keys
             ON sys.foreign_Keys.parent_Object_ID = parent.Theobject_ID
          INNER JOIN #tables referenced
             ON sys.foreign_Keys.referenced_Object_ID = referenced.Theobject_ID
            AND sys.foreign_Keys.referenced_Object_ID <> parent.Theobject_ID
      WHERE   parent.TheOrder = 0--i.e. it hasn't been ordered yet
      GROUP BY parent.TheObject_ID
      HAVING  SUM(CASE WHEN referenced.TheOrder = 0 THEN -20000
               ELSE referenced.TheOrder
            END) > 0--where all its referenced tables have been ordered
  )
  SET @Rowcount = @@Rowcount
  SET @ii = @ii + 1
  IF @ii > 100
    BREAK
END
SELECT TheObject_ID,TheName,TheSchema,TheOrder
 FROM #tables order by TheOrder
IF @ii > 100 --not a directed acyclic graph (DAG).
  RAISERROR ('Cannot load in tables with mutual references in foreign keys',16,1)
IF EXISTS ( SELECT  * FROM #tables WHERE TheOrder = 0 )
  RAISERROR ('could not do the topological sort',16,1)
 
GO


EXEC #TablesInDependencyOrder
