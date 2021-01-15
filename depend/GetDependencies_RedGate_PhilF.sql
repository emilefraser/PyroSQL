IF Object_Id(N'dbo.It_Depends') IS NOT NULL DROP FUNCTION dbo.It_Depends;
GO

CREATE FUNCTION dbo.It_Depends (@ObjectName VARCHAR(200), @ObjectsOnWhichItDepends BIT)
RETURNS @References TABLE
  (
  ThePath VARCHAR(MAX), --the ancestor objects delimited by a '/'
  TheFullEntityName VARCHAR(200),
  TheType VARCHAR(20),
  iteration INT
  )

/**
summary:   >
 This Table function returns a a table giving the dependencies of the object whose name
 is supplied as a parameter.
 At the moment, only objects are allowed as a parameter, You can specify whether you 
 want those objects that rely on the object, or those on whom the object relies.
History: >
  Adapted from source code published at:
  https://www.red-gate.com/simple-talk/wp-content/uploads/imported/2284-ItDepends.html

compatibility: SQL Server 2005 - SQL Server 2017
Example usage: |

 /*
 * AdventureWorks.Employee: objects that depend on it
 * Note: function SPACE(...) indents rows to indicate hierarchical
 * relationships
 */

  USE AdventureWorks
  SELECT      [Result] =
              SPACE(F.iteration * 4) +
              F.TheFullEntityName +
              N' (' + RTRIM(F.TheType) + N'')''

    FROM      dbo.It_Depends(N''Employee'', 0) F

  ORDER BY    F.ThePath

  /*
   * AdventureWorks.Employee: objects that it depends on
   * Note: function SPACE(...) indents rows to indicate hierarchical
   * relationships
   */

  USE AdventureWorks
  SELECT      [Result] =
              SPACE(F.iteration * 4) +
              F.TheFullEntityName +
              N' (' + RTRIM(F.TheType) + N'')''

    FROM      dbo.It_Depends(N''Employee'', 1) F

  ORDER BY    F.ThePath
Blog post overview and comments: https://www.red-gate.com/simple-talk/sql/t-sql-programming/dependencies-and-references-in-sql-server/
Revisions:
 - Author: Phil Factor
   Version: 1.1
   Modification: Allowed both types of dependencies, returned full detail table
   date: 2015-09-20

 - Author: Kevin Schultz 
   Version: 1.2
   Date: 2016-03-28 
   Modification: >
     Add the schema name consistently to column "@DatabaseDependencies.TheReferredEntity" by adding
     an INNER JOIN to sys.schemas and modifying the SELECT clause 
  
 - Author: Kevin Schultz 
   Version: 1.2
   Date: 2016-10-25 
   Modification: >   
     Insert the current dependency object type (DatabaseDependencies.EntityType) instead of the
     parent dependency object type  (previousReferences.TheType), in the INSERT INTO SELECT clause

 - Author: Kevin Schultz 
   Version: 1.3
   Date: 2018-11-25 
   Modification: >
     2018-11-25 KLS Column sys.sql_expression_dependencies.referenced_id is NULLable, so substitute 
     with lookup OBJECT_ID(sys.sql_expression_dependencies.referenced_entity_name) when inserting 
     soft dependencies into table variable DatabaseDepencies. Sequences EntityType changed from SYN
     to SEQ. Qualified object names and used aliases consistently. Converted to return Unicode 
     N*CHAR types.
 - Author: Kevin Schultz 
   Version: 1.4
   Date:  2018-11-27 
   Modification: > 
    SQL inline table-valued function (''IF'') type added  as acceptable soft dependency
ToDo: Must add assemblies, must allow entities such as types to be specified 
    
Returns: >
 references table which has the name, the type, the display order and the 'path' 
 of each dependent object
 In this example output, we have set @ObjectName=ObjectTableName and @ObjectsOnWhichItDepends=0,
 to retrieve objects dependent on ObjectTableName):
 
 THEPATH                                            THEFULLENTITYNAME              THETYPE ITERATION
 -------------------------------------------------- -----------------------------  ------- ---------
 dbo.ObjectTableName                                dbo.ObjectTableName            U       1
 dbo.ObjectTableName/dbo.ReferencingStoredProcedure dbo.ReferencingStoredProcedure P       2

