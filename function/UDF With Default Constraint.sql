SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO
/*******************************************
The code for this function contains extra steps, because SQL Server 
does not allow you to alter a function if it is referenced by a default constraint
******************************************/



/*******************************************
1. Identify default constraints on tables which reference this function
Store commands to drop and recreate those functions in a table
Note: SQL Server does not allow you to create a default constraint with a system name
in an ALTER TABLE ADD CONSTRAINT statement like this, so this script has a side-effect
of turning system-named default constraints into user-named default constraints (using what is 
present in the database as the hard coded name)
******************************************/

DROP TABLE IF EXISTS #manageconstraints;
GO

SELECT N'ALTER TABLE ' + s.name + N'.[' + t.name + N'] DROP CONSTRAINT ' + d.name AS drop_command,
       N'ALTER TABLE ' + s.name + N'.[' + t.name + N'] ADD CONSTRAINT ' + d.name + N' DEFAULT ' + d.definition
       + N' for ' + c.name AS create_command
INTO #manageconstraints
FROM sys.tables t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    JOIN sys.default_constraints d
        ON d.parent_object_id = t.object_id
    JOIN sys.columns c
        ON c.object_id = t.object_id
           AND c.column_id = d.parent_column_id
WHERE t.name NOT IN ( '__MigrationLog', '__SchemaSnapshot' );


/*******************************************
2. Drop default constraints before altering function
******************************************/

DECLARE @command NVARCHAR(MAX);

DECLARE drop_constraints CURSOR FAST_FORWARD LOCAL READ_ONLY FOR
SELECT drop_command
FROM #manageconstraints;

OPEN drop_constraints;

FETCH NEXT FROM drop_constraints
INTO @command;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @command;
    EXEC sp_executesql @command;
    FETCH NEXT FROM drop_constraints
    INTO @command;
END;

CLOSE drop_constraints;
DEALLOCATE drop_constraints;
GO


/*******************************************
3. Recreate the function
******************************************/


CREATE OR ALTER FUNCTION [dbo].[IMAUDF]
()
RETURNS DATETIME2(0)
AS
BEGIN
    DECLARE @return DATETIME2(0);
    SET @return = SYSDATETIME();
    RETURN @return;
END;
GO



/*******************************************
4. Recreate default constraints referencing this function
******************************************/

DECLARE @command NVARCHAR(MAX);

DECLARE create_constraints CURSOR FAST_FORWARD LOCAL READ_ONLY FOR
SELECT create_command
FROM #manageconstraints;

OPEN create_constraints;

FETCH NEXT FROM create_constraints
INTO @command;

WHILE @@FETCH_STATUS = 0
BEGIN

    PRINT @command;
    EXEC sp_executesql @command;
    FETCH NEXT FROM create_constraints
    INTO @command;
END;

CLOSE create_constraints;
DEALLOCATE create_constraints;
GO