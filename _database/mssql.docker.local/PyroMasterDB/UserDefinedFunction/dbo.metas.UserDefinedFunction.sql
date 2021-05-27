SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[metas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	This Table function returns a a table giving the metaencies of the object whose name
	is supplied as a parameter.
	At the moment, only objects are allowed as a parameter, You can specify whether you 
	want those objects that rely on the object, or those on whom the object relies.
*/

CREATE   FUNCTION [dbo].[metas] (
	@ObjectName VARCHAR(200)
,	@ObjectsOnWhichItmetas BIT
)
RETURNS @References TABLE (
	ThePath VARCHAR(MAX), --the ancestor objects delimited by a ''/''
	TheFullEntityName VARCHAR(257),
	TheType VARCHAR(20),
	Iteration INT
)


/*
	SELECT  space(iteration * 4) + TheFullEntityName + '' ('' + rtrim(TheType) + '')''
	FROM    dbo.metas(''ArmTemplate'',0)
	ORDER BY ThePath


 THEPATH                                            THEFULLENTITYNAME              THETYPE ITERATION
 -------------------------------------------------- -----------------------------  ------- ---------
 dbo.ObjectTableName                                dbo.ObjectTableName            U       1
 dbo.ObjectTableName/dbo.ReferencingStoredProcedure dbo.ReferencingStoredProcedure P       2
*/

AS
  BEGIN
    DECLARE @Databasemetaencies TABLE (
      EntityName NVARCHAR(200),
      EntityType NCHAR(5),
      metaencyType NCHAR(4),
      TheReferredEntity NVARCHAR(200),
      TheReferredType NCHAR(5)
	);

    INSERT INTO @Databasemetaencies (EntityName, EntityType, metaencyType,
    TheReferredEntity, TheReferredType)
    -- Tables that reference UDTs
    SELECT Object_Schema_Name(O.object_id) + N''.'' + O.name AS EntityName,
      O.type AS EntityType, N''hard'' AS metaencyType,
      TY.name AS TheReferredEntity, N''UDT'' AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS C
          ON C.object_id = O.object_id
        INNER JOIN sys.types AS TY
          ON TY.user_type_id = C.user_type_id
      WHERE TY.is_user_defined = 1
    UNION ALL
    -- UDTTs that reference UDTs
    SELECT Object_Schema_Name(TT.type_table_object_id) + N''.'' + TT.name AS EntityName,
      N''UDTT'' AS EntityType, N''hard'' AS metaencyType,
      TY.name AS TheReferredEntity, N''UDT'' AS TheReferredType
      FROM sys.table_types AS TT
        INNER JOIN sys.columns AS C
          ON C.object_id = TT.type_table_object_id
        INNER JOIN sys.types AS TY
          ON TY.user_type_id = C.user_type_id
      WHERE TY.is_user_defined = 1
    UNION ALL
    -- Tables/views that reference triggers
    SELECT Object_Schema_Name(OBJECT_CHILD.object_id) + N''.''
           + OBJECT_CHILD.name AS EntityName, OBJECT_CHILD.type AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(OBJECT_PARENT.object_id) + N''.'' + OBJECT_PARENT.name AS TheReferredEntity,
      OBJECT_PARENT.type AS TheReferredType
      FROM sys.objects AS OBJECT_PARENT
        INNER JOIN sys.objects AS OBJECT_CHILD
          ON OBJECT_CHILD.parent_object_id = OBJECT_PARENT.object_id
      WHERE OBJECT_CHILD.type = N''TR''
    UNION ALL
    -- Tables that reference defaults via columns (only default objects)
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N''.''
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N''U'' AS EntityType, N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS OBJECT_COLUMNS
          ON OBJECT_COLUMNS.default_object_id = O.object_id
      WHERE O.parent_object_id = 0
    UNION ALL
    -- Types that reference defaults (only default objects)
    SELECT TYPES.name AS EntityName, N''UDT'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.types AS TYPES
          ON TYPES.default_object_id = O.object_id
      WHERE O.parent_object_id = 0
    UNION ALL
    -- Tables that reference rules via columns
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N''.''
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N''U'' AS EntityType, N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.columns AS OBJECT_COLUMNS
          ON OBJECT_COLUMNS.rule_object_id = O.object_id
    UNION ALL
    -- Types that reference rules
    SELECT TYPES.name AS EntityName, N''UDT'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.types AS TYPES
          ON TYPES.rule_object_id = O.object_id
    UNION ALL
    -- Tables that reference XmlSchemaCollections
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N''.''
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N''U'' AS EntityType, N''hard'' AS metaencyType,
      X.name AS TheReferredEntity, N''XMLC'' AS TheReferredType
      FROM sys.columns AS OBJECT_COLUMNS --should we eliminate views?

        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = OBJECT_COLUMNS.xml_collection_id
    UNION ALL
    -- Table types that reference XmlSchemaCollections
    SELECT Object_Schema_Name(OBJECT_COLUMNS.object_id) + N''.''
           + Object_Name(OBJECT_COLUMNS.object_id) AS EntityName,
      N''UDTT'' AS EntityType, N''hard'' AS metaencyType,
      X.name AS TheReferredEntity, N''XMLC'' AS TheReferredType
      FROM sys.columns AS OBJECT_COLUMNS
        INNER JOIN sys.table_types AS TT
          ON TT.type_table_object_id = OBJECT_COLUMNS.object_id
        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = OBJECT_COLUMNS.xml_collection_id
    UNION ALL
    -- Procedures that reference XmlSchemaCollections
    SELECT Object_Schema_Name(PARAMS.object_id) + N''.'' + O.name AS EntityName,
      O.type AS EntityType, N''hard'' AS metaencyType,
      X.name AS TheReferredEntity, N''XMLC'' AS TheReferredType
      FROM sys.parameters AS PARAMS
        INNER JOIN sys.xml_schema_collections AS X
          ON X.xml_collection_id = PARAMS.xml_collection_id
        INNER JOIN sys.objects AS O
          ON O.object_id = PARAMS.object_id
    UNION ALL
    -- Table references table
    SELECT Object_Schema_Name(TBL.object_id) + N''.'' + TBL.name AS EntityName,
      TBL.type AS EntityType, N''hard'' AS metaencyType,
      Object_Schema_Name(referenced_object_id) + N''.''
      + Object_Name(referenced_object_id) AS TheReferredEntity,
      N''U'' AS TheReferredType
      FROM sys.foreign_keys AS FK
        INNER JOIN sys.tables AS TBL
          ON TBL.object_id = FK.parent_object_id
    UNION ALL
    -- UDT references types
    SELECT Object_Schema_Name(PARAMS.object_id) + N''.'' + O.name AS EntityName,
      O.type AS EntityType, N''hard'' AS metaencyType,
      PARAM_TYPES.name AS TheReferredEntity, N''UDT'' AS TheReferredType
      FROM sys.parameters AS PARAMS
        INNER JOIN sys.types AS PARAM_TYPES
          ON PARAMS.user_type_id = PARAM_TYPES.user_type_id
         AND PARAM_TYPES.is_user_defined <> 0
        INNER JOIN sys.objects AS O
          ON O.object_id = PARAMS.object_id
    UNION ALL
    -- Table, view references partition scheme
    SELECT Object_Schema_Name(O.object_id) + N''.'' + O.name AS EntityName,
      O.type AS EntityType, N''hard'' AS metaencyType,
      PS.name AS TheReferredEntity, N''PS'' AS TheReferredType
      FROM sys.indexes AS IDX
        INNER JOIN sys.partitions AS P
          ON IDX.object_id = P.object_id AND IDX.index_id = P.index_id
        INNER JOIN sys.partition_schemes AS PS
          ON IDX.data_space_id = PS.data_space_id
        INNER JOIN sys.objects AS O
          ON O.object_id = IDX.object_id
    UNION ALL
    -- Partition scheme references partition function
    SELECT PS.name AS EntityName, N''PS'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.partition_schemes AS PS
        INNER JOIN sys.objects AS O
          ON PS.function_id = O.object_id
    UNION ALL
    -- Plan guide references sp, udf (and triggers?)
    SELECT PG.name AS EntityName, N''PG'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.plan_guides AS PG
          ON PG.scope_object_id = O.object_id
    UNION ALL
    -- Synonym refrences object
    SELECT S.name AS EntityName, N''SYN'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.synonyms AS S
          ON Object_Id(S.base_object_name) = O.object_id
    UNION ALL
    -- Sequences that reference UDTTs
    SELECT S.name AS EntityName, N''SEQ'' AS EntityType,
      N''hard'' AS metaencyType,
      Object_Schema_Name(O.object_id) + N''.'' + O.name AS TheReferredEntity,
      O.type AS TheReferredType
      FROM sys.objects AS O
        INNER JOIN sys.sequences AS S
          ON S.user_type_id = O.object_id
    UNION ALL
    -- Soft metaencies
    SELECT DISTINCT Coalesce(Object_Schema_Name(SED.referencing_id) + N''.'', N'''')
                    + Object_Name(SED.referencing_id) AS EntityName,
      REFERENCING_OBJECT.type AS EntityType, N''soft'' AS metaencyType,
      Coalesce(REFERENCED_SCHEMA.name + N''.'', N'''') + --likely schema name
      Coalesce(SED.referenced_entity_name, N'''') AS TheReferredEntity, --very likely entity name
      REFERENCED_OBJECT.type AS TheReferredType
      FROM sys.sql_expression_metaencies AS SED
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
    ( N''FN'', -- SQL scalar function
      N''IF'', -- SQL inline table-valued function
      N''P'', -- SQL Stored Procedure
      N''TF'', -- SQL table-valued-function
      N''TR'', -- SQL DML trigger
      N''U'', -- Table (user-defined)
      N''V'' -- View
    );

    DECLARE @RowCount INT;

    DECLARE @ii INT;

    -- Firstly we put in the object as a seed.
    INSERT INTO @References (ThePath, TheFullEntityName, TheType, iteration)
      SELECT Coalesce(Object_Schema_Name(O.object_id) + N''.'', N'''') + O.name AS ThePath,
        Coalesce(Object_Schema_Name(O.object_id) + N''.'', N'''') + O.name AS TheFullEntityName,
        O.type AS theType, 1 AS [iteration ]
        FROM sys.objects AS O
        WHERE O.name LIKE @ObjectName;

    -- Then we just pull out the metaencies at each level. watching out for
    -- self-references and circular references
    SELECT @RowCount = @@RowCount, @ii = 2;

    -- If we are looking for objects on which it metas
    IF @ObjectsOnWhichItmetas <> 0
      WHILE @ii < 20 AND @RowCount > 0
        BEGIN
          INSERT INTO @References (ThePath, TheFullEntityName, TheType,
          iteration)
            SELECT DISTINCT PREVIOUS_REFERENCES.ThePath + N''/''
                            + DATABASE_metaENCIES.TheReferredEntity AS ThePath,
              DATABASE_metaENCIES.TheReferredEntity AS TheFullEntityName,
              DATABASE_metaENCIES.TheReferredType AS theType,
              @ii AS iteration
              FROM @Databasemetaencies AS DATABASE_metaENCIES
                INNER JOIN @References AS PREVIOUS_REFERENCES
                  ON PREVIOUS_REFERENCES.TheFullEntityName = DATABASE_metaENCIES.EntityName
                 AND PREVIOUS_REFERENCES.iteration = @ii - 1
              WHERE DATABASE_metaENCIES.TheReferredEntity <> DATABASE_metaENCIES.EntityName
                AND DATABASE_metaENCIES.TheReferredEntity NOT IN 
				  (SELECT RSUB_EXISTING.TheFullEntityName FROM @References AS RSUB_EXISTING);

          SELECT @RowCount = @@RowCount;
          SELECT @ii = @ii + 1;
        END;

    ELSE

      -- We are looking for objects that meta on it.
      WHILE @ii < 20 AND @RowCount > 0
        BEGIN
          INSERT INTO @References (ThePath, TheFullEntityName, TheType,
          iteration)
            SELECT DISTINCT PREVIOUS_REFERENCES.ThePath + N''/''
                            + DATABASE_metaENCIES.EntityName AS ThePath,
              DATABASE_metaENCIES.EntityName AS TheFullEntityName,
              DATABASE_metaENCIES.EntityType AS theType, @ii AS iteration
              FROM @Databasemetaencies AS DATABASE_metaENCIES
                INNER JOIN @References AS PREVIOUS_REFERENCES
                  ON PREVIOUS_REFERENCES.TheFullEntityName = DATABASE_metaENCIES.TheReferredEntity
                 AND PREVIOUS_REFERENCES.iteration = @ii - 1
              WHERE DATABASE_metaENCIES.TheReferredEntity <> DATABASE_metaENCIES.EntityName
                AND DATABASE_metaENCIES.EntityName NOT IN 
				 (SELECT RSUB_EXISTING.TheFullEntityName FROM @References AS RSUB_EXISTING);

          SELECT @RowCount = @@RowCount;
          SELECT @ii = @ii + 1;
        END;

    RETURN;
  END;


' 
END
GO
