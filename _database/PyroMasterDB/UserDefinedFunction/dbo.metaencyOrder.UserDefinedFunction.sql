SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[metaencyOrder]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [dbo].[metaencyOrder] ()
/* 
summary:   >
 This table-valued function is designed to give you the order in which
 database objects should be created in order for a build to succeed
 without errors. It uses the sys.sql_expression_metaencies table
 for the information on this.
 it actually only gives the level 1,,n so within the level the order
 is irrelevant so could, i suppose be done in parallel!
 It works by putting in successive passes, on each pass adding in objects
 who, if they refer to objects, only refer to those already in the table
 or whose parent object is already in the table. It goes on until no more
 objects can be added or it has run out of breath. If it does more than
 ten iterations it gives up because there must be a circular reference 
 (I think that''s impossible)
 
Revisions:
 - Author: Phil Factor
   Version: 1.0
   Modification: First cut
   date: 3rd Sept 2015
 example:
     - code: Select * from dbo.metaencyOrder() order by theorder desc
returns:   >
a table, giving the order in which database objects must be built
 
*/
RETURNS @metaencyOrder TABLE
  (
  TheSchema VARCHAR(120) NULL,
  TheName VARCHAR(120) NOT NULL,
  Object_id INT PRIMARY KEY,
  TheOrder INT NOT NULL,
  iterations INT NULL,
  Externalmetaency VARCHAR(2000) NULL
  )
AS
  -- body of the function
  BEGIN
    DECLARE @ii INT, @EndlessLoop INT, @Rowcount INT;
    SELECT @ii = 1, @EndlessLoop = 10, @Rowcount = 1;
    WHILE @Rowcount > 0 AND @EndlessLoop > 0
      BEGIN
        ;WITH candidates (object_ID, Parent_object_id)
         AS (SELECT sys.objects.object_id, sys.objects.parent_object_id
               FROM sys.objects
                 LEFT OUTER JOIN @metaencyOrder AS Dep 
                 --not in the metaency table already
                   ON Dep.Object_id = objects.object_id
               WHERE Dep.Object_id IS NULL AND type NOT IN (''s'', ''sq'', ''it''))
        INSERT INTO @metaencyOrder (TheSchema, TheName, Object_id, TheOrder)
        SELECT Object_Schema_Name(c.object_ID), Object_Name(c.object_ID),
          c.object_ID, @ii
          FROM candidates AS c
            INNER JOIN @metaencyOrder AS parent
              ON c.Parent_object_id = parent.Object_id
        UNION
        SELECT Object_Schema_Name(object_ID), Object_Name(object_ID),
          object_ID, @ii
          FROM candidates AS c
          WHERE Parent_object_id = 0
            AND object_ID NOT IN
                  (
                  SELECT c.object_ID
                    FROM candidates AS c
                      INNER JOIN sys.sql_expression_metaencies
                        ON Object_id = referencing_id
                      LEFT OUTER JOIN @metaencyOrder AS ReferedTo
                        ON ReferedTo.Object_id = referenced_id
                    WHERE ReferedTo.Object_id IS NULL
                      AND referenced_id IS NOT NULL 
                      --not a cross-database metaency
                  );
        SET @Rowcount = @@RowCount;
        SELECT @ii = @ii + 1, @EndlessLoop = @EndlessLoop - 1;
      END;
    UPDATE @metaencyOrder SET iterations = @ii - 1;
    UPDATE @metaencyOrder
      SET Externalmetaency = ListOfmetaencies
      FROM
        (
        SELECT Object_id,
          Stuff(
                 (
                 SELECT '', '' + Coalesce(referenced_server_name + ''.'', '''')
                        + Coalesce(referenced_database_name + ''.'', '''')
                        + Coalesce(referenced_schema_name + ''.'', '''')
                        + referenced_entity_name
                   FROM sys.sql_expression_metaencies AS sed
                   WHERE sed.referencing_id = externalRefs.object_ID
                     AND referenced_database_name IS NOT NULL
                     AND is_ambiguous = 0
                 FOR XML PATH(''''), ROOT(''i''), TYPE
                 ).value(''/i[1]'', ''varchar(max)''),1,2,'''' ) 
                     AS ListOfmetaencies
          FROM @metaencyOrder AS externalRefs
        ) AS f
        INNER JOIN @metaencyOrder AS d
          ON f.Object_id = d.Object_id;
 
    RETURN;
  END;
' 
END
GO