...
**/
AS
  BEGIN
    DECLARE @DatabaseDependencies TABLE
      (
      EntityName NVARCHAR(200),
      EntityType NCHAR(5),
      DependencyType NCHAR(4),
      TheReferredEntity NVARCHAR(200),
      TheReferredType NCHAR(5)
      );
    /*
 Populate @DatabaseDependencies via multiple UNION ALL statements, one for
 each hard and soft dependency type. Table of hard references:
 https://www.red-gate.com/simple-talk/wp-content/uploads/imported/2284-Dependencies.png
 */

    INSERT INTO @DatabaseDependencies (EntityName, EntityType, DependencyType,
    TheReferredEntity, TheReferredType)
    -- Tables that reference UDTs
    SELECT Object_Schema_Name(O.object_id) + N'.' + O.name AS EntityName,
      O.type AS EntityType, N'hard' AS DependencyType,
      TY.name AS TheReferredEntity, N'UDT' AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS C
          ON C.object_id = O.object_id
        INNER JOIN sys.types AS TY
          ON TY.user_type_id = C.user_type_id
      WHERE TY.is_user_defined = 1
    UNION ALL
    -- UDTTs that reference UDTs
    SELECT Object_Schema_Name(TT.type_table_object_id) + N'.' + TT.name AS EntityName,
      N'UDTT' AS EntityType, N'hard' AS DependencyType,
      TY.name AS TheReferredEntity, N'UDT' AS TheReferredType
      FROM sys.table_types AS TT
        INNER JOIN sys.columns AS C
          ON C.object_id = TT.type_table_object_id
        INNER JOIN sys.types AS TY
          ON TY.user_type_id = C.user_type_id
      WHERE TY.is_user_defined = 1
    UNION ALL
    -- Tables/views that reference triggers
    SELECT Object_Schema_Name(OBJECT_CHILD.object_id) + N'.'
           + OBJECT_CHILD.name AS EntityName, OBJECT_CHILD.type AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(OBJECT_PARENT.object_id) + N'.' + OBJECT_PARENT.name AS TheReferredEntity,
      OBJECT_PARENT.type AS TheReferredType
      FROM sys.objects AS OBJECT_PARENT
        INNER JOIN sys.objects AS OBJECT_CHILD
          ON OBJECT_CHILD.parent_object_id = OBJECT_PARENT.object_id
      WHERE OBJECT_CHILD.type = N'TR'
    UNION ALL
    -- Tables that reference defaults via columns (only default objects)
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N'.'
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N'U' AS EntityType, N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS OBJECT_COLUMNS
          ON OBJECT_COLUMNS.default_object_id = O.object_id
      WHERE O.parent_object_id = 0
    UNION ALL
    -- Types that reference defaults (only default objects)
    SELECT TYPES.name AS EntityName, N'UDT' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.types AS TYPES
          ON TYPES.default_object_id = O.object_id
      WHERE O.parent_object_id = 0
    UNION ALL
    -- Tables that reference rules via columns
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N'.'
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N'U' AS EntityType, N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS OBJECT_COLUMNS
          ON OBJECT_COLUMNS.rule_object_id = O.object_id
    UNION ALL
    -- Types that reference rules
    SELECT TYPES.name AS EntityName, N'UDT' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.types AS TYPES
          ON TYPES.rule_object_id = O.object_id
    UNION ALL
    -- Tables that reference XmlSchemaCollections
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N'.'
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N'U' AS EntityType, N'hard' AS DependencyType,
      X.name AS TheReferredEntity, N'XMLC' AS TheReferredType
      FROM sys.columns AS OBJECT_COLUMNS --should we eliminate views?

        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = OBJECT_COLUMNS.xml_collection_id
    UNION ALL
    -- Table types that reference XmlSchemaCollections
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N'.'
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N'UDTT' AS EntityType, N'hard' AS DependencyType,
      X.name AS TheReferredEntity, N'XMLC' AS TheReferredType
      FROM sys.columns AS OBJECT_COLUMNS
        INNER JOIN sys.table_types AS TT
          ON TT.type_table_object_id = OBJECT_COLUMNS.object_id
        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = OBJECT_COLUMNS.xml_collection_id
    UNION ALL
    -- Procedures that reference XmlSchemaCollections
    SELECT Object_Schema_Name(PARAMS.object_id) + N'.' + O.name AS EntityName,
      O.type AS EntityType, N'hard' AS DependencyType,
      X.name AS TheReferredEntity, N'XMLC' AS TheReferredType
      FROM sys.parameters AS PARAMS
        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = PARAMS.xml_collection_id
        INNER JOIN sys.objects AS O
          ON O.object_id = PARAMS.object_id
    UNION ALL
    -- Table references table
    SELECT Object_Schema_Name(TBL.object_id) + N'.' + TBL.name AS EntityName,
      TBL.type AS EntityType, N'hard' AS DependencyType,
      Object_Schema_Name(referenced_object_id) + N'.'
      + Object_Name(referenced_object_id) AS TheReferredEntity,
      N'U' AS TheReferredType
      FROM sys.foreign_keys AS FK
        INNER JOIN sys.tables AS TBL
          ON TBL.object_id = FK.parent_object_id
    UNION ALL
    -- UDT references types
    SELECT Object_Schema_Name(PARAMS.object_id) + N'.' + O.name AS EntityName,
      O.type AS EntityType, N'hard' AS DependencyType,
      PARAM_TYPES.name AS TheReferredEntity, N'UDT' AS TheReferredType
      FROM sys.parameters AS PARAMS
        INNER JOIN sys.types AS PARAM_TYPES
          ON PARAMS.user_type_id = PARAM_TYPES.user_type_id
         AND PARAM_TYPES.is_user_defined <> 0
        INNER JOIN sys.objects AS O
          ON O.object_id = PARAMS.object_id
    UNION ALL
    -- Table, view references partition scheme
    SELECT Object_Schema_Name(O.object_id) + N'.' + O.name AS EntityName,
      O.type AS EntityType, N'hard' AS DependencyType,
      PS.name AS TheReferredEntity, N'PS' AS TheReferredType
      FROM sys.indexes AS IDX
        INNER JOIN sys.partitions AS P
          ON IDX.object_id = P.object_id AND IDX.index_id = P.index_id
        INNER JOIN sys.partition_schemes AS PS
          ON IDX.data_space_id = PS.data_space_id
        INNER JOIN sys.objects AS O
          ON O.object_id = IDX.object_id
    UNION ALL
    -- Partition scheme references partition function
    SELECT PS.name AS EntityName, N'PS' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.partition_schemes AS PS
        INNER JOIN sys.objects AS O
          ON PS.function_id = O.object_id
    UNION ALL
    -- Plan guide references sp, udf (and triggers?)
    SELECT PG.name AS EntityName, N'PG' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.plan_guides AS PG
          ON PG.scope_object_id = O.object_id
    UNION ALL
    -- Synonym refrences object
    SELECT S.name AS EntityName, N'SYN' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.synonyms AS S
          ON Object_Id(S.base_object_name) = O.object_id
    UNION ALL
    -- Sequences that reference UDTTs
    SELECT S.name AS EntityName, N'SEQ' AS EntityType,
      N'hard' AS DependencyType,
      Object_Schema_Name(O.object_id) + N'.' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.sequences AS S
          ON S.user_type_id = O.object_id
    UNION ALL
    -- Soft dependencies
    SELECT DISTINCT Coalesce(Object_Schema_Name(SED.referencing_id) + N'.', N'')
                    + Object_Name(SED.referencing_id) AS EntityName,
      REFERENCING_OBJECT.type AS EntityType, N'soft' AS DependencyType,
      Coalesce(REFERENCED_SCHEMA.name + N'.', N'') + --likely schema name
      Coalesce(SED.referenced_entity_name, N'') AS TheReferredEntity, --very likely entity name
      REFERENCED_OBJECT.type AS TheReferredType
      FROM sys.sql_expression_dependencies AS SED
        INNER JOIN sys.objects AS REFERENCING_OBJECT
          ON SED.referencing_id = REFERENCING_OBJECT.object_id
        INNER JOIN(sys.objects AS REFERENCED_OBJECT
        INNER JOIN sys.schemas AS REFERENCED_SCHEMA
          ON REFERENCED_OBJECT.schema_id = REFERENCED_SCHEMA.schema_id)
          ON Object_Id(SED.referenced_entity_name) = REFERENCED_OBJECT.object_id
      WHERE SED.referencing_class = 1
        AND SED.referenced_class = 1
        /*
            * sys.objects (Transact-SQL) type values, via: 
            * https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-2017
            */
        AND REFERENCING_OBJECT.type IN
    ( N'FN', -- SQL scalar function
      N'IF', -- SQL inline table-valued function
      N'P', -- SQL Stored Procedure
      N'TF', -- SQL table-valued-function
      N'TR', -- SQL DML trigger
      N'U', -- Table (user-defined)
      N'V' -- View
    );

    DECLARE @RowCount INT;

    DECLARE @ii INT;

    -- Firstly we put in the object as a seed.
    INSERT INTO @References (ThePath, TheFullEntityName, TheType, iteration)
      SELECT Coalesce(Object_Schema_Name(O.object_id) + N'.', N'') + O.name AS ThePath,
        Coalesce(Object_Schema_Name(O.object_id) + N'.', N'') + O.name AS TheFullEntityName,
        O.type AS theType, 1 AS [iteration ]
        FROM sys.objects AS O
        WHERE O.name LIKE @ObjectName;

    -- Then we just pull out the dependencies at each level. watching out for
    -- self-references and circular references
    SELECT @RowCount = @@RowCount, @ii = 2;

    -- If we are looking for objects on which it depends
    IF @ObjectsOnWhichItDepends <> 0
      WHILE @ii < 20 AND @RowCount > 0
        BEGIN
          INSERT INTO @References (ThePath, TheFullEntityName, TheType,
          iteration)
            SELECT DISTINCT PREVIOUS_REFERENCES.ThePath + N'/'
                            + DATABASE_DEPENDENCIES.TheReferredEntity AS ThePath,
              DATABASE_DEPENDENCIES.TheReferredEntity AS TheFullEntityName,
              DATABASE_DEPENDENCIES.TheReferredType AS theType,
              @ii AS iteration
              FROM @DatabaseDependencies AS DATABASE_DEPENDENCIES
                INNER JOIN @References AS PREVIOUS_REFERENCES
                  ON PREVIOUS_REFERENCES.TheFullEntityName = DATABASE_DEPENDENCIES.EntityName
                 AND PREVIOUS_REFERENCES.iteration = @ii - 1
              WHERE DATABASE_DEPENDENCIES.TheReferredEntity <> DATABASE_DEPENDENCIES.EntityName
                AND DATABASE_DEPENDENCIES.TheReferredEntity NOT IN 
				  (SELECT RSUB_EXISTING.TheFullEntityName FROM @References AS RSUB_EXISTING);

          SELECT @RowCount = @@RowCount;
          SELECT @ii = @ii + 1;
        END;

    ELSE

      -- We are looking for objects that depend on it.
      WHILE @ii < 20 AND @RowCount > 0
        BEGIN
          INSERT INTO @References (ThePath, TheFullEntityName, TheType,
          iteration)
            SELECT DISTINCT PREVIOUS_REFERENCES.ThePath + N'/'
                            + DATABASE_DEPENDENCIES.EntityName AS ThePath,
              DATABASE_DEPENDENCIES.EntityName AS TheFullEntityName,
              DATABASE_DEPENDENCIES.EntityType AS theType, @ii AS iteration
              FROM @DatabaseDependencies AS DATABASE_DEPENDENCIES
                INNER JOIN @References AS PREVIOUS_REFERENCES
                  ON PREVIOUS_REFERENCES.TheFullEntityName = DATABASE_DEPENDENCIES.TheReferredEntity
                 AND PREVIOUS_REFERENCES.iteration = @ii - 1
              WHERE DATABASE_DEPENDENCIES.TheReferredEntity <> DATABASE_DEPENDENCIES.EntityName
                AND DATABASE_DEPENDENCIES.EntityName NOT IN 
				 (SELECT RSUB_EXISTING.TheFullEntityName FROM @References AS RSUB_EXISTING);

          SELECT @RowCount = @@RowCount;
          SELECT @ii = @ii + 1;
        END;

    RETURN;
  END;


