/****** Object:  UserDefinedFunction [dbo].[DependencyOrder]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DependencyOrder] ()
/* 
summary:   >
 This table-valued function is designed to give you the order in which
 database objects should be created in order for a build to succeed
 without errors. It uses the sys.sql_expression_dependencies table
 for the information on this.
 it actually only gives the level 1,,n so within the level the order
 is irrelevant so could, i suppose be done in parallel!
 It works by putting in successive passes, on each pass adding in objects
 who, if they refer to objects, only refer to those already in the table
 or whose parent object is already in the table. It goes on until no more
 objects can be added or it has run out of breath. If it does more than
 ten iterations it gives up because there must be a circular reference 
 (I think that's impossible)
 
Revisions:
 - Author: Phil Factor
   Version: 1.0
   Modification: First cut
   date: 3rd Sept 2015
 example:
     - code: Select * from dbo.DependencyOrder() order by theorder desc
returns:   >
a table, giving the order in which database objects must be built
 
*/
RETURNS @DependencyOrder TABLE
  (
  TheSchema VARCHAR(120) NULL,
  TheName VARCHAR(120) NOT NULL,
  Object_id INT PRIMARY KEY,
  TheOrder INT NOT NULL,
  iterations INT NULL,
  ExternalDependency VARCHAR(2000) NULL
  )
AS
  BEGIN
    DECLARE @ii INT, @EndlessLoop INT, @Rowcount INT;
    SELECT @ii = 1, @EndlessLoop = 10, @Rowcount = 1;
    WHILE @Rowcount > 0 AND @EndlessLoop > 0
      BEGIN
        ;WITH candidates (object_ID, Parent_object_id)
         AS (SELECT sys.objects.object_id, sys.objects.parent_object_id
               FROM sys.objects
                 LEFT OUTER JOIN @DependencyOrder AS Dep 
                   ON Dep.Object_id = objects.object_id
               WHERE Dep.Object_id IS NULL AND type NOT IN ('s', 'sq', 'it'))
        INSERT INTO @DependencyOrder (TheSchema, TheName, Object_id, TheOrder)
        SELECT Object_Schema_Name(c.object_ID), Object_Name(c.object_ID),
          c.object_ID, @ii
          FROM candidates AS c
            INNER JOIN @DependencyOrder AS parent
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
                      INNER JOIN sys.sql_expression_dependencies
                        ON Object_id = referencing_id
                      LEFT OUTER JOIN @DependencyOrder AS ReferedTo
                        ON ReferedTo.Object_id = referenced_id
                    WHERE ReferedTo.Object_id IS NULL
                      AND referenced_id IS NOT NULL 
                  );
        SET @Rowcount = @@RowCount;
        SELECT @ii = @ii + 1, @EndlessLoop = @EndlessLoop - 1;
      END;
    UPDATE @DependencyOrder SET iterations = @ii - 1;
    UPDATE @DependencyOrder
      SET ExternalDependency = ListOfDependencies
      FROM
        (
        SELECT Object_id,
          Stuff(
                 (
                 SELECT ', ' + Coalesce(referenced_server_name + '.', '')
                        + Coalesce(referenced_database_name + '.', '')
                        + Coalesce(referenced_schema_name + '.', '')
                        + referenced_entity_name
                   FROM sys.sql_expression_dependencies AS sed
                   WHERE sed.referencing_id = externalRefs.object_ID
                     AND referenced_database_name IS NOT NULL
                     AND is_ambiguous = 0
                 FOR XML PATH(''), ROOT('i'), TYPE
                 ).value('/i[1]', 'varchar(max)'),1,2,'' ) 
                     AS ListOfDependencies
          FROM @DependencyOrder AS externalRefs
        ) AS f
        INNER JOIN @DependencyOrder AS d
          ON f.Object_id = d.Object_id;
 
    RETURN;
  END;
GO
/****** Object:  UserDefinedFunction [dbo].[DetermineVariant]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DetermineVariant]()

RETURNS NVARCHAR(20)
AS
BEGIN
DECLARE @one TINYINT
DECLARE @two VARCHAR(20)

SET @one = 1
SET @two = '2'

/*SELECT @one + @two AS 'ValueOfAggregate'
,	SQL_VARIANT_PROPERTY(@one + @two,'basetype') AS 'ResultOfExpression'
, SQL_VARIANT_PROPERTY(@one + @two,'precision') AS 'ResultOfPrecision'
, SQL_VARIANT_PROPERTY(@one,'basetype') AS 'DataTypeOf @one'
, SQL_VARIANT_PROPERTY(@one,'precision') AS 'PrecisionOf @one'
, SQL_VARIANT_PROPERTY(@one,'scale') AS 'ScaleOf @one'
, SQL_VARIANT_PROPERTY(@one,'MaxLength') AS 'MaxLengthOf @one'
, SQL_VARIANT_PROPERTY(@one,'Collation') AS 'CollationOf @one'
, SQL_VARIANT_PROPERTY(@two,'basetype') AS 'DataTypeOf @two'
, SQL_VARIANT_PROPERTY(@two,'precision') AS 'PrecisionOf @two'
*/
RETURN @two

END
GO
/****** Object:  UserDefinedFunction [dbo].[HierarchyFromJSON]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   FUNCTION [dbo].[HierarchyFromJSON](@JSONData VARCHAR(MAX))
RETURNS @ReturnTable TABLE
  (
  Element_ID INT, /* internal surrogate primary key gives the order of parsing and the list order */
  SequenceNo INT NULL, /* the sequence number in a list */
  Parent_ID INT, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
  Object_ID INT, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
  Name NVARCHAR(2000), /* the name of the object */
  StringValue NVARCHAR(MAX) NOT NULL, /*the string representation of the value of the element. */
  ValueType VARCHAR(10) NOT NULL /* the declared type of the value represented as a string in StringValue*/
  )
AS
  BEGIN
    DECLARE @ii INT = 1, @rowcount INT = -1;
    DECLARE @null INT =
      0, @string INT = 1, @int INT = 2, @boolean INT = 3, @array INT = 4, @object INT = 5;
 
    DECLARE @TheHierarchy TABLE
      (
      element_id INT IDENTITY(1, 1) PRIMARY KEY,
      sequenceNo INT NULL,
      Depth INT, /* effectively, the recursion level. =the depth of nesting*/
      parent_ID INT,
      Object_ID INT,
      NAME NVARCHAR(2000),
      StringValue NVARCHAR(MAX) NOT NULL,
      ValueType VARCHAR(10) NOT NULL
      );
 
    INSERT INTO @TheHierarchy
      (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
      SELECT 1, @ii, NULL, 0, 'root', @JSONData, 'object';
 
    WHILE @rowcount <> 0
      BEGIN
        SELECT @ii = @ii + 1;
 
        INSERT INTO @TheHierarchy
          (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
          SELECT Scope_Identity(), @ii, Object_ID,
            Scope_Identity() + Row_Number() OVER (ORDER BY parent_ID), [Key], Coalesce(o.Value,'null'),
            CASE o.Type WHEN @string THEN 'string'
              WHEN @null THEN 'null'
              WHEN @int THEN 'int'
              WHEN @boolean THEN 'boolean'
              WHEN @int THEN 'int'
              WHEN @array THEN 'array' ELSE 'object' END
          FROM @TheHierarchy AS m
            CROSS APPLY OpenJson(StringValue) AS o
          WHERE m.ValueType IN
        ('array', 'object') AND Depth = @ii - 1;
 
        SELECT @rowcount = @@RowCount;
      END;
 
    INSERT INTO @ReturnTable
      (Element_ID, SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType)
      SELECT element_id, element_id - sequenceNo, parent_ID,
        CASE WHEN ValueType IN ('object', 'array') THEN Object_ID ELSE NULL END,
        CASE WHEN NAME LIKE '[0-9]%' THEN NULL ELSE NAME END,
        CASE WHEN ValueType IN ('object', 'array') THEN '' ELSE StringValue END, ValueType
      FROM @TheHierarchy;
 
    RETURN;
  END;
GO
/****** Object:  UserDefinedFunction [dbo].[JSONHierarchy]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[JSONHierarchy]
  (
  @JSONData VARCHAR(MAX),
  @Parent_object_ID INT = NULL,
  @MaxObject_id INT = 0,
  @type INT = null
  )
RETURNS @ReturnTable TABLE
  (
  Element_ID INT IDENTITY(1, 1) PRIMARY KEY, /* internal surrogate primary key gives the order of parsing and the list order */
  SequenceNo INT NULL, /* the sequence number in a list */
  Parent_ID INT, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
  Object_ID INT, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
  Name NVARCHAR(2000), /* the name of the object */
  StringValue NVARCHAR(MAX) NOT NULL, /*the string representation of the value of the element. */
  ValueType VARCHAR(10) NOT NULL /* the declared type of the value represented as a string in StringValue*/
  )
AS
  BEGIN
	--the types of JSON
    DECLARE @null INT =
      0, @string INT = 1, @int INT = 2, @boolean INT = 3, @array INT = 4, @object INT = 5;
 
    DECLARE @OpenJSONData TABLE
      (
      sequence INT IDENTITY(1, 1),
      [key] VARCHAR(200),
      Value VARCHAR(MAX),
      type INT
      );
 
    DECLARE @key VARCHAR(200), @Value VARCHAR(MAX), @Thetype INT, @ii INT, @iiMax INT,
      @NewObject INT, @firstchar CHAR(1);
 
    INSERT INTO @OpenJSONData
      ([key], Value, type)
      SELECT [Key], Value, Type FROM OpenJson(@JSONData);
	SELECT @ii = 1, @iiMax = Scope_Identity()
    SELECT  @Firstchar= --the first character to see if it is an object or an array
	  Substring(@JSONData,PatIndex('%[^'+CHAR(0)+'- '+CHAR(160)+']%',' '+@JSONData+'!' collate SQL_Latin1_General_CP850_Bin)-1,1)
    IF @type IS NULL AND @firstchar IN ('[','{')
		begin
	   INSERT INTO @returnTable
	    (SequenceNo,Parent_ID,Object_ID,Name,StringValue,ValueType)
			SELECT 1,NULL,1,'-','', 
			   CASE @firstchar WHEN '[' THEN 'array' ELSE 'object' END
        SELECT @type=CASE @firstchar WHEN '[' THEN @array ELSE @object END,
		@Parent_object_ID  = 1, @MaxObject_id=Coalesce(@MaxObject_id, 1) + 1;
		END       
	WHILE(@ii <= @iiMax)
      BEGIN
	  --OpenJSON renames list items with 0-nn which confuses the consumers of the table
        SELECT @key = CASE WHEN [key] LIKE '[0-9]%' THEN NULL ELSE [key] end , @Value = Value, @Thetype = type
          FROM @OpenJSONData
          WHERE sequence = @ii;
 
        IF @Thetype IN (@array, @object) --if we have been returned an array or object
          BEGIN
            SELECT @MaxObject_id = Coalesce(@MaxObject_id, 1) + 1;
			--just in case we have an object or array returned
            INSERT INTO @ReturnTable --record the object itself
              (SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType)
              SELECT @ii, @Parent_object_ID, @MaxObject_id, @key, '',
                CASE @Thetype WHEN @array THEN 'array' ELSE 'object' END;
 
            INSERT INTO @ReturnTable --and return all its children
              (SequenceNo, Parent_ID, Object_ID, [Name],  StringValue, ValueType)
			  SELECT SequenceNo, Parent_ID, Object_ID, 
				[Name],
				Coalesce(StringValue,'null'),
				ValueType
              FROM dbo.JSONHierarchy(@Value, @MaxObject_id, @MaxObject_id, @type);
			SELECT @MaxObject_id=Max(Object_id)+1 FROM @ReturnTable
		  END;
        ELSE
          INSERT INTO @ReturnTable
            (SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType)
            SELECT @ii, @Parent_object_ID, NULL, @key, Coalesce(@Value,'null'),
              CASE @Thetype WHEN @string THEN 'string'
                WHEN @null THEN 'null'
                WHEN @int THEN 'int'
                WHEN @boolean THEN 'boolean' ELSE 'int' END;
 
        SELECT @ii = @ii + 1;
      END;
 
    RETURN;
  END;

GO
/****** Object:  UserDefinedFunction [dbo].[Proper]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Function [dbo].[Proper](@Data VarChar(8000))
Returns VarChar(8000)
As
Begin
  Declare @Position Int

  Select @Data = Stuff(Lower(@Data), 1, 1, Upper(Left(@Data, 1))),
         @Position = PatIndex('%[^a-zA-Z][a-z]%', @Data COLLATE Latin1_General_Bin)

  While @Position > 0
    Select @Data = Stuff(@Data, @Position, 2, Upper(SubString(@Data, @Position, 2))),
           @Position = PatIndex('%[^a-zA-Z][a-z]%', @Data COLLATE Latin1_General_Bin)

  Return @Data
End
GO
/****** Object:  UserDefinedFunction [dbo].[RemovePatternFromString]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- REPLACES SPECIAL CHARACTERS FROM STRINGS
CREATE   FUNCTION [dbo].[RemovePatternFromString](@STRINGVALUE VARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @PATTERN NVARCHAR(128) = '%[$&.!?(]%'
    DECLARE @POS INT = PATINDEX(@PATTERN, @STRINGVALUE)
    WHILE @POS > 0 BEGIN
        SET @STRINGVALUE = STUFF(@STRINGVALUE, @POS, 1, '_')
        SET @POS = PATINDEX(@PATTERN, @STRINGVALUE)
    END
	SET @STRINGVALUE = REPLACE(REPLACE(REPLACE(@STRINGVALUE , ')',''),'[',''), ']', '')
    RETURN @STRINGVALUE
END
GO
/****** Object:  UserDefinedFunction [dbo].[ToProperCase]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ToProperCase](@string VARCHAR(255)) RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @i INT           -- index
  DECLARE @l INT           -- input length
  DECLARE @c NCHAR(1)      -- current char
  DECLARE @f INT           -- first letter flag (1/0)
  DECLARE @o VARCHAR(255)  -- output string
  DECLARE @w VARCHAR(10)   -- characters considered as white space

  SET @w = '[' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(160) + ' ' + ']'
  SET @i = 1
  SET @l = LEN(@string)
  SET @f = 1
  SET @o = ''

  WHILE @i <= @l
  BEGIN
    SET @c = SUBSTRING(@string, @i, 1)
    IF @f = 1 
    BEGIN
     SET @o = @o + @c
     SET @f = 0
    END
    ELSE
    BEGIN
     SET @o = @o + LOWER(@c)
    END

    IF @c LIKE @w SET @f = 1

    SET @i = @i + 1
  END

  RETURN @o
END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_Get_ObjectDefinition]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- TEST
-- SELECT PERFTEST.udf_Get_ObjectDefinition('[PERFTEST].[sp_Create_MetricsLog]', 'P')
-- SELECT PERFTEST.udf_Get_ObjectDefinition('[PERFTEST].[sp_Create_MetricsLog]', 'SQL_STORED_PROCEDURE')
-- SELECT PERFTEST.udf_Get_ObjectDefinition('[PERFTEST].[sp_Create_MetricsLog]', NULL)
-- SELECT PERFTEST.udf_Get_ObjectDefinition('[PERFTEST].[sp_Create_MetricsLog]', '')
-- SELECT PARSENAME('[PERFTEST].[sp_Create_MetricsLog]', 1)
CREATE   FUNCTION [dbo].[udf_Get_ObjectDefinition]
(
	@ObjectName SYSNAME
,	@ObjectType VARCHAR(128) = NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Object_Definition VARCHAR(MAX)

	-- Declare the return variable here
	IF(@ObjectType IS NULL OR LEN(@ObjectType) = 0)
	BEGIN
		SET @Object_Definition = (SELECT OBJECT_DEFINITION (OBJECT_ID(@ObjectName)))
	END

	ELSE
	BEGIN
		IF(LEN(@ObjectType) <=2 )
		BEGIN
			SET @Object_Definition = (
				SELECT 
					object_definition(o.object_id)
				FROM 
					sys.objects AS o
				WHERE 
					o.type = @ObjectType
				AND
					o.name = PARSENAME(@ObjectName, 1)
			)
		END

		ELSE
		BEGIN
			SET @Object_Definition = (
				SELECT 
					object_definition(o.object_id)
				FROM 
					sys.objects AS o
				WHERE 
					o.type_desc = @ObjectType
				AND
					o.name = PARSENAME(@ObjectName, 1)
				)
		END
	END



	-- Add the T-SQL statements to compute the return value here
	/*
	SELECT object_definition(object_id) as [Proc Definition]
	FROM sys.objects 
	WHERE type='P'

	SELECT definition 
	FROM sys.sql_modules 
	WHERE object_id = OBJECT_ID('yourSchemaName.yourStoredProcedureName')

	SELECT
		sch.name+'.'+ob.name AS       [Object], 
		ob.create_date, 
		ob.modify_date, 
		ob.type_desc, 
		mod.definition
	FROM 
     sys.objects AS ob
     LEFT JOIN sys.schemas AS sch ON
            sch.schema_id = ob.schema_id
     LEFT JOIN sys.sql_modules AS mod ON
            mod.object_id = ob.object_id
	WHERE mod.definition IS NOT NULL --Selects only objects with the definition (code)
	
	SELECT definition
	FROM sys.sql_modules
	WHERE object_id = object_id('uspGetAlbumsByArtist');

	EXEC sp_helptext 'uspGetAlbumsByArtist';



	SELECT ROUTINE_DEFINITION, *
	FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINE_NAME = 'uspGetAlbumsByArtist';
	*/

	-- Return the result of the function
	RETURN @Object_Definition

END

GO
/****** Object:  UserDefinedFunction [dbo].[udf_Get_TableRowCount]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- TEST
-- SELECT PERFTEST.udf_Get_TableRowCount('[PERFTEST].[MetricsLog]')
-- SELECT PERFTEST.udf_Get_TableRowCount('PERFTEST.MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('PERFTEST.MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('')
-- SELECT PERFTEST.udf_Get_TableRowCount(NULL)
-- SELECT PARSENAME('[PERFTEST].[sp_Create_MetricsLog]', 1)
CREATE   FUNCTION [dbo].[udf_Get_TableRowCount]
(
	@TableName SYSNAME
)
RETURNS INT
AS
BEGIN
	DECLARE @Table_RowCount INT = (
		SELECT 
			SUM(P.rows)

			--SELECT *
		FROM
			sys.tables t
		INNER JOIN 
			sys.schemas s 
			ON s.schema_id = t.schema_id
		INNER JOIN 
			sys.partitions p 
			ON t.object_id = p.object_id
		INNER JOIN 
			sys.indexes i 
			ON p.object_id = i.object_id
			AND p.index_id = i.index_id
			AND i.index_id < 2
		WHERE
			t.name = PARSENAME(@TableName, 1)
		GROUP BY 
			t.object_id
			, t.name
			, S.name
	)


	-- Return the result of the function
	RETURN @Table_RowCount

END

GO
/****** Object:  UserDefinedFunction [dyna].[GetObjectReference]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   FUNCTION [dyna].[GetObjectReference](
	@ServerName			SYSNAME = NULL
,	@DatabaseName		SYSNAME = NULL
,	@SchemaName			SYSNAME = NULL
,	@ObjectName			SYSNAME = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT @ObjectName
	))
END
GO
/****** Object:  UserDefinedFunction [dyna].[GetQualifiedObjectReference]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   FUNCTION [dyna].[GetQualifiedObjectReference](
	@ServerName			SYSNAME = NULL
,	@DatabaseName		SYSNAME = NULL
,	@SchemaName			SYSNAME = NULL
,	@ObjectName			SYSNAME = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT QUOTENAME(@ObjectName)
	))
END
GO
/****** Object:  UserDefinedFunction [inout].[uftReadfileAsTable]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inout].[uftReadfileAsTable]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS 
@File TABLE
(
[LineNo] int identity(1,1), 
line varchar(8000)) 

AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String VARCHAR(8000),
		@YesOrNo INT

select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
	INSERT INTO @file(line) SELECT @String
	END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	insert into @File(line) select @strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [string].[CamelCaseFieldName_To_SpaceInclusiveNames]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----USE [InfoMart]
----GO

----/****** Object:  Schema [INTEGRATION]    Script Date: 2019/11/14 4:26:01 PM ******/
----CREATE SCHEMA [INTEGRATION]
----GO
----/****** Object:  UserDefinedFunction [dbo].[CamelCaseFieldName_To_SpaceInclusiveNames]    Script Date: 2019/11/14 4:26:01 PM ******/
----SET ANSI_NULLS ON
----GO
----SET QUOTED_IDENTIFIER ON
----GO

CREATE   FUNCTION [string].[CamelCaseFieldName_To_SpaceInclusiveNames] (
    @fieldName VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE
		@i INT, @j INT
	,   @cp NCHAR, @c0 NCHAR, @c1 NCHAR
	,   @returnValue VARCHAR(MAX)

	SELECT
		@i = 1
	,   @j = LEN(@fieldName)
	,   @returnValue = ''

	WHILE @i <= @j
	BEGIN
		SELECT
			@cp = SUBSTRING(@fieldName,@i-1,1)
		,   @c0 = SUBSTRING(@fieldName,@i+0,1)
		,   @c1 = SUBSTRING(@fieldName,@i+1,1)

		IF (@c0 = UPPER(@c0) COLLATE Latin1_General_CS_AS)
		BEGIN
			IF 
				(@c0 = UPPER(@c0) COLLATE Latin1_General_CS_AS)
			AND 
				(@cp <> UPPER(@cp) COLLATE Latin1_General_CS_AS)
			OR  (
					@c1 <> UPPER(@c1) COLLATE Latin1_General_CS_AS
				AND 
					@cp <> ' '
				AND 
					@c0 <> ' '
				)
		   BEGIN
				SET @returnValue = @returnValue + ' '
		   END -- IF Inner
		END -- IF Outer

		SET @returnValue = @returnValue + @c0
		SET @i = @i + 1

		END -- WHILE

	RETURN @returnValue

END

GO
/****** Object:  UserDefinedFunction [string].[SplitStringIntoColumns]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [string].[SplitStringIntoColumns] (
    @string NVARCHAR(MAX),
    @delimiter CHAR(1)
    )
RETURNS @out_put TABLE (
    [column_id] INT IDENTITY(1, 1) NOT NULL,
    [value] NVARCHAR(MAX)
    )
AS
BEGIN
    DECLARE @value NVARCHAR(MAX),
        @pos INT = 0,
        @len INT = 0

    SET @string = CASE 
            WHEN RIGHT(@string, 1) != @delimiter
                THEN @string + @delimiter
            ELSE @string
            END

    WHILE CHARINDEX(@delimiter, @string, @pos + 1) > 0
    BEGIN
        SET @len = CHARINDEX(@delimiter, @string, @pos + 1) - @pos
        SET @value = SUBSTRING(@string, @pos, @len)

        INSERT INTO @out_put ([value])
        SELECT LTRIM(RTRIM(@value)) AS [column]

        SET @pos = CHARINDEX(@delimiter, @string, @pos + @len) + 1
    END

    RETURN
END
GO
/****** Object:  UserDefinedFunction [string].[udf_get_FieldName_Propercase]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [string].[udf_get_FieldName_Propercase] (
	@FieldName AS SYSNAME
) 
RETURNS VARCHAR(MAX)
BEGIN
    DECLARE @Reset BIT
	DECLARE @Return_Value VARCHAR(MAX)
	DECLARE @i INT
	DECLARE @c CHAR(1)

IF @FieldName IS NULL 
	RETURN NULL

SELECT
    @Reset = 1,
    @i = 1,
    @Return_Value = ''

WHILE (@i <= LEN(@FieldName)) 
	SELECT
		@c = SUBSTRING(@FieldName, @i, 1)
	,	@Return_Value = @Return_Value + 
						CASE
							WHEN
								@Reset = 1 
							THEN
								UPPER(@c) 
							ELSE
								LOWER(@c) 
						END
	,	@Reset = 
				CASE
					WHEN
						@c LIKE '[a-zA-Z]' 
					THEN
						0 
					ELSE
						1 
				END
	,	@i = @i + 1 


RETURN REPLACE(@Return_Value , '_', ' ')

END

GO
/****** Object:  UserDefinedFunction [string].[udf_get_PresentationView_CreateOrAlter_Statement]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =========================================================================
-- Author:      Emile Fraser
-- Create Date: 2019/11/13
-- Last Update: 2019/11/13
-- Description: Returns the code converting Dim/Facts into pres views
-- ==========================================================================
CREATE   FUNCTION [string].[udf_get_PresentationView_CreateOrAlter_Statement](
	@schemaName AS SYSNAME
,	@viewName AS SYSNAME

)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lf CHAR(1) = CHAR(13)
	DECLARE @tab CHAR(1) = CHAR(9)

	DECLARE @fullViewName SYSNAME =  QUOTENAME(@schemaName)  + '.' +  QUOTENAME(@viewName)
	DECLARE @fullPresentationViewName SYSNAME = (SELECT REPLACE(@fullViewName, 'vw_', 'vw_pres_'))
	DECLARE @sqlCommand VARCHAR(MAX) = ''
	DECLARE @sqlColumns VARCHAR(MAX) = ''
	DECLARE @sqlFrom VARCHAR(MAX) = ''
	DECLARE @sqlWhere VARCHAR(MAX) = ''
	DECLARE @sqlStatement VARCHAR(MAX) = ''


	/*************************
		  COMMAND BLOCK
	*************************/
	SET @sqlCommand = 'CREATE OR ALTER VIEW ' + @fullPresentationViewName + @lf
	SET @sqlCommand = @sqlCommand + 'AS' + @lf
	SET @sqlCommand = @sqlCommand + 'SELECT' + @lf

	/*************************
		  COLUMNS BLOCK
	*************************/
	SELECT @sqlColumns = 		
		@sqlColumns + @tab 
						+ QUOTENAME(c.name) + ' AS ' 
						+ QUOTENAME(REPLACE(IM.udf_get_FieldName_Propercase(dbo.CamelCaseFieldName_To_SpaceInclusiveNames(c.name)),'  ',' '))
						+ @lf + IIF(vc.TotalColumns != c.column_id,  ',', '')
	FROM 
		sys.views AS v
	INNER JOIN 
		sys.schemas AS s
	ON 
		s.schema_id = v.schema_id
	INNER JOIN 
		sys.columns as c
	ON 
		v.object_id = c.object_id
	INNER JOIN (	  
			SELECT 
				object_id
			,	COUNT(1) AS TotalColumns
			FROM 
				sys.columns 
			WHERE 
				object_id = object_id(@fullViewName)
			GROUP BY 
				object_id
	) AS vc
	ON
		vc.object_id = v.object_id

	/*************************
			FROM BLOCK
	*************************/
	SET @sqlFrom = 'FROM ' + @lf + @tab + @fullViewName + @lf

	SET @sqlStatement = @sqlCommand + @sqlColumns + @sqlFrom + @sqlWhere
		
	RETURN @sqlStatement

END

GO
/****** Object:  Table [dba].[StorageStats_Batch]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_Batch](
	[BatchID] [int] IDENTITY(1,1) NOT NULL,
	[HasStorageStatsRun_Machine] [bit] NOT NULL,
	[HasStorageStatsRun_Database] [bit] NOT NULL,
	[HasStorageStatsRun_DatabaseFile] [bit] NOT NULL,
	[HasStorageStatsRun_Object] [bit] NOT NULL,
	[HasStorageStatsRun_Index] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dba].[StorageStats_Index]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_Index](
	[StorageStats_IndexID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[index_type] [tinyint] NOT NULL,
	[type_desc] [nvarchar](60) NULL,
	[fill_factor] [tinyint] NULL,
	[is_unique] [bit] NULL,
	[is_padded] [bit] NULL,
	[size_index_total] [float] NULL,
	[size_index_used] [float] NULL,
	[size_index_unused] [float] NULL,
	[table_id] [int] NOT NULL,
	[schema_id] [int] NOT NULL,
	[database_id] [int] NOT NULL,
	[CreatedDT] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dba].[vw_StorageStats_Index]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW  [dba].[vw_StorageStats_Index]
AS
SELECT 
	  ss_idx.[BatchID] AS [Batch ID]
      ,[Index ID] = ss_idx.[index_id]
	  ,[Index Name] = idx.[name]
      ,[Index Type] = ss_idx.[index_type]
      ,[Index Description] = ss_idx.[type_desc]
      ,ss_idx.[fill_factor] AS [Fill Factor]
      ,ss_idx.[is_unique] AS [Is Unique]
      ,ss_idx.[is_padded] AS [Is Padded]
      ,ss_idx.[size_index_total] / 1024  AS [Size Index Total (MB)] 
      ,ss_idx.[size_index_used]  / 1024 AS [Size Index Used (MB)]
      ,ss_idx.[size_index_unused]  / 1024  AS [Size Index Unused (MB)]
      ,[Table ID] = ss_idx.[table_id] 
	  ,t.[name] AS [Table Name]
      ,[Schema ID] = ss_idx.[schema_id]
	  ,[Schema Name] = sch.[name]
      ,[Database ID] = ss_idx.[database_id]
	  ,[Database Name] = db.[name]
  FROM 
	[dba].[StorageStats_Batch] AS bat
  LEFT JOIN [dba].[StorageStats_Index] AS ss_idx
  	ON ss_idx.BatchID = bat.BatchID
  LEFT JOIN sys.indexes AS idx
  ON idx.index_id = ss_idx.index_id
  LEFT JOIN sys.databases AS db
  ON db.database_id = ss_idx.database_id
  LEFT JOIN sys.schemas AS sch
  ON sch.schema_id = ss_idx.schema_id
  LEFT JOIN sys.tables AS t
  ON t.object_id = ss_idx.table_id
GO
/****** Object:  Table [dba].[StorageStats_DatabaseFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_DatabaseFile](
	[StorageStats_DatabaseFileID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[file_id] [int] NULL,
	[file_guid] [uniqueidentifier] NULL,
	[file_name] [nvarchar](128) NULL,
	[file_type] [int] NULL,
	[file_type_desc] [varchar](128) NULL,
	[file_classification] [varchar](128) NULL,
	[file_path] [nvarchar](max) NULL,
	[file_drive] [nvarchar](10) NULL,
	[size_file] [bigint] NULL,
	[max_size] [bigint] NULL,
	[growth] [bigint] NULL,
	[database_id] [int] NOT NULL,
	[SqlServerInstanceName] [nvarchar](128) NULL,
	[MachineName] [sysname] NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dba].[vw_StorageStats_DatabaseFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    VIEW [dba].[vw_StorageStats_DatabaseFile]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	dbf.[file_id] AS [File ID]
,	dbf.[file_name] AS [File Name]
,	dbf.[file_type_desc] AS [File Type Description]
,	dbf.[file_classification] AS [File Classification]
,	dbf.[file_path] AS [File Path]
,	REPLACE(dbf.[file_drive], ':', '') AS [File Drive]
,	dbf.[size_file] / 1024  AS [File Size (MB)]
,	dbf.[max_size] AS [Max Size]
,	dbf.[growth] AS [Growth (MB)]
,	dbf.[database_id] AS [Database ID]
,	[SqlServerInstanceName] AS [Database Instance Name]
,	[MachineName] AS [Server Name]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_DatabaseFile] AS dbf
	ON dbf.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
/****** Object:  Table [dba].[StorageStats_Database]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_Database](
	[StorageStats_Database_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[database_id] [int] NOT NULL,
	[size_database] [int] NULL,
	[state] [tinyint] NULL,
	[state_desc] [nvarchar](60) NULL,
	[recovery_model] [tinyint] NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[is_auto_update_stats_on] [bit] NULL,
	[is_auto_shrink_on] [bit] NULL,
	[is_ansi_padding_on] [bit] NULL,
	[is_fulltext_enabled] [bit] NULL,
	[is_query_store_on] [bit] NULL,
	[is_temporal_history_retention_enabled] [bit] NULL,
	[SqlServerInstanceName] [nvarchar](128) NULL,
	[MachineName] [nvarchar](128) NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dba].[vw_StorageStats_Database]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    VIEW [dba].[vw_StorageStats_Database]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	db.[database_id] AS [Database ID]
,	d.[name] AS [Database Name]
,	db.[size_database] * 8 / 1024 AS [Database Size (MB)]
,	db.[state_desc] AS [State]
,	db.[recovery_model_desc] AS [Recovery Model]
,	IIF(db.[is_auto_create_stats_on] = 1 , 'Yes', 'No') AS [Is Auto Create Stats On]
,	IIF(db.[is_auto_update_stats_on]= 1 , 'Yes', 'No') AS [Is Auto Update Stats On]
,	IIF(db.[is_auto_shrink_on]= 1 , 'Yes', 'No') AS [Is Auto Shrink On]
,	IIF(db.[is_ansi_padding_on]= 1 , 'Yes', 'No') AS [Is ANSI Padding On]
,	IIF(db.[is_fulltext_enabled]= 1 , 'Yes', 'No') AS [Is Fulltext On]
,	IIF(db.[is_query_store_on]= 1 , 'Yes', 'No') AS [Is Query Store On]
,	IIF(db.[is_temporal_history_retention_enabled]= 1 , 'Yes', 'No') AS [Is Temporal History ON]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_Database] AS db
	ON db.BatchID = bat.BatchID
INNER JOIN 
	sys.databases AS d
	ON d.database_id = db.database_id
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
/****** Object:  Table [dba].[StorageStats_Server]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_Server](
	[StorageStats_DatabaseFile_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[drive_mountpoint] [nvarchar](100) NULL,
	[drive_name] [nvarchar](100) NULL,
	[drive_type] [nvarchar](100) NULL,
	[size_drive_total] [bigint] NULL,
	[size_drive_used] [bigint] NULL,
	[size_drive_unused] [bigint] NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dba].[vw_StorageStats_Server]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    VIEW [dba].[vw_StorageStats_Server]
AS
SELECT 
	bat.BatchID AS [Batch ID]
,	CONVERT(CHAR(1), REPLACE(ser.drive_mountpoint, ':\','')) AS [Drive MountPoint]
,	ser.drive_name AS [Drive Name]
,	ser.drive_type AS [Drive Type]
,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS [ServerName]
,	ser.size_drive_total / 1024 / 1024 AS [Drive Size Total (MB)]
,	ser.size_drive_used  / 1024 / 1024 AS [Drive Size Used (MB)]
,	ser.size_drive_unused / 1024 / 1024 AS [Drive Size Unused (MB)]
,	IIF(batcurr.CurrentBatchID IS NULL, 'No', 'Yes') AS [Is Current Batch]
FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
	[dba].[StorageStats_Server] AS ser
	ON ser.BatchID = bat.BatchID
LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
/****** Object:  View [dba].[vw_StorageStats_Batch]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dba].[vw_StorageStats_Batch]
AS
SELECT  bat.[BatchID] AS [Batch ID]
      , bat.[HasStorageStatsRun_Machine] AS [Has ServerStats Run]
      , bat.[HasStorageStatsRun_Database] AS [Has DatabaseStats Run]
      , bat.[HasStorageStatsRun_DatabaseFile] AS [Has DatabaseFileStats Run]
      , bat.[HasStorageStatsRun_Object] AS [Has ObjectStats Run]
      , bat.[HasStorageStatsRun_Index] AS [Has IndexStats Run]
      ,CONVERT(DATE, bat.[CreatedDT]) AS [Batch Date]
	 ,	IIF(batcurr.CurrentBatchID IS NULL, 'No', 'Yes') AS [Is Current Batch]
  FROM [dba].[StorageStats_Batch] AS bat
  LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
/****** Object:  Table [dba].[StorageStats_Object]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dba].[StorageStats_Object](
	[StorageStats_Object_ID] [int] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NOT NULL,
	[object_id] [int] NOT NULL,
	[object_type] [char](2) NULL,
	[object_type_desc] [nvarchar](60) NULL,
	[large_value_types_out_of_row] [bit] NULL,
	[durability] [tinyint] NULL,
	[durability_desc] [nvarchar](60) NULL,
	[temporal_type] [tinyint] NULL,
	[temporal_type_desc] [nvarchar](60) NULL,
	[is_external] [bit] NOT NULL,
	[history_retention_period] [int] NULL,
	[column_count] [int] NOT NULL,
	[row_count] [bigint] NULL,
	[text_in_row_limit] [int] NULL,
	[size_table_total] [bigint] NULL,
	[size_table_used] [bigint] NULL,
	[size_table_unused] [bigint] NULL,
	[allocation_type] [tinyint] NOT NULL,
	[allocation_type_desc] [nvarchar](60) NULL,
	[schema_id] [int] NULL,
	[database_id] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dba].[vw_StorageStats_Object]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     VIEW  [dba].[vw_StorageStats_Object]
AS
SELECT 
	  ss.[BatchID] AS [Batch ID]
      ,	db.database_id AS [Database ID]
	  ,	[Database Name] = db.name
	  ,	[Object ID] = ss.[object_id]
	  ,	[Object Name] = obj.[name]
      ,	1.00 * [size_table_total] / 1024 AS [Object Size Total (MB)] 
      ,	1.00 * 	[size_table_used] / 1024 AS [Object Size Used (MB)] 
      ,	1.00 * 	[size_table_unused] / 1024 AS [Object Size Unused (MB)] 
  FROM 
	[dba].[StorageStats_Batch] AS bat
LEFT JOIN 
[dba].[StorageStats_Object] AS ss
ON ss.BatchID = bat.BatchID  
LEFT JOIN sys.tables AS tab
ON tab.object_id = ss.object_id


LEFT JOIN sys.objects AS obj
  ON obj.object_id = ss.object_id

  LEFT JOIN sys.databases AS db
  ON db.database_id = ss.database_id
  LEFT JOIN sys.schemas AS sch
  ON sch.schema_id = ss.schema_id
  LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [dba].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID
  WHERE
	ss.object_type = 'U'
	AND tab.object_id is not null
GO
/****** Object:  UserDefinedFunction [dbo].[GetNums]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetNums](@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO
/****** Object:  UserDefinedFunction [dbo].[GetRowCountsFromPartitions]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[GetRowCountsFromPartitions] (@SchemaName SYSNAME, @StageOfLoad NVARCHAR(128))
RETURNS TABLE
AS
RETURN
	SELECT
			[StageOfLoad]	= @StageOfLoad
		  , [EntityName]	= tbl.[name]
		  , [DatabaseName]	= DB_NAME()
		  , [SchemaName]	= sch.[name]
		  , [TableName]		= tbl.[name]
		  , [RowCount]		= SUM(par.[rows]) 
		FROM
			[sys].[tables] AS tbl
		INNER JOIN
			[sys].[schemas] AS sch
			ON sch.schema_id = tbl.schema_id
		INNER JOIN
			[sys].[partitions] AS par
			ON tbl.object_id = par.object_id
		INNER JOIN
			[sys].[indexes] AS idx
			ON par.object_id = idx.object_id 
			AND par.[index_id] = idx.[index_id]
		WHERE 
			idx.[index_id] < 2 
		AND 
			sch.[name] = @SchemaName
		GROUP BY
			tbl.object_id
		  , tbl.[name]
		  , sch.[name]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSchemaRowCountFromPartitions]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[GetSchemaRowCountFromPartitions] (@SchemaName SYSNAME, @StageOfLoad NVARCHAR(128))
RETURNS TABLE
AS
RETURN
	SELECT
			[StageOfLoad]	= @StageOfLoad
		  , [EntityName]	= tbl.[name]
		  , [DatabaseName]	= DB_NAME()
		  , [SchemaName]	= sch.[name]
		  , [TableName]		= tbl.[name]
		  , [RowCount]		= SUM(par.[rows]) 
		FROM
			[sys].[tables] AS tbl
		INNER JOIN
			[sys].[schemas] AS sch
			ON sch.schema_id = tbl.schema_id
		INNER JOIN
			[sys].[partitions] AS par
			ON tbl.object_id = par.object_id
		INNER JOIN
			[sys].[indexes] AS idx
			ON par.object_id = idx.object_id 
			AND par.[index_id] = idx.[index_id]
		WHERE 
			idx.[index_id] < 2 
		AND 
			sch.[name] = @SchemaName
		GROUP BY
			tbl.object_id
		  , tbl.[name]
		  , sch.[name]
GO
/****** Object:  UserDefinedFunction [dbo].[SeeAccessControlChanges]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE FUNCTION [dbo].[SeeAccessControlChanges]
  /**
  Summary: >
    This function gives you a list
    of security events concerning users, roles and logins
    from the default trace
  Author: Phil Factor
  Date: 04/10/2018
  Examples:
     - Select * from dbo.SeeAccessControlChanges(DateAdd(day,-1,SysDateTime()),SysDateTime())
  columns: datetime_local, action, data, hostname, ApplicationName, LoginName, traceName, spid, EventClass, objectName, rolename, TargetLoginName, category_id, ObjectType 
  Returns: >
        datetime_local datetime2(7)
        action nvarchar(816)
        data ntext
        hostname nvarchar(256)
        ApplicationName nvarchar(256)
        LoginName nvarchar(256)
        traceName nvarchar(128)
        spid int
        EventClass int
        objectName nvarchar(256)
        rolename nvarchar(256)
        TargetLoginName nvarchar(256)
        category_id smallint
        ObjectType nvarchar(128)
          **/
    (
    @Start DATETIME2,--the start of the period
    @finish DATETIME2--the end of the period
    )
  RETURNS TABLE
   --WITH ENCRYPTION|SCHEMABINDING, ..
  AS
  RETURN
  select * from sys.objects
  /*
    (
    SELECT 
        CONVERT(
          DATETIME2,
         SWITCHOFFSET(CONVERT(datetimeoffset, StartTime), DATENAME(TzOffset, SYSDATETIMEOFFSET()))
               )  AS datetime_local, 'User '+Coalesce( LoginName+ ' ','unknown ')+ 
        CASE EventSubclass --interpret the subclass for these traces
          WHEN 1 THEN 'added ' WHEN 2 THEN 'dropped ' WHEN 3 THEN 'granted database access for ' 
          WHEN 4 THEN 'revoked database access from ' ELSE 'did something to ' END+ Coalesce(TargetLoginName,'') 
        + Coalesce( CASE EventSubclass WHEN 1 THEN ' to object ' ELSE ' from object ' end+objectname, '') AS action,
        Coalesce(TextData,'') AS [data], hostname, ApplicationName, LoginName, TE.name AS traceName, spid, 
        EventClass, objectName, rolename, TargetLoginName, TE.category_id, 
      SysTSV.subclass_name AS ObjectType
       FROM::fn_trace_gettable(--just use the latest trace
           (SELECT TOP 1 traces.path FROM sys.traces 
              WHERE traces.is_default = 1), DEFAULT) AS DT
        LEFT OUTER JOIN sys.trace_events AS TE
          ON DT.EventClass = TE.trace_event_id
        LEFT OUTER JOIN sys.trace_subclass_values AS SysTSV
          ON DT.EventClass = SysTSV.trace_event_id
         AND DT.ObjectType = SysTSV.subclass_value
      WHERE StartTime BETWEEN @start AND @finish
      AND TargetLoginName IS NOT NULL
    )
	*/
GO
/****** Object:  UserDefinedFunction [dbo].[SeeDatabaseObjectChanges]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE    FUNCTION [dbo].[SeeDatabaseObjectChanges]


  /**
  Summary: >
    This function gives you a list
    of database object changes that happened between
    the two dates, taken from the default trace
  Author: Phil Factor
  Date: 04/10/2018
  Examples:
     - Select * from dbo.SeeDatabaseObjectChanges(DateAdd(day,-1,SysDateTime()),SysDateTime())
  Columns: datetime_local, action, databaseID, TransactionID, Hostname, ApplicationName, LoginName, spid, objectid 
  Returns: >
        datetime_local datetime
        action nvarchar(4000)
        databaseID int
        TransactionID bigint
        Hostname nvarchar(256)
        ApplicationName nvarchar(256)
        LoginName nvarchar(256)
        spid int
        objectid int
          **/
    (
    @Start DATETIME2,--the start of the period
    @finish DATETIME2--the end of the period
    )
  RETURNS TABLE
   --WITH ENCRYPTION|SCHEMABINDING, ..
  AS
  RETURN
	select * from sys.objects

  /*
    (
      SELECT     
        CONVERT(
          DATETIME2,
         SWITCHOFFSET(CONVERT(datetimeoffset, StartTime), DATENAME(TzOffset, SYSDATETIMEOFFSET()))
               )  AS datetime_local, 
           'User '+Coalesce(SessionLoginName,loginName,'') +' '+ Replace(name, 'Object:','')
               +Coalesce(' '+objtype,'')+' '+ Coalesce(DatabaseName+'.'+ObjectName,databasename) AS action,
        databaseID, TransactionID, Hostname, ApplicationName, LoginName, spid,objectid
       FROM::fn_trace_gettable(--just use the latest trace
           (SELECT TOP 1 traces.path FROM sys.traces 
              WHERE traces.is_default = 1), DEFAULT) AS DT
        LEFT OUTER JOIN sys.trace_events AS TE
          ON DT.EventClass = TE.trace_event_id
        LEFT OUTER JOIN sys.trace_subclass_values AS SysTSV
          ON DT.EventClass = SysTSV.trace_event_id
         AND DT.ObjectType = SysTSV.subclass_value
          LEFT OUTER JOIN
        (
     VALUES(8259, 'Check Constraint'),( 8260, 'Default (constraint or standalone)'),( 8262, 'Foreign-key Constraint'),( 8272, 'Stored Procedure'),
     ( 8274, 'Rule'),( 8275, 'System Table'),( 8276, 'Trigger on Server'),( 8277, 'User Table'),( 8278, 'View'),
     ( 8280, 'Extended Stored Procedure'),(16724, 'CLR Trigger'),(16964, 'Database'),(16975, 'Object'),(17222, 'FullText Catalog'),
     (17232, 'CLR Stored Procedure'),(17235, 'Schema'),(17475, 'Credential'),(17491, 'DDL Event'),(17741, 'Management Event'),
     (17747, 'Security Event'),(17749, 'User Event'),(17985, 'CLR Aggregate Function'),(17993, 'Inline Table-valued SQL Function'),
     (18000, 'Partition Function'),(18002, 'Replication Filter Procedure'),(18004, 'Table-valued SQL Function'),(18259, 'Server Role'),
     (18263, 'Microsoft Windows Group'),(19265, 'Asymmetric Key'),(19277, 'Master Key'),(19280, 'Primary Key'),(19283, 'ObfusKey'),
     (19521, 'Asymmetric Key Login'),(19523, 'Certificate Login'),(19538, 'Role'),(19539, 'SQL Login'),(19543, 'Windows Login'),
     (20034, 'Remote Service Binding'),(20036, 'Event Notification on Database'),(20037, 'Event Notification'),(20038, 'Scalar SQL Function'),
     (20047, 'Event Notification on Object'),(20051, 'Synonym'),(20549, 'End Point'),(20801, 'Adhoc Queries which may be cached'),
     (20816, 'Prepared Queries which may be cached'),(20819, 'Service Broker Service Queue'),(20821, 'Unique Constraint'),
     (21057, 'Application Role'),(21059, 'Certificate'),(21075, 'Server'),(21076, 'Transact-SQL Trigger'),(21313, 'Assembly'),
     (21318, 'CLR Scalar Function'),(21321, 'Inline scalar SQL Function'),(21328, 'Partition Scheme'),(21333, 'User'),
     (21571, 'Service Broker Service Contract'),(21572, 'Trigger on Database'),(21574, 'CLR Table-valued Function'),
     (21577, 'Internal Table (For example, XML Node Table, Queue Table.)'),(21581, 'Service Broker Message Type'),(21586, 'Service Broker Route'),
     (21587, 'Statistics'),(21825, 'User'),(21827, 'User'),(21831, 'User'),(21843, 'User'),(21847, 'User'),(22099, 'Service Broker Service'),
     (22601, 'Index'),(22604, 'Certificate Login'),(22611, 'XMLSCHEMA'),(22868,  'Type (e.g. Table Type)'))f(objectTypeid, ObjType)
     ON dt.objectType=objecttypeid
     WHERE StartTime BETWEEN @start AND @finish
      AND databasename NOT IN ('tempdb', 'MASTER')
    )

	*/
GO
/****** Object:  UserDefinedFunction [dbo].[ufnLeadingZeros]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufnLeadingZeros](
    @Value int
) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;

GO
/****** Object:  UserDefinedFunction [string].[udf_split_String]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/*
--	Written by: Emile Fraser
--	Date		:	2020-05-20
--	Function	:	Splits a string based on a delimeter and retuns a certain chunk based on the ChunkNumber

--	Chunk Number 3 ways:		1	Positive	Start from 1 ...n
--								0	N/A			Last chunk
--								-1	Negative	Last Chunk less the number (from the back)
--*/
CREATE  FUNCTION [string].[udf_split_String] (
	@StringValue	NVARCHAR(MAX)
,   @Delimiter		NVARCHAR(30)
,	@ChunkNumber	SMALLINT		= NULL
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN

	 WITH E1(N) AS ( 
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
		UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
		UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	), E2(N) AS (
		SELECT 1 FROM E1 a, E1 b
	), E4(N) AS (
		SELECT 1 FROM E2 a, E2 b
	), E8(N) AS (
		SELECT 1 FROM E4 a, E2 b
	), cteTally(N) AS (
		SELECT 0 
			UNION ALL 
		SELECT 
			TOP (DATALENGTH(ISNULL(@StringValue,1))) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E8
	),	cteStart(ChunkStart, ChunkNumber) AS (
				SELECT 
					t.N + 1
				,	ROW_NUMBER() OVER (ORDER BY t.N +1 )
				FROM 
					cteTally t
                WHERE 
					SUBSTRING(@StringValue, t.N, 1) = @Delimiter 
				OR 
					t.N = 0
	), cteFinal(ChunkStart, ChunkNumber, ChunkNumber_Max) AS (
		SELECT 
			cte.ChunkStart
		,	cte.ChunkNumber
		,	ctm.ChunkNumber_Max
		FROM cteStart AS cte
		CROSS JOIN (
			SELECT MAX(ChunkNumber) AS ChunkNumber_Max FROM cteStart
		) AS ctm
	)
	SELECT
		Item = SUBSTRING(@StringValue, f.ChunkStart, ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringValue, f.ChunkStart), 0) - f.ChunkStart, 8000))
	FROM 
		cteFinal f
	WHERE
		f.ChunkNumber BETWEEN COALESCE(IIF(@ChunkNumber <= 0, f.ChunkNumber_Max + @ChunkNumber, @ChunkNumber), 0) AND COALESCE(IIF(@ChunkNumber <= 0, f.ChunkNumber_Max, @ChunkNumber), 9999)
																
GO
/****** Object:  Table [bp].[CodeSmells]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bp].[CodeSmells](
	[SmellID] [int] IDENTITY(1,1) NOT NULL,
	[SmellCode] [varchar](100) NOT NULL,
	[SmellDecription] [varchar](250) NULL,
	[SmellTypeID] [int] NULL,
	[SmellProcedureName] [sysname] NULL,
	[SmellProcedureText] [varchar](max) NULL,
	[CreatedDT] [datetime] NOT NULL,
	[UpdatedDT] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [bp].[CodeSmellType]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bp].[CodeSmellType](
	[SmellTypeID] [int] IDENTITY(0,1) NOT NULL,
	[SmellTypeCode] [varchar](30) NOT NULL,
	[SmellTypeDecription] [varchar](250) NULL,
	[SmellSchemaName] [sysname] NULL,
	[CreatedDT] [datetime] NOT NULL,
	[UpdatedDT] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Nums]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nums](
	[n] [int] NOT NULL,
 CONSTRAINT [PK_Nums] PRIMARY KEY CLUSTERED 
(
	[n] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [inout].[JsonArmIn]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [inout].[JsonArmIn](
	[JsonArmString] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [inout].[JsonIn]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [inout].[JsonIn](
	[JsonString] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [tool].[GetBcpExportDynamic]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view [tool].[GetBcpExportDynamic]
as
   select
      name = '"' + name + '"' ,
      crdate = '"' + convert(varchar(8), crdate, 112) + '"' ,
      crtime = '"' + convert(varchar(8), crdate, 108) + '"'
   from sys.sysobjects
GO
/****** Object:  View [tool].[GetBcpFormatFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [tool].[GetBcpFormatFile]
as
   select top 100 percent
      name = '"' + name + '"' ,
      crdate = '"' + convert(varchar(8), crdate, 112) + '"' ,
      crtime = '"' + convert(varchar(8), crdate, 108) + '"'
   from sys.sysobjects
   order by crdate desc
GO
/****** Object:  View [tool].[TableDiff]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [tool].[TableDiff]
AS
WITH CTE_Dev
AS (
    SELECT ColumnId_LEFT = C.column_id
        ,ColumnName_LEFT = C.NAME
        ,MaxLength_LEFT = C.max_length
        ,UserTypeID_LEFT = C.user_type_id
        ,Precision_LEFT = C.precision
        ,Scale_LEFT = C.scale
        ,DataTypeName_LEFT = T.NAME
    FROM sys.columns C
    INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
    WHERE OBJECT_ID = OBJECT_ID('ext.BSEG_Accounting_Segment')
    )
    ,CTE_Temp
AS (
    SELECT ColumnId_RIGHT = C.column_id
        ,ColumnName_RIGHT = C.NAME
        ,MaxLength_RIGHT = C.max_length
        ,UserTypeId_RIGHT = C.user_type_id
        ,Precision_RIGHT = C.precision
        ,Scale_RIGHT = C.scale
        ,DataTypeName_RIGHT = T.NAME
    FROM sys.columns C
    INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
    WHERE OBJECT_ID = OBJECT_ID('ini.BSEG_Accounting_Segment')
    )
SELECT *
FROM CTE_Dev D
FULL OUTER JOIN CTE_Temp T ON D.ColumnName_LEFT= T.ColumnName_RIGHT
WHERE ISNULL(D.MaxLength_LEFT, 0) < ISNULL(T.MaxLength_RIGHT, 999)
GO
ALTER TABLE [bp].[CodeSmellType] ADD  DEFAULT (getdate()) FOR [CreatedDT]
GO
ALTER TABLE [bp].[CodeSmellType] ADD  DEFAULT ((1)) FOR [IsActive]
GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_Batch]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	-- RUNNING EVERYTHING FROM THE LOWEST LEVEL 
	-- ENSURE THAT LOWER ITEMS CAN JOIN TO HIGHER ITEMS WITH FOREIGN KEYS
	
	--	MACHINE_INSTANCE
	--	SQLSERVER_INSTANCE
	--	FILESIZE
	--	DATABASE
	--	DATABASE_FILE (data vs 
	--	SCHEMA
	--	TABLE 
	--	INDEXES
	
	EXEC master.dbo. sp_Update_StorageStats_Batch
*/
CREATE     PROCEDURE [dba].[sp_Update_StorageStats_Batch]
AS
BEGIN
	
	DECLARE 
		@StorageStats_BatchID INT = NULL
	,	@RC int = NULL

	-- If the table for Storage tracking doesnt exists, create it
	-- Also Assign BatchID to 1
	IF OBJECT_ID('dba.StorageStats_Batch', 'U') IS NULL
	BEGIN 

		  CREATE TABLE dba.[StorageStats_Batch](
			[BatchID]							[int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
			[HasStorageStatsRun_Machine]		[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Database]		[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_DatabaseFile]	[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Object]			[bit]				NOT NULL DEFAULT 0,
			[HasStorageStatsRun_Index]			[bit]				NOT NULL DEFAULT 0,
			[CreatedDT]							[datetime2](7)		NOT NULL DEFAULT GETDATE(),
			[UpdatedDT]							[datetime2](7)		NOT NULL DEFAULT GETDATE()
		) ON [PRIMARY]

	END	

	-- Create a Row with all default values
	INSERT INTO
		dba.StorageStats_Batch
	DEFAULT VALUES

	SET @StorageStats_BatchID = SCOPE_IDENTITY()
	--SELECT @StorageStats_BatchID

	-- VERY IMPORTANT, Run UPDATEUSAGE on EACH Database BEFORE Rest of the Procs are run
	EXEC sp_MSforeachdb 'DBCC UPDATEUSAGE (''?'') WITH NO_INFOMSGS;'
 
	-- LEVEL 0 = INDEXES 
	EXECUTE @RC = dba.sp_update_StorageStats_Index @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Index]	= 1 
		,	[UpdatedDT]					= GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 1 = OBJECT 
	EXECUTE @RC = dba.sp_Update_StorageStats_Object @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Object] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 2 = DBF 
	EXECUTE @RC = dba.sp_Update_StorageStats_DatabaseFile @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_DatabaseFile] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 3 = DB 
	EXECUTE @RC = dba.sp_Update_StorageStats_Database @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Database] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END

	-- LEVEL 4 = Machine Level 
	EXECUTE @RC = dba.sp_Update_StorageStats_Server @StorageStats_BatchID
	IF @RC = 0
	BEGIN
		UPDATE 
			dba.StorageStats_Batch
		SET 
			[HasStorageStatsRun_Machine] = 1 
		,	[UpdatedDT] = GETDATE()
		WHERE
			BatchID = @StorageStats_BatchID
	END
END




GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_Database]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	--POPULATES THE STORAGE STATS FOR A SPECIFIC DATABASE
	DECLARE @BatchID INT = 1
	EXEC [dba].sp_Update_StorageStats_Database @BatchID
*/
CREATE   PROCEDURE [dba].[sp_Update_StorageStats_Database]
	@BatchID INT
AS
BEGIN
	
	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('[dba].StorageStats_Database', 'U') IS NULL
	BEGIN 
		CREATE TABLE [dba].[StorageStats_Database](
			[StorageStats_Database_ID] [int] NULL,
			[BatchID] [int] NULL,
			[database_id] [int] NOT NULL,
			[size_database] [int] NULL,
			[state] [tinyint] NULL,
			[state_desc] [nvarchar](60) NULL,
			[recovery_model] [tinyint] NULL,
			[recovery_model_desc] [nvarchar](60) NULL,
			[is_auto_create_stats_on] [bit] NULL,
			[is_auto_update_stats_on] [bit] NULL,
			[is_auto_shrink_on] [bit] NULL,
			[is_ansi_padding_on] [bit] NULL,
			[is_fulltext_enabled] [bit] NULL,
			[is_query_store_on] [bit] NULL,
			[is_temporal_history_retention_enabled] [bit] NULL,
			[SqlServerInstanceName] nvarchar(128) NULL,
			[MachineName]  nvarchar(128) NULL,
			[CreatedDT] [datetime2](7) NULL,
		)

	END
	

	INSERT INTO
		[dba].StorageStats_Database
	(
      	[BatchID]
      ,	[database_id]
      ,	[size_database]
      ,	[state]
      ,	[state_desc]
      ,	[recovery_model]
      ,	[recovery_model_desc]
      ,	[is_auto_create_stats_on]
      ,	[is_auto_update_stats_on]
      ,	[is_auto_shrink_on]
      ,	[is_ansi_padding_on]
      ,	[is_fulltext_enabled]
      ,	[is_query_store_on]
      ,	[is_temporal_history_retention_enabled]
	  , [SqlServerInstanceName]
	  , [MachineName]
      ,	[CreatedDT]
	)
	SELECT 
		@BatchID AS BatchID
	,	d.database_id AS database_id
	,	SUM(m.size) AS size_bytes
	,	d.state
	,	d.state_desc
	,	d.recovery_model
	,	d.recovery_model_desc
	,	d.is_auto_create_stats_on
	,	d.is_auto_update_stats_on
	,	d.is_auto_shrink_on
	,	d.is_ansi_padding_on
	,	d.is_fulltext_enabled
	,	d.is_query_store_on
	,	d.is_temporal_history_retention_enabled
	,	CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) AS SqlServerInstanceName
	,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS MachineName
	,	GETDATE() AS CreatedDT
	FROM 
		sys.databases AS d
	INNER JOIN 
		sys.master_files AS m
	ON 
		m.database_id = d.database_id 
	GROUP BY 
		d.database_id
	,	d.state
	,	d.state_desc
	,	d.recovery_model
	,	d.recovery_model_desc
	,	is_auto_create_stats_on
	,	is_auto_update_stats_on
	,	is_auto_shrink_on
	,	is_ansi_padding_on
	,	is_fulltext_enabled
	,	is_query_store_on
	,	is_temporal_history_retention_enabled

	END

GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_DatabaseFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE @BatchID INT = 1
	EXEC dba.sp_Update_StorageStats_DatabaseFile @BatchID
*/
CREATE     PROCEDURE [dba].[sp_Update_StorageStats_DatabaseFile]
			@BatchID INT
AS
BEGIN

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('STORE.StorageStats_DatabaseFile', 'U') IS NULL
	BEGIN 
		CREATE TABLE STORE.[StorageStats_DatabaseFile](
			[StorageStats_DatabaseFileID] [int] NULL,
			[BatchID] [int] NULL,
			[file_id] INT NULL,
			[file_guid] UNIQUEIDENTIFIER NULL,
			[file_name] NVARCHAR(128) NULL,	
			[file_type] INT NULL,
			[file_type_desc] VARCHAR(128) NULL,
			[file_classification] varchar(128) NULL,
			[file_path] NVARCHAR(MAX) NULL,
			[file_drive] NVARCHAR(10) NULL,
			[size_file] BIGINT NULL,
			[max_size]	BIGINT NULL,
			[growth] BIGINT NULL,
			[database_id] [int] NOT NULL,
			[SqlServerInstanceName] [sysname] NULL,
			[MachineName]  [sysname] NULL,
			[CreatedDT] [datetime2](7) NOT NULL DEFAULT GETDATE()
		)

	END

	INSERT INTO STORE.[StorageStats_DatabaseFile]
	(
       [BatchID]
      ,[file_id]
      ,[file_guid]
      ,[file_name]
      ,[file_type]
      ,[file_type_desc]
	  ,[file_classification]
      ,[file_path]
      ,[file_drive]
      ,[size_file]
	  ,[max_size]
	  ,[growth]
      ,[database_id]
      ,[SqlServerInstanceName]
      ,[MachineName]
      ,[CreatedDT]
	)
	SELECT 
		@BatchID
	,	m.file_id
	,	m.file_guid
	,	m.name
	,	m.type
	,	m.type_desc
	,	CASE	WHEN DB_NAME(m.database_id) = 'tempdb' THEN 'tempdb'
				WHEN m.Type_Desc = 'LOG'  THEN 'log'
				ELSE 'data'
		END AS file_classification
	,	m.physical_name
	,	SUBSTRING(m.physical_name, 1, CHARINDEX(':', m.physical_name))
	,	(m.size * 8) AS size_file
	,	m.max_size
	,	m.growth
	,	m.database_id
	,	CONVERT(NVARCHAR(128), SERVERPROPERTY('ServerName')) AS SqlServerInstanceName
	,	CONVERT(NVARCHAR(128),SERVERPROPERTY('MachineName')) AS MachineName
	,	GETDATE() AS CreatedDT
	FROM 
		sys.databases AS d
	INNER JOIN 
		sys.master_files AS m
	ON 
		m.database_id = d.database_id 
	ORDER BY 
		m.physical_name	

END

GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_Index]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	DECLARE @BatchID INT = 1
	EXEC dba.sp_Update_StorageStats_Index @BatchID
*/
CREATE     PROCEDURE [dba].[sp_Update_StorageStats_Index]
	@BatchID INT = NULL
AS
BEGIN

	-- GETS PageSize for type, version as well as flavour of SQL we are dealing with
	DECLARE @PageSize FLOAT = (SELECT v.low / 1024.0 FROM master.dbo.spt_values v WHERE v.number = 1 AND v.type = 'E')
	DECLARE @sql_statement NVARCHAR(MAX) = NULL
	DECLARE @DatabaseID INT = NULL
	DECLARE @DatabaseName NVARCHAR(128) = NULL

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('dba.StorageStats_Index', 'U') IS NULL
	BEGIN 

		 CREATE TABLE 
			dba.[StorageStats_Index]
			(
				[StorageStats_IndexID] [int] IDENTITY(1,1) NOT NULL,
				[BatchID] [int] NOT NULL,
				[index_id] [int] NOT NULL,
				[index_type] [tinyint] NOT NULL,
				[type_desc] [nvarchar](60) NULL,
				[fill_factor] [tinyint] NULL,
				[is_unique] [bit] NULL,
				[is_padded] [bit] NULL,
				[size_index_total] FLOAT NULL,
				[size_index_used] FLOAT NULL,
				[size_index_unused] FLOAT NULL,
				[object_id] [int] NOT NULL,
				[schema_id] [int] NOT NULL,
				[database_id] INT NOT NULL,
				[CreatedDT] [datetime] NOT NULL DEFAULT GETDATE()
			)

	END


	DECLARE @DatabaseCursor CURSOR 
	SET @DatabaseCursor = CURSOR READ_ONLY FOR  
	SELECT 
		d.database_id, d.name 
	FROM 
		sys.databases AS  d

	OPEN @DatabaseCursor  

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN 

		-- Test results against sp_spaceused 'HUB_Site'
		-- 8KB difference between sp_spaceused and HEAP index table is as result of column headers
		set @sql_statement = '
		INSERT INTO
			dba.StorageStats_Index
			(
      			[BatchID]
			  ,	[index_id]
			  ,	[index_type]
			  ,	[type_desc]
			  ,	[fill_factor]
			  ,	[is_unique]
			  ,	[is_padded]
			  ,	[size_index_total]
			  ,	[size_index_used]
			  ,	[size_index_unused]
			  ,	[table_id]
			  ,	[schema_id]
			  ,	[database_id]
			  ,	[CreatedDT]
			)
		SELECT
				' + CONVERT(VARCHAR(10), @BatchID) + ' AS BatchID
			,	o.object_id AS index_id
			,	i.type AS index_type
			,	i.type_desc
			,	i.fill_factor
			,	i.is_unique
			,	i.is_padded
			,	(a.total_pages * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_total
			,	(a.used_pages * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_used
			,	((a.total_pages - a.used_pages) * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_unused
			,	t.object_id AS table_id
			,	o.schema_id
			,	' + CONVERT(VARCHAR(10),@DatabaseID) + ' AS DatabaseID
			,	GETDATE() AS CreatedDT
		FROM 
			' + QUOTENAME(@DatabaseName) + '.sys.objects o
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.indexes i
			ON i.object_id = o.object_id
		INNer JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.tables AS t
			ON t.object_id = o.object_id
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.partitions AS p 
			ON p.object_id = i.object_id 
			AND p.index_id = i.index_id
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.allocation_units AS a 
			ON a.container_id = p.partition_id
		WHERE 
			o.is_ms_shipped <> 1
		AND 
			i.index_id > 0
		ORDER BY 
			i.[name]'


		EXEC sp_executesql @stmt = @sql_statement

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  

END 


END

GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_Object]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	DECLARE @BatchID INT = 1
	EXEC dba.sp_Update_StorageStats_Object @BatchID
*/
CREATE       PROCEDURE [dba].[sp_Update_StorageStats_Object]
	@BatchID INT = NULL
AS
BEGIN

	-- GETS PageSize for type, version as well as flavour of SQL we are dealing with
	DECLARE @PageSize FLOAT = (SELECT v.low / 1024.0 FROM master.dbo.spt_values v WHERE v.number = 1 AND v.type = 'E')
	DECLARE @sql_statement NVARCHAR(MAX) = NULL
	DECLARE @DatabaseID INT = NULL
	DECLARE @DatabaseName NVARCHAR(128) = NULL

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('dba.StorageStats_Object', 'U') IS NULL
	BEGIN 

		CREATE TABLE dba.[StorageStats_Object](
			[StorageStats_Table_ID] [int] NOT NULL,
			[BatchID] [int] NOT NULL,
			[object_id] [int] NOT NULL,
			[object_type] [char](2) NULL,
			[object_type_desc] [nvarchar](60) NULL,
			[large_value_types_out_of_row] [bit] NULL,
			[durability] [tinyint] NULL,
			[durability_desc] [nvarchar](60) NULL,
			[temporal_type] [tinyint] NULL,
			[temporal_type_desc] [nvarchar](60) NULL,
			[is_external] [bit] NOT NULL,
			[history_retention_period] [int] NULL,
			[column_count] [int] NOT NULL,
			[row_count] [bigint] NULL,
			[text_in_row_limit] [int] NULL,
			[size_table_total] [bigint] NULL,
			[size_table_used] [bigint] NULL,
			[size_table_unused] [bigint] NULL,
			[allocation_type] [tinyint] NOT NULL,
			[allocation_type_desc] [nvarchar](60) NULL,
			[schema_id] [int] NULL,
			[database_id] INT NOT NULL,
			[CreatedDT] DATETIME2(7) NOT NULL DEFAULT GETDATE()
		) 

	END


	DECLARE @DatabaseCursor CURSOR 
	SET @DatabaseCursor = CURSOR READ_ONLY FOR  
	SELECT 
		d.database_id, d.name 
	FROM 
		sys.databases AS d  

	OPEN @DatabaseCursor  

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN 

		set @sql_statement = '
		INSERT INTO dba.StorageStats_Object
		(
				[BatchID]
			  ,	[object_id]
			  ,	[object_type]
			  ,	[object_type_desc]
			  ,	[large_value_types_out_of_row]
			  ,	[durability]
			  ,	[durability_desc]
			  ,	[temporal_type]
			  ,	[temporal_type_desc]
			  ,	[is_external]
			  ,	[history_retention_period]
			  ,[column_count]
			  ,[row_count]
			  ,[text_in_row_limit]
			  ,[size_table_total]
			  ,[size_table_used]
			  ,[size_table_unused]
			  ,[allocation_type]
			  ,[allocation_type_desc]
			  ,[schema_id]
			  ,[database_id]
			  ,[CreatedDT]
	  )
			SELECT 
				' + CONVERT(VARCHAR(10), @BatchID) + ' AS BatchID
			,	t.object_id AS table_id
			,	t.type AS object_type
			,	t.type_desc AS object_type_desc			
			,	t.large_value_types_out_of_row
			,	t.durability
			,	t.durability_desc
			,	t.temporal_type
			,	t.temporal_type_desc
			,	t.is_external
			,	t.history_retention_period
			,	t.max_column_id_used AS column_count
			,	p.rows AS row_count
			,	t.text_in_row_limit
			,	(a.total_pages) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_total
			,	(a.used_pages) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_used
			,	((a.total_pages) - (a.used_pages)) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_unused
			,	a.type AS allocation_type
			,	a.type_desc AS allocation_type_desc
			,	s.schema_id
			,	' + CONVERT(VARCHAR(10),@DatabaseID) + ' AS DatabaseID
			,	GETDATE() AS CreatedDT
			FROM
				' + QUOTENAME(@DatabaseName) + '.sys.objects AS o
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.tables AS t
			ON t.object_id = o.object_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.indexes AS i
			ON t.object_id = i.object_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.partitions AS p
			ON i.object_id = p.object_id AND i.index_id = p.index_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.allocation_units AS a
			ON p.partition_id = a.container_id
			LEFT OUTER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.schemas AS s
			ON t.schema_id = s.schema_id
		WHERE
			i.type = 0'
		
		EXEC sp_executesql @stmt = @sql_statement

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  

END 

END

GO
/****** Object:  StoredProcedure [dba].[sp_Update_StorageStats_Server]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	DECLARE @BatchID INT = 1
	EXEC master.dbo.sp_Update_StorageStats_Server @BatchID
*/
CREATE     PROCEDURE [dba].[sp_Update_StorageStats_Server]
			@BatchID INT
AS
BEGIN

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('dba.StorageStats_Server', 'U') IS NULL
	BEGIN 
		CREATE TABLE dba.[StorageStats_Server](
		   [StorageStats_DatabaseFile_ID] [int] IDENTITY NOT NULL
		  ,[BatchID] [int] NOT NULL
		  ,[drive_mountpoint] nvarchar(100) NULL
		  ,[drive_name]  nvarchar(100) NULL
		  ,[drive_type] nvarchar(100) NULL
		  ,[size_drive_total] bigint NULL
		  ,[size_drive_used] bigint NULL
		  ,[size_drive_unused] bigint NULL
		  ,CreatedDT DATEtime2(7) not null default getdate()
		)

	END

	INSERT INTO dba.[StorageStats_Server]
	(
       [BatchID]
      ,[drive_mountpoint]
      ,[drive_name]
      ,[drive_type]
      ,[size_drive_total]
      ,[size_drive_used]
	  ,[size_drive_unused]
	)
	SELECT DISTINCT 
		@BatchID
	,	dovs.volume_mount_point AS drive_mountpoint
	,	dovs.logical_volume_name AS [drive_name]
	,	dovs.file_system_type AS [drive_type]
	,	dovs.total_bytes AS [size_drive_total]
	,	dovs.total_bytes - dovs.available_bytes AS [size_drive_used]
	,	dovs.available_bytes AS [size_drive_unused]
FROM 
	sys.master_files mf
CROSS APPLY 
	sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs


END
GO
/****** Object:  StoredProcedure [dbo].[Generate_DbDiagram]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Main Generation Procedure
-- EXEC [dbo].[Generate_DbDiagram]
CREATE   PROCEDURE [dbo].[Generate_DbDiagram]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET STATISTICS IO OFF

DECLARE
	@DatabaseType					NVARCHAR(MAX)	= 'SQL Server'
,	@ProjectDescription				NVARCHAR(MAX)	= 'MetadataDB'
,	@Database_ToDiagram				SYSNAME			= 'AcAzMetaDataDB'
,	@Schema_ToDiagram				SYSNAME			= 'adf'
,	@ERD_Type						SMALLINT		= 1 -- 1 = ONLY KEYS, 2 = FULL
,	@Object_Type					SYSNAME			= 'U' -- U, V

DECLARE 
	@sql_statement					NVARCHAR(MAX)
,	@sql_parameter					NVARCHAR(MAX)
,	@sql_message					NVARCHAR(MAX)
,	@sql_crlf						NVARCHAR(2) = CHAR(13) + CHAR(10)
,	@sql_tab						NVARCHAR(1) = CHAR(9)
,	@sql_debug						BIT = 1
,	@sql_execute					BIT = 1

DECLARE 
	@Level00_project		NVARCHAR(MAX)
,	@level0_enums			NVARCHAR(MAX)
,	@level1_tables			NVARCHAR(MAX)
,	@level2_references		NVARCHAR(MAX)
,	@level012_final			NVARCHAR(MAX)

DECLARE
	@table_cursor			CURSOR
,	@schema_name			NVARCHAR(MAX)
,	@table_name				NVARCHAR(MAX)
,	@column_name			NVARCHAR(MAX)
,	@column_type			NVARCHAR(MAX)
,	@is_primarykey			NVARCHAR(MAX)

DECLARE 
	@ObjectName				NVARCHAR(MAX)
,	@ObjectType				NVARCHAR(MAX)

DECLARE @metadata TABLE (
	Id					INT IDENTITY(1,1)	NOT NULL PRIMARY KEY
,	ObjectType			SYSNAME				NOT NULL
,	ObjectName			SYSNAME				NOT NULL
,	ObjectValue			NVARCHAR(256)		NULL
,	ObjectParent		SYSNAME				NULL
,	ObjectReference		NVARCHAR(256)		NULL
,	SpecialProperty		NVARCHAR(256)		NULL
,	IsInclude			BIT					DEFAULT 1
)

RAISERROR('************ DATABASE *************', 0, 1) WITH NOWAIT

-- Database 
INSERT INTO @metadata(ObjectType, ObjectName)
SELECT 'DATABASE', QUOTENAME(db.name)
FROM sys.databases AS db
WHERE db.name = @Database_ToDiagram

IF NOT EXISTS (
	SELECT * FROM @metadata WHERE ObjectType = 'DATABASE'
)
BEGIN
	SET @ObjectName = @Database_ToDiagram
	SET @objectType = 'DATABASE'
	GOTO ISSUE
END
ELSE
BEGIN	
	SET @sql_message = @Database_ToDiagram + ' has been added' + @sql_crlf
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT
END


-- SCHEMA
RAISERROR('************ SCHEMA *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
	SELECT ''SCHEMA'', QUOTENAME(sc.name), ''' + QUOTENAME(@Database_ToDiagram) + '''
	FROM ' + QUOTENAME(@Database_ToDiagram) + '.[sys].[schemas] AS sc
	WHERE sc.name = ''' + @Schema_ToDiagram + ''''

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END


IF NOT EXISTS (
	SELECT * FROM @metadata WHERE ObjectType = 'SCHEMA'
)
BEGIN
	SET @ObjectName = @Schema_ToDiagram
	SET @objectType = 'SCHEMA'
	GOTO ISSUE
END
ELSE
BEGIN	
	SET @sql_message = @Schema_ToDiagram + ' has been added' + @sql_crlf
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT
END


-- OBJECTS
RAISERROR('************ OBJECTS *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
SELECT
	obj.Type_Desc
,  ''' + QUOTENAME(@Database_ToDiagram) + '.' + QUOTENAME(@Schema_ToDiagram) + '.'' + QUOTENAME(obj.name)
, ''' + QUOTENAME(@Database_ToDiagram) + '.' + QUOTENAME(@Schema_ToDiagram) + '''
FROM 
	sys.objects AS obj
INNER JOIN 
	sys.schemas AS sch
	ON sch.schema_id = obj.schema_id
WHERE
	obj.is_ms_shipped = 0
AND	
	sch.name = ''DC''
	AND
	obj.[Type] = ''' + @Object_Type + ''''

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END



-- COLUMNS
RAISERROR('************ COLUMN *************', 0, 1) WITH NOWAIT
SET @sql_statement = '
SELECT 
		ObjectType		= ''COLUMN'' 
    ,	ObjectName		= ''' + QUOTENAME(@Database_ToDiagram) + ''' + ' + '''.''' + '+ QUOTENAME(sch.name)' + ' + ' + '''.''' + '+ QUOTENAME(tab.name)' + ' + ' + '''.''' + '+ QUOTENAME(col.name)
	,	ObjectValue		= t.name + '' ['' + IIF(col.is_nullable = 1, ''null'', ''not null'') + '']''
	,	ObjectParent	= ''' + QUOTENAME(@Database_ToDiagram) + ''' + ' + '''.''' + '+ QUOTENAME(sch.name)' + ' + ' + '''.''' + '+ QUOTENAME(tab.name)
FROM ' + QUOTENAME(@Database_ToDiagram) + '.sys.tables as tab
INNER JOIN ' + QUOTENAME(@Database_ToDiagram) + '.sys.schemas AS sch
ON sch.Schema_ID = tab.Schema_ID
INNER JOIN ' + QUOTENAME(@Database_ToDiagram) + '.sys.columns as col
ON tab.object_id = col.object_id
    left join ' + QUOTENAME(@Database_ToDiagram) + '.sys.types as t
    on col.user_type_id = t.user_type_id
where sch.name = ''' + @Schema_ToDiagram + '''
order by tab.name, column_id'

IF(@sql_debug = 1)
BEGIN
	RAISERROR(@sql_statement,0,1) WITH NOWAIT
END
IF(@sql_execute = 1)
BEGIN
	INSERT INTO @metadata(ObjectType, ObjectName, ObjectValue, ObjectParent)
	EXEC sp_executesql @stmt = @sql_statement
END


select table_view,
    object_type, 
    constraint_type,
    constraint_name,
    details
from (
    select schema_name(t.schema_id) + '.' + t.[name] as table_view, 
        case when t.[type] = 'U' then 'Table'
            when t.[type] = 'V' then 'View'
            end as [object_type],
        case when c.[type] = 'PK' then 'Primary key'
            when c.[type] = 'UQ' then 'Unique constraint'
            when i.[type] = 1 then 'Unique clustered index'
            when i.type = 2 then 'Unique index'
            end as constraint_type, 
        isnull(c.[name], i.[name]) as constraint_name,
        substring(column_names, 1, len(column_names)-1) as [details]
    from sys.objects t
        left outer join sys.indexes i
            on t.object_id = i.object_id
        left outer join sys.key_constraints c
            on i.object_id = c.parent_object_id 
            and i.index_id = c.unique_index_id
       cross apply (select col.[name] + ', '
                        from sys.index_columns ic
                            inner join sys.columns col
                                on ic.object_id = col.object_id
                                and ic.column_id = col.column_id
                        where ic.object_id = t.object_id
                            and ic.index_id = i.index_id
                                order by col.column_id
                                for xml path ('') ) D (column_names)
    where is_unique = 1
    and t.is_ms_shipped <> 1
    union all 
    select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
        'Table',
        'Foreign key',
        fk.name as fk_constraint_name,
        schema_name(pk_tab.schema_id) + '.' + pk_tab.name
    from sys.foreign_keys fk
        inner join sys.tables fk_tab
            on fk_tab.object_id = fk.parent_object_id
        inner join sys.tables pk_tab
            on pk_tab.object_id = fk.referenced_object_id
        inner join sys.foreign_key_columns fk_cols
            on fk_cols.constraint_object_id = fk.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Check constraint',
        con.[name] as constraint_name,
        con.[definition]
    from sys.check_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Default constraint',
        con.[name],
        col.[name] + ' = ' + con.[definition]
    from sys.default_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id) a
order by table_view, constraint_type, constraint_name



SELECT * FROM @metadata

	
--	DatabseName	SYSNAME
--,	SchemaName	SYSNAME
--,	ObjectName	SYSNAME




--SET @table_cursor = CURSOR FOR 
--SELECT
--	sch.name, tab.name
--FROM 
--	sys.objects AS obj
--INNER JOIN 
--	sys.tables AS tab
--	ON tab.object_id = obj.object_id
--INNER JOIN 
--	sys.schemas AS sch
--	ON sch.schema_id = tab.schema_id
--WHERE
--	obj.is_ms_shipped = 0
--AND	
--	sch.name = @Schema_ToDiagram

--select 
--    col.column_id as id,
--    col.name,
--    t.name as data_type,
--    col.max_length,
--    col.precision,
--    col.is_nullable
--from sys.tables as tab
--    inner join sys.columns as col
--        on tab.object_id = col.object_id
--    left join sys.types as t
--    on col.user_type_id = t.user_type_id
--where tab.name = 'Table name' -- enter table name here
---- and schema_name(tab.schema_id) = 'Schema name'
--order by tab.name, column_id;


--OPEN @table_cursor

--FETCH NEXT FROM @table_cursor
--INTO @schema_name, @table_name

--WHILE(@@FETCH_STATUS = 0)
--BEGIN
		
--	--SELECT @schema_name, @table_name

--	-- Kicks off the Table Definition
--	SET @level1_tables += 'Table ' + @table_name +  ' {' + @sql_crlf
	
--	SELECT 
--		-- Combine existing string with Column Name, Column Type and Open Square Bracket for the Column Definition
--		@level1_tables += @sql_tab + col.name + ' ' + typ.name + ' ' + '[' + 

--	--	---- Now set the different column settings
--	--	--CASE 
--	--	--		-- First Primary Key
--	--	--		WHEN idc.object_id IS NOT NULL
--	--	--			THEN	CASE 
--	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 1
--	--	--							THEN 'pk, increment'
--	--	--						WHEN idc.object_id IS NOT NULL AND col.is_identity = 0
--	--	--							THEN 'pk'
--	--	--							ELSE ''
--	--	--					END

--	--			-- Now Unique Column Constraint
--	--			--WHEN idx.is_unique_constraint = 1 
--	--			--	THEN	CASE 
--	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 1
--	--			--					THEN 'unique, increment'
--	--			--				WHEN idx.is_unique_constraint = 1 AND col.is_identity = 0
--	--			--					THEN 'unique'
--	--			--					ELSE ''
--	--			--			END
			
--	--		---- No the Increment that fell through	
--	--		--WHEN col.is_identity = 1 
--	--		--	THEN 'increment'		

--	--		---- Now Get default values 
--	--		--WHEN col.default_object_id <> 0 
--	--		--	THEN 'default: `' + ISNULL(dcs.[Definition],'') + '`'
--	--		--	ELSE ''
--	--		--END +
		
--	--		---- Add comma in case one of above was true
--	--		--CASE 
--	--		--	WHEN  (idc.object_id IS NOT NULL OR idx.is_unique_constraint = 1 OR col.is_identity = 1 OR col.default_object_id <> 0 )
--	--		--		THEN ', '
--	--		--		ELSE ''
--	--		--END +

--	--		---- nullable and non nullable 
--	--		--CASE 
--	--		--	WHEN col.is_nullable = 0
--	--		--		THEN 'not null'
--	--		--		ELSE 'null'
--	--		--END + 

--	--		---- lastly add optional note
--	--		--CASE 
--	--		--	WHEN 0 = 1
--	--		--		THEN 'note: ''blah blah blah'''
--	--		--		ELSE ''
--	--		--END + ']' 
--	--			--ELSE ''
--	--		--END
--		+ ']' 
--			+ @sql_crlf -- Now close the bracket
--	FROM 
--		sys.objects AS obj
--	INNER JOIN 
--		sys.tables AS tab
--		ON tab.object_id = obj.object_id
--	INNER JOIN 
--		sys.schemas AS sch
--		ON sch.schema_id = tab.schema_id
--	INNER JOIN 
--		sys.columns AS col
--		ON col.object_id = obj.object_id
--	INNER JOIN 
--		sys.types AS typ
--		ON typ.user_type_id = col.user_type_id
--	--WHERE
--	--	sch.name = 'BG'

--	----LEFT JOIN 
--	----	sys.computed_columns AS ccl
--	----	ON ccl.object_id = obj.object_id
--	--	LEFT JOIN	
--	--		sys.default_constraints AS dcs
--	--		ON dcs.parent_object_id = obj.object_id
--	--		AND dcs.parent_column_id = col.column_id

--	-- LEFT join sys.indexes idx
-- --       on tab.object_id = idx.object_id 
--	--	and  idx.object_id = col.object_id
-- --       and idx.is_primary_key = 1

-- --   LEFT join sys.index_columns idc
-- --       on idc.object_id = idx.object_id
-- --       and idc.index_id = idx.index_id
-- --       and col.column_id = idc.column_id
--	----LEFT JOIN 
--	----	sys.key_constraints AS kcs
--	----	ON kcs.parent_object_id = obj.object_id
--	----		AND kcs.parent_column_id = col.column_id
--	WHERE
--		sch.name = @schema_name
--	AND
--		obj.name = @table_name
--	AND
--		obj.is_ms_shipped = 0
--	ORDER BY 
--		col.column_id
	

--	/* TODO: Create index here */
--	SET @level1_tables += '}' + @sql_crlf + @sql_crlf

--	IF(@sql_debug = 1)
--		RAISERROR(@level1_tables, 0, 1) WITH NOWAIT


--	FETCH NEXT FROM @table_cursor
--	INTO @schema_name, @table_name

--END

---- Finishing up table definitions
--SET @level1_tables += @sql_crlf + '
--//==============================================//
--'



---- REFERENCES DEFINITION
--SET @level2_references = '
--//----------------------------------------------//
--// Level 2 - References
--//----------------------------------------------//

--'

--SELECT
--	@level2_references +=	'Ref:' + 
--							' "' + pk_tab.name + '"'	+ '.' + '"' + pk_col.name + '" ' + 			
--							'<' + 
--							' "' + tab.name + '"'	+ '.' + '"' + col.name + '"' + REPLICATE(@sql_crlf,2)

----select *
--FROM
--	sys.tables tab
--inner join 
--	sys.schemas AS sch
--	on sch.schema_id = tab.schema_id
--inner join 
--	sys.columns col 
--    on col.object_id = tab.object_id
--left outer join 
--	sys.foreign_key_columns fk_cols
--    on fk_cols.parent_object_id = tab.object_id
--    and fk_cols.parent_column_id = col.column_id
--left outer join 
--	sys.foreign_keys fk
--    on fk.object_id = fk_cols.constraint_object_id
--left outer join 
--	sys.tables pk_tab
--    on pk_tab.object_id = fk_cols.referenced_object_id
--inner join 
--	sys.schemas AS pk_sch
--	on pk_sch.schema_id = pk_tab.schema_id
--left outer join 
--	sys.columns pk_col
--    on pk_col.column_id = fk_cols.referenced_column_id
--    and pk_col.object_id = fk_cols.referenced_object_id
--WHERE 
--	pk_tab.object_id IS NOT NULL
--AND 
--	sch.name = @Schema_ToDiagram



---- Finishing up refrences definitions
--SET @level2_references += @sql_crlf + '
--//==============================================//
--'

----SELECT @level3_enum_index

--SET @level012_final =  ISNULL(@level00_project, '') + ISNULL(@level0_enums, '') + ISNULL(@level1_tables, '') + ISNULL(@level2_references, '')

--SELECT @level012_final

--DataVault@123
--END 
--GO

--EXEC #Generate_DbDiagram
--GO

--DROP PROCEDURE IF EXISTS #Generate_DbDiagram
--GO




---- PROJECT DEFINITION
--SET @Level00_project = '
--//----------------------------------------------//
--// Level 00 - Project
--//----------------------------------------------//
--Project project_name {
--  database_type: ''' + @DatabaseType + '''
--  Note: ''' + @ProjectDescription + '''
--}
--'

---- Finishing up project definitions
--SET @Level00_project += @sql_crlf + '
--//==============================================//
--'
---- ENUMS DEFINITION
--SET @level0_enums = '
--//----------------------------------------------//
--// Level 0 - Enums
--//----------------------------------------------//
--'

---- Finishing up enums definitions
--SET @level0_enums += @sql_crlf + '
--//==============================================//
--'
---- TABLE DEFINITION
--SET @level1_tables = '
--//----------------------------------------------//
--// Level 1 - Tables
--//----------------------------------------------//
--'


ISSUE: 
	SET @sql_message = '### ERROR ###' + @sql_crlf
	SET @sql_message += 'No ' + @ObjectName + '(' +  @ObjectType + ') found!'
	RAISERROR(@sql_message, 0, 1) WITH NOWAIT

END
GO
/****** Object:  StoredProcedure [dbo].[GetArmTemplateJson]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetArmTemplateJson] AS
BEGIN

SELECT *
FROM OPENROWSET(BULK 'arm_template.json', DATA_SOURCE = 'CustomerTestBlobStorage', SINGLE_CLOB) as data

END
GO
/****** Object:  StoredProcedure [dbo].[GetStringOrBinaryTruncated]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetStringOrBinaryTruncated]
	@String VARCHAR(MAX)
AS
 
DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
             ,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST(('<a>'+REPLACE(@String,'(','</a><a>')
           +'</a>') AS XML)
 

 select @String
SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)
  select @TCount
;WITH CTE AS
     (SELECT
     (CASE
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))>0)
     THEN 1
     WHEN CHARINDEX('VALUES',A.value('.', 'varchar(max)'))>0
     THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=2  THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=3  THEN 3
     END) AS[Batch Number],
     REPLACE(REPLACE(A.value('.', 'varchar(max)')
     ,'INSERT INTO',''),'VALUES ','') AS [Column]
     FROM @Xml.nodes('A') AS FN(A))
 

select * from cte
GO
/****** Object:  StoredProcedure [dbo].[GetTableDiff]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [dbo].[GetTableDiff]
AS

DECLARE 
	@DATABASE_LEFT		SYSNAME = ''
,	@DATABASE_RIGHT		SYSNAME = ''
,	@SCHEMA_LEFT		SYSNAME = 'ini'
,	@SCHEMA_RIGHT		SYSNAME = 'ext'
,	@ENTITY_LEFT		SYSNAME = 'BSEG_Accounting_Segment'
,	@ENTITY_RIGHT		SYSNAME = 'BSEG_Accounting_Segment'

DECLARE 
	@sql_statement 		NVARCHAR(MAX)
	
SET @sql_statement = '
	SELECT ENTLEFT.name as ENTLEFT_ColumnName, 
	ENTRIGHT.name as ENTRIGHT_ColumnName, 
	ENTLEFT.is_nullable as ENTLEFT_is_nullable, 
	ENTRIGHT.is_nullable as ENTRIGHT_is_nullable, 
	ENTLEFT.system_type_name as ENTLEFT_Datatype, 
	ENTRIGHT.system_type_name as ENTRIGHT_Datatype, 
	ENTLEFT.is_identity_column as ENTLEFT_is_identity, 
	ENTRIGHT.is_identity_column as ENTRIGHT_is_identity ,
	IIF(ENTLEFT.system_type_name = ENTRIGHT.system_type_name, 1, 0) AS is_system_type_match
	FROM sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_LEFT) + '.' + QUOTENAME(@ENTITY_LEFT) + 
			''', NULL, 0) AS ENTLEFT 
	FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_RIGHT) + '.' + QUOTENAME(@ENTITY_RIGHT) + 
		''', NULL, 0) AS ENTRIGHT
	ON ENTLEFT.name = ENTRIGHT.name
'
PRINT(@sql_statement)
EXECUTE sp_executesql
	@stmt = @sql_statement
	
GO
/****** Object:  StoredProcedure [dbo].[ImportJsonFromAzBlobToLocal]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ImportJsonFromAzBlobToLocal] 
AS 
BEGIN
SELECT 'TODO'
/*

Import JSON documents from Azure File Storage
You can also use OPENROWSET(BULK) as described above to read JSON files from other file locations that SQL Server can access. For example, Azure File Storage supports the SMB protocol. As a result you can map a local virtual drive to the Azure File storage share using the following procedure:

Create a file storage account (for example, mystorage), a file share (for example, sharejson), and a folder in Azure File Storage by using the Azure portal or Azure PowerShell.

Upload some JSON files to the file storage share.

Create an outbound firewall rule in Windows Firewall on your computer that allows port 445. Note that your Internet service provider may block this port. If you get a DNS error (error 53) in the following step, then you have not opened port 445, or your ISP is blocking it.

Mount the Azure File Storage share as a local drive (for example T:).

Here is the command syntax:

dos

Copy
net use [drive letter] \\[storage name].file.core.windows.net\[share name] /u:[storage account name] [storage account access key]
Here's an example that assigns local drive letter T: to the Azure File Storage share:

dos

Copy
net use t: \\mystorage.file.core.windows.net\sharejson /u:myaccount hb5qy6eXLqIdBj0LvGMHdrTiygkjhHDvWjUZg3Gu7bubKLg==
You can find the storage account key and the primary or secondary storage account access key in the Keys section of Settings in the Azure portal.

Now you can access your JSON files from the Azure File Storage share by using the mapped drive, as shown in the following example:

SQL

Copy
SELECT book.* FROM
 OPENROWSET(BULK N't:\books\books.json', SINGLE_CLOB) AS json
 CROSS APPLY OPENJSON(BulkColumn)
 WITH( id nvarchar(100), name nvarchar(100), price float,
    pages_i int, author nvarchar(100)) AS book
For more info about Azure File Storage, see File storage.


*/
END
GO
/****** Object:  StoredProcedure [dbo].[InsertJsonToSqlFromAzBlob]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Written by: Emile Frser
	Date: 2020-10-01
	Description: Inserts json from Az Storage acccount

	EXEC  dbo.InsertJsonToSqlFromAzBlob 
*/
CREATE   PROCEDURE [dbo].[InsertJsonToSqlFromAzBlob] 
AS
BEGIN

	/* Dynamic SQL variable declaration */
	DECLARE 
		@sql_statement 			NVARCHAR(MAX)
	,	@sql_message 			NVARCHAR(MAX)
	,	@sql_parameter 			NVARCHAR(MAX)
	,	@sql_crlf				NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@sql_tab				NVARCHAR(1) = CHAR(9)
	,	@sql_execute			BIT = 1
	,	@sql_debug				BIT = 1	
	,	@sql_log				BIT = 1


	DECLARE
		@TargetSchema			SYSNAME
	,	@TargetTable			SYSNAME
	,	@err_log				NVARCHAR(MAX)

	IF (@sql_log = 1)
	BEGIN
		DECLARE @log TABLE (logmessage NVARCHAR(MAX))
	END

	-- Step1.  Obtain blob container name (@blobcontainer)
	DECLARE @blobcontainer NVARCHAR(MAX) = 'https://dmgrdiag.blob.core.windows.net/acazmetadatadb'
	
	--Step2. get shared access signature via storage explorer that looks like this (@sharedaccesssignatrue)
	--					?sv=2019-10-10&st=2020-10-04T00%.......
	DECLARE @sharedaccesssignatrue NVARCHAR(MAX) = '?sv=2019-10-10&st=2020-10-04T00%3A18%3A35Z&se=2020-10-05T00%3A18%3A35Z&sr=b&sp=rac&sig=jDed4%2FX2RUmdLaR2gZo7AdozA8iu83o8gJWBNb8eAlk%3D'

	--Step3. Get filename of the file (@filename)
	DECLARE @filename NVARCHAR(MAX) = 'arm_template.json'
	
	-- Step 4. Create database scoped credential (@dbscopedcredential)
	DECLARE @dbscopedcredential SYSNAME  = 'acazmetadatadbcred'

	--DROP DATABASE SCOPED CREDENTIAL acazmetadatadbcred

	SET @sql_statement = '
	CREATE DATABASE SCOPED CREDENTIAL ' + @dbscopedcredential + @sql_crlf + '
	WITH IDENTITY = ''SHARED ACCESS SIGNATURE'',
	SECRET = ''' + @sharedaccesssignatrue + '''';

	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC sp_executesql @stmt = @sql_statement
			INSERT INTO @log (logmessage) VALUES (@sql_message)
		END TRY
		BEGIN CATCH
			SET @err_log = (SELECT ERROR_MESSAGE())
			INSERT INTO @log (logmessage) VALUES (@err_log)
		END CATCH
	END
	IF (@sql_log = 1)
	BEGIN
		SELECT * FROM @log
	END

	-- Step 5. Create external datasource (@acazmetadatadbextsource)
	DECLARE @externaldatasource SYSNAME  = 'acazmetadatadbextsource'

--	DROP EXTERNAL DATA SOURCE acazmetadatadbextsource

	SET @sql_statement = '
	CREATE EXTERNAL DATA SOURCE ' + @externaldatasource + @sql_crlf + '
	WITH ( '+ @sql_crlf + '
		TYPE = BLOB_STORAGE,' + '
		LOCATION = ''' + @blobcontainer + ''',
		CREDENTIAL = ' + @dbscopedcredential + '
	)';

	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
	END
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC sp_executesql @stmt = @sql_statement
			INSERT INTO @log (logmessage) VALUES (@sql_message)
		END TRY
		BEGIN CATCH
			SET @err_log = (SELECT ERROR_MESSAGE())
			INSERT INTO @log (logmessage) VALUES (@err_log)
		END CATCH
	END
	IF (@sql_log = 1)
	BEGIN
		SELECT * FROM @log
	END


	-- Step 6. Insert JSON into a single columned table
	DROP TABLE IF EXISTS adf.armtest

	CREATE TABLE adf.armtest (testvalue nvarchar(max))

	SET @sql_statement = '
	BULK INSERT ' + QUOTENAME(@TargetSchema) + '.' + QUOTENAME(@TargetTable) + CHAR(13) + '
	FROM ''' + @filename + '' + CHAR(13)  + '
	WITH ( DATA_SOURCE = ''' + @externaldatasource + ''');'

	IF (@sql_debug = 1)
	BEGIN
		SET @sql_message = @sql_statement
	END
	IF (@sql_execute = 1)
	BEGIN
		BEGIN TRY
			EXEC sp_executesql @stmt = @sql_statement
			INSERT INTO @log (logmessage) VALUES (@sql_message)
		END TRY
		BEGIN CATCH
			SET @err_log = (SELECT ERROR_MESSAGE())
			INSERT INTO @log (logmessage) VALUES (@err_log)
		END CATCH
	END
	IF (@sql_log = 1)
	BEGIN
		SELECT * FROM @log
	END

	select * from adf.armtest

	
SELECT * FROM OPENROWSET(
   BULK 'arm_template.json',
   DATA_SOURCE = 'acazmetadatadb'
   , SINGLE_CLOB
   ) AS DataFile;   


END



GO
/****** Object:  StoredProcedure [dbo].[InsertJsonToSqlFromLocalFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Written by: Emile Frser
	Date: 2020-10-01
	Description: Inserts json to column/variable from local file 
*/


CREATE PROCEDURE [dbo].[InsertJsonToSqlFromLocalFile]
AS
BEGIN

DECLARE @json NVARCHAR(MAX)
-- Load file contents into a variable
SELECT @json = BulkColumn
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

-- Load file contents into a table 
SELECT BulkColumn
 INTO #temp 
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

 END
GO
/****** Object:  StoredProcedure [dbo].[Numbers_Create]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC PYROTOOLS.dbo.Numbers_Create
*/
CREATE   PROCEDURE [dbo].[Numbers_Create]
AS

DROP TABLE IF EXISTS dbo.Numbers

CREATE TABLE dbo.Numbers(n BIGINT)

;WITH e1(n) AS
(
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
)														-- 10
	,e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b)		-- 10*10
	,e3(n) AS (SELECT 1 FROM e1 CROSS JOIN e2 AS c)		-- 10*100
	,e4(n) AS (SELECT 1 FROM e1 CROSS JOIN e3 AS d)		-- 10*1000
	,e5(n) AS (SELECT 1 FROM e1 CROSS JOIN e4 AS e)		-- 10*10000
	,e6(n) AS (SELECT 1 FROM e1 CROSS JOIN e5 AS e)		-- 10*10000
INSERT  INTO 
	dbo.Numbers(n)
SELECT 
	n = ROW_NUMBER() OVER (ORDER BY n) 
FROM 
	e6 
ORDER BY 
	n

CREATE UNIQUE CLUSTERED INDEX 
	ucix_Numbers_n
ON 
	dbo.Numbers(n) 
WITH 
	(DATA_COMPRESSION = PAGE);
GO
/****** Object:  StoredProcedure [dbo].[ServerDiscovery]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ServerDiscovery]
AS 

SELECT 'BuildClrVersion' ColumnName, SERVERPROPERTY('BuildClrVersion') ColumnValue
UNION ALL
SELECT 'Collation', SERVERPROPERTY('Collation')
UNION ALL
SELECT 'CollationID', SERVERPROPERTY('CollationID')
UNION ALL
SELECT 'ComparisonStyle', SERVERPROPERTY('ComparisonStyle')
UNION ALL
SELECT 'ComputerNamePhysicalNetBIOS', SERVERPROPERTY('ComputerNamePhysicalNetBIOS')
UNION ALL
SELECT 'Edition', SERVERPROPERTY('Edition')
UNION ALL
SELECT 'EditionID', SERVERPROPERTY('EditionID')
UNION ALL
SELECT 'EngineEdition', SERVERPROPERTY('EngineEdition')
UNION ALL
SELECT 'InstanceName', SERVERPROPERTY('InstanceName')
UNION ALL
SELECT 'IsClustered', SERVERPROPERTY('IsClustered')
UNION ALL
SELECT 'IsFullTextInstalled', SERVERPROPERTY('IsFullTextInstalled')
UNION ALL
SELECT 'IsIntegratedSecurityOnly', SERVERPROPERTY('IsIntegratedSecurityOnly')
UNION ALL
SELECT 'IsSingleUser', SERVERPROPERTY('IsSingleUser')
UNION ALL
SELECT 'LCID', SERVERPROPERTY('LCID')
UNION ALL
SELECT 'LicenseType', SERVERPROPERTY('LicenseType')
UNION ALL
SELECT 'MachineName', SERVERPROPERTY('MachineName')
UNION ALL
SELECT 'NumLicenses', SERVERPROPERTY('NumLicenses')
UNION ALL
SELECT 'ProcessID', SERVERPROPERTY('ProcessID')
UNION ALL
SELECT 'ProductVersion', SERVERPROPERTY('ProductVersion')
UNION ALL
SELECT 'ProductLevel', SERVERPROPERTY('ProductLevel')
UNION ALL
SELECT 'ResourceLastUpdateDateTime', SERVERPROPERTY('ResourceLastUpdateDateTime')
UNION ALL
SELECT 'ResourceVersion', SERVERPROPERTY('ResourceVersion')
UNION ALL
SELECT 'ServerName', SERVERPROPERTY('ServerName')
UNION ALL
SELECT 'SqlCharSet', SERVERPROPERTY('SqlCharSet')
UNION ALL
SELECT 'SqlCharSetName', SERVERPROPERTY('SqlCharSetName')
UNION ALL
SELECT 'SqlSortOrder', SERVERPROPERTY('SqlSortOrder')
UNION ALL
SELECT 'SqlSortOrderName', SERVERPROPERTY('SqlSortOrderName')
GO
/****** Object:  StoredProcedure [dbo].[sp_alter_column]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_alter_column]
(
  @schemaname SYSNAME
  ,@tablename SYSNAME
  ,@columnname SYSNAME
  ,@columnrename SYSNAME = @columnname
  ,@datatype SYSNAME
  ,@executionmode bit = 0
)
AS BEGIN
  /*
    Author: Sergio Govoni https://www.linkedin.com/in/sgovoni/
    Version: 1.0
    License: MIT License
    Github repository: https://github.com/segovoni/sp_alter_column
    Documentation will coming soon!
  */

  -- Check input parameters
  IF (LTRIM(RTRIM(ISNULL(@schemaname, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter schema name (@schemaname) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@tablename, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter table name (@tablename) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@columnname, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter column name (@columnname) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@columnrename, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter column rename (@columnrename), if specified, it can not be empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@datatype, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter data type (@datatype) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF NOT EXISTS (SELECT
                   ORDINAL_POSITION
                 FROM
                   INFORMATION_SCHEMA.COLUMNS
                 WHERE
                   (TABLE_SCHEMA=@schemaname)
                   AND (TABLE_NAME=@tablename)
                   AND (COLUMN_NAME=@columnname))
  BEGIN
    RAISERROR(N'The object has not been found.', 16, 1);
    RETURN;
  END;

  -- Let's go!
  BEGIN TRY
    SET NOCOUNT ON;

    -- Create temporary table
    CREATE TABLE #tmp_usp_alter_column
    (
      schemaname SYSNAME NOT NULL
      ,tablename SYSNAME NOT NULL
      ,objecttype SYSNAME NOT NULL
      ,operationtype NVARCHAR(1) NOT NULL
      ,sqltext NVARCHAR(MAX) NOT NULL
    );

    -- Foreign key section
    -- Drop foreign key
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      schemap.name AS schemaname
      ,objp.name AS tablename
      ,'FK' AS objecttype
      ,'D' AS operationtype,
      ('ALTER TABLE [' + RTRIM(schemap.name) + '].[' + RTRIM(objp.name) + '] ' +
       'DROP CONSTRAINT [' + RTRIM(constr.name) + '];') AS sqltext
    FROM
      sys.foreign_key_columns AS fkc
    JOIN
      sys.objects AS objp ON objp.object_id=fkc.parent_object_id
    JOIN
      sys.schemas AS schemap ON objp.schema_id=schemap.schema_id
    JOIN
      sys.objects AS objr ON objr.object_id=fkc.referenced_object_id
    JOIN
      sys.schemas AS schemar ON objr.schema_id=schemar.schema_id
    JOIN
      sys.columns AS colr ON colr.column_id=fkc.referenced_column_id and colr.object_id=fkc.referenced_object_id
    JOIN
      sys.columns AS colp ON colp.column_id=fkc.parent_column_id and colp.object_id=fkc.parent_object_id
    JOIN
      sys.objects AS constr ON constr.object_id=fkc.constraint_object_id
    WHERE
      -- ToDo
      ((schemar.name=@schemaname) AND (objr.name=@tablename) AND (colr.name=@columnname) AND (objr.type='U')) OR
      ((schemap.name=@schemaname) AND (objp.name=@tablename) AND (colp.name=@columnname) AND (objr.type='U'));

    -- Create foreign key
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      schemap.name AS schemaname
      ,objp.name AS tablename
      ,'FK' AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(schemap.name) + '].[' + RTRIM(objp.name) + '] ' + 
        CASE (fk.is_not_trusted)
          WHEN 0 THEN 'WITH CHECK ADD CONSTRAINT [' + RTRIM(constr.name) + '] '
          WHEN 1 THEN 'WITH NOCHECK ADD CONSTRAINT [' + RTRIM(constr.name) + '] '
        END +
        'FOREIGN KEY ([' + RTRIM(colp.name) + '])' + ' ' +
        'REFERENCES [' + RTRIM(schemar.name) + '].[' + RTRIM(objr.name) + ']([' + RTRIM(colr.name) + ']);') AS sqltext
    FROM
      sys.foreign_key_columns AS fkc
    JOIN
      sys.foreign_keys AS fk ON fkc.constraint_object_id=fk.object_id
    JOIN
      sys.objects AS objp ON objp.object_id=fkc.parent_object_id
    JOIN
      sys.schemas AS schemap ON objp.schema_id=schemap.schema_id
    JOIN
      sys.objects AS objr ON objr.object_id=fkc.referenced_object_id
    JOIN
      sys.schemas AS schemar ON objr.schema_id=schemar.schema_id
    JOIN
      sys.columns AS colr ON colr.column_id=fkc.referenced_column_id and colr.object_id=fkc.referenced_object_id
    JOIN
      sys.columns AS colp ON colp.column_id=fkc.parent_column_id and colp.object_id=fkc.parent_object_id
    JOIN
      sys.objects AS constr ON constr.object_id=fkc.constraint_object_id
    WHERE
      -- ToDo
      /*
      (schemar.name=@schemaname)
      AND (objr.name=@tablename)
      AND (colr.name=@columnname)
      AND (objr.type='U');
      */
      ((schemar.name=@schemaname) AND (objr.name=@tablename) AND (colr.name=@columnname) AND (objr.type='U')) OR
      ((schemap.name=@schemaname) AND (objp.name=@tablename) AND (colp.name=@columnname) AND (objr.type='U'));

    -- Default constraints section
    -- Drop default constraints
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      S.name AS schemaname
      ,O.name AS tablename
      ,'DF' AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(S.name) + '].[' + RTRIM(O.name) + '] ' +
        'DROP [' + RTRIM(DC.name) + '];') AS sqltext
    FROM
      sys.default_constraints AS DC
    JOIN
      sys.objects AS O ON DC.parent_object_id=O.object_id
    JOIN
      sys.schemas AS S ON O.schema_id=S.schema_id
    JOIN
      sys.columns AS Col ON Col.default_object_id=DC.object_id
    WHERE
      (S.name=@schemaname)
      AND (O.name=@tablename)
      AND (Col.name=@columnname)
      AND (DC.type='D')
      AND (O.type='U');

    -- Create default constraints
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      S.name AS schemaname
      ,O.name AS tablename
      ,'DF' AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(S.name) + '].[' + RTRIM(O.name) + '] ' +
        'ADD CONSTRAINT [' + RTRIM(DC.name) + '] ' +
        'DEFAULT ' + DC.definition + ' ' +
        'FOR [' + Col.name + '];') AS sqltext
    FROM
      sys.default_constraints AS DC
    JOIN
      sys.objects AS O ON DC.parent_object_id=O.object_id
    JOIN
      sys.schemas AS S ON O.schema_id=S.schema_id
    JOIN
      sys.columns AS Col ON Col.default_object_id=DC.object_id
    WHERE
      (S.name=@schemaname)
      AND (O.name=@tablename)
      AND (Col.name=@columnname)
      AND (DC.type='D')
      AND (O.type='U');

    -- Unique constraints and Primary keys section
    -- Drop unique constraints and primary keys
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      KCU.TABLE_SCHEMA AS schemaname
      ,KCU.TABLE_NAME AS tablename
      -- ToDo: Keep fixed objecttype code 
      ,KC.type AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(KCU.TABLE_SCHEMA) + '].[' + RTRIM(KCU.TABLE_NAME) + '] ' +
        'DROP CONSTRAINT [' + RTRIM(KCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
    JOIN
      sys.key_constraints AS KC ON KCU.CONSTRAINT_NAME=KC.name
    WHERE
      (KCU.TABLE_SCHEMA=@schemaname)
      AND (KCU.TABLE_NAME=@tablename)
      AND (KCU.COLUMN_NAME=@columnname)
      AND ((KC.type='UQ') OR (KC.type='PK'));

    -- Create unique constraints and primary keys
    WITH UQC_PK AS
    (
      SELECT
        DISTINCT
        'A' AS rowtype
        -- ToDo: Keep fixed objecttype code
        ,K.type AS objecttype
        ,KCU.TABLE_CATALOG
        ,KCU.TABLE_SCHEMA
        ,KCU.TABLE_NAME
        ,KCU.CONSTRAINT_NAME
        ,CAST(0 AS INTEGER) AS ordinal_position
        ,CAST('' AS VARCHAR(MAX)) AS COLUMN_NAME
        ,CAST('ALTER TABLE [' + RTRIM(KCU.TABLE_SCHEMA) + '].[' + RTRIM(KCU.TABLE_NAME) + '] ' +
              (CASE (K.type)
                 WHEN 'PK' THEN 'WITH NOCHECK '
                 ELSE ''
               END)  +
              'ADD CONSTRAINT [' + RTRIM(KCU.CONSTRAINT_NAME) + '] ' +
              (CASE (K.type)
                 WHEN 'UQ' THEN 'UNIQUE'
                 WHEN 'PK' THEN 'PRIMARY KEY'
               END)  + '('AS VARCHAR(MAX)) AS sqltext
      FROM
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
      JOIN
        sys.key_constraints AS K ON KCU.CONSTRAINT_NAME=K.name
      WHERE
        (KCU.TABLE_SCHEMA=@schemaname) 
        AND (KCU.TABLE_NAME=@tablename) 
        AND (KCU.COLUMN_NAME=@columnname) 
        AND ((K.type='UQ') OR (K.type='PK')) 

      UNION ALL

      SELECT
        'R' AS rowtype
        ,U.objecttype
        ,U.TABLE_CATALOG
        ,U.TABLE_SCHEMA
        ,U.TABLE_NAME
        ,U.CONSTRAINT_NAME
        ,KCU2.ORDINAL_POSITION
        ,U.COLUMN_NAME
        ,CAST(U.sqltext +
              CASE (KCU2.ordinal_position)
                WHEN 1 THEN ''
                ELSE ','
              END + ' [' + RTRIM(KCU2.COLUMN_NAME) + '] ' AS VARCHAR(MAX)) AS sqltext
      FROM
        UQC_PK AS U
      JOIN
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU2 ON (U.TABLE_CATALOG=KCU2.TABLE_CATALOG)
                                                   AND (U.TABLE_SCHEMA=KCU2.TABLE_SCHEMA)
                                                   AND (U.TABLE_NAME=KCU2.TABLE_NAME)
                                                   AND (U.CONSTRAINT_NAME=KCU2.CONSTRAINT_NAME)
      WHERE (KCU2.ordinal_position=U.ordinal_position + 1)
    ),
    UQC_PK2 AS
    (
      SELECT
        MAX(UQC_PK.ordinal_position) AS maxordinalposition
        ,UQC_PK.objecttype
        ,UQC_PK.TABLE_SCHEMA
        ,UQC_PK.TABLE_NAME
        ,UQC_PK.CONSTRAINT_NAME
      FROM
        UQC_PK
      WHERE
        (UQC_PK.rowtype='R')
      GROUP BY
        UQC_PK.objecttype
        ,UQC_PK.TABLE_SCHEMA
        ,UQC_PK.TABLE_NAME
        ,UQC_PK.CONSTRAINT_NAME
    )
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      UQC_PK.TABLE_SCHEMA
      ,UQC_PK.TABLE_NAME
      ,UQC_PK.objecttype
      ,'C'
      ,UQC_PK.sqltext + ') '
    FROM
      UQC_PK2
    JOIN
      UQC_PK ON (UQC_PK.CONSTRAINT_NAME=UQC_PK2.CONSTRAINT_NAME)
            AND (UQC_PK.TABLE_SCHEMA=UQC_PK2.TABLE_SCHEMA)
            AND (UQC_PK.TABLE_NAME=UQC_PK2.TABLE_NAME)
            AND (UQC_PK.ordinal_position=UQC_PK2.maxordinalposition);

    -- Check constraints section
    -- Drop check constraints
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      -- ToDo: Keep fixed objecttype code
      ,CHK.type AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        'DROP CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C');

    -- Create (enabled) check constraints
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      ,CHK.type AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        CASE (CHK.is_not_trusted)
          WHEN 0 THEN 'WITH CHECK ADD CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '] CHECK ' + RTRIM(CHK.Definition) + ';'
          WHEN 1 THEN 'WITH NOCHECK ADD CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '] CHECK ' + RTRIM(CHK.Definition) + ';'END ) AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C');

    -- Create (disabled) check constraints
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      ,CHK.type AS objecttype
      ,'I' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        'NOCHECK CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C')
      AND (CHK.is_disabled=1);

    -- Statistics section
    -- Drop statistics
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      sch.name AS schemaname
      ,obj.name AS tablename
      ,'STATS' AS objecttype
      ,'D' AS operationtype
      ,'DROP STATISTICS [' + RTRIM(sch.name) + '].[' + RTRIM(obj.name) + '].[' + RTRIM(stat.name) + ']' AS SQLStr 
    FROM 
      sys.stats_columns AS statc 
    JOIN 
      sys.stats AS stat ON ((stat.stats_id=statc.stats_id) AND (stat.object_id=statc.object_id)) 
    JOIN 
      sys.objects AS obj ON statc.object_id=obj.object_id 
    JOIN 
      sys.columns AS col ON ((col.column_id=statc.column_id) AND (col.object_id=statc.object_id)) 
    JOIN 
      sys.schemas AS sch ON obj.schema_id=sch.schema_id 
    WHERE 
      (sch.name=@schemaname)
      AND (obj.name=@tablename)
      AND (col.name=@columnname)
      AND ((stat.auto_created=1) OR (stat.user_created=1))
      AND (obj.type='U');

    -- Create statistics
    WITH Stat AS 
    ( 
      SELECT 
        'A' AS RowType 
        ,T.object_id 
        ,T.stats_id 
        ,T.StatLevel 
        ,T.KeyOrdinal 
        ,T.SchemaName 
        ,T.TableName 
        ,CAST('CREATE ' +
              'STATISTICS [' + RTRIM(T.StatsName) + 
              '] ON [' + RTRIM(T.SchemaName) + 
              '].[' + RTRIM(T.TableName) +
              '] ( ' AS VARCHAR(MAX)) AS SQLStr 
      FROM 
      ( 
        SELECT 
          DISTINCT 
          stat.object_id 
          ,stat.stats_id 
          ,CAST(0 AS INTEGER) AS StatLevel 
          ,CAST(0 AS INTEGER) AS KeyOrdinal 
          ,stat.name AS StatsName 
          ,sch.name AS SchemaName 
          ,obj.name AS TableName 
        FROM 
          sys.stats_columns AS statc 
        JOIN 
          sys.stats AS stat ON ((stat.stats_id=statc.stats_id) 
                            AND (stat.object_id=statc.object_id)) 
        JOIN 
          sys.objects AS obj ON statc.object_id=obj.object_id 
        JOIN 
          sys.columns AS col ON ((col.column_id=statc.column_id) 
                             AND (col.object_id=statc.object_id)) 
        JOIN 
          sys.schemas AS sch ON obj.schema_id=sch.schema_id 
        WHERE 
          (sch.name=@schemaname)
          AND (obj.name=@tablename)
          AND (col.name=@columnname)
          AND (obj.type='U')
          AND ((stat.auto_created=1) OR (stat.user_created=1))
      ) AS T 

      UNION ALL 

      SELECT 
        'R' AS RowType 
        ,statcol.object_id 
        ,statcol.stats_id 
        ,CAST(S.StatLevel + 1 AS INTEGER) AS IdxLevel 
        ,CAST(statcol.stats_column_id AS INTEGER) KeyOrdinal 
        ,S.SchemaName 
        ,S.TableName 
        ,CAST(S.SQLStr + CASE (statcol.stats_column_id) WHEN 1 THEN '' ELSE ',' END + 
              ' [' + RTRIM(col.name) + 
              '] ' AS VARCHAR(MAX)) AS SQLStr 
      FROM 
        Stat AS S 
      JOIN 
        sys.stats_columns AS statcol ON ((statcol.object_id=S.object_id) 
                                     AND (statcol.stats_id=S.stats_id)) 
      JOIN 
        sys.columns AS col ON ((col.column_id=statcol.column_id) 
                           AND (col.object_id=statcol.object_id)) 
      WHERE 
        (statcol.stats_column_id=(S.KeyOrdinal + 1)) 
    ), 
    Stat2 AS 
    ( 
      SELECT 
        MAX(Stat.KeyOrdinal) AS MaxKeyOrdinal 
        ,Stat.object_id 
        ,Stat.stats_id 
      FROM 
        Stat 
      JOIN 
        sys.objects AS O ON O.object_id=Stat.object_id 
      WHERE 
        (Stat.RowType='R') 
      GROUP BY 
        Stat.object_id 
        ,Stat.stats_id 
    )
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      Stat.schemaname
      ,Stat.tablename
      ,'STATS' AS objecttype
      ,'C' AS operationtype
      ,Stat.SQLStr + ')'
    FROM 
      Stat2 
    JOIN 
      Stat ON ((Stat.object_id=Stat2.object_id) 
           AND (Stat.stats_id=Stat2.stats_id)) 
           AND (Stat.KeyOrdinal=Stat2.MaxKeyOrdinal);

    -- Indexes section
    -- Drop indexes
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      sch.name
      ,obj.name
      ,'IDX' AS objecttype
      ,'D' AS operationtype
      ,('DROP INDEX [' + RTRIM(sch.name) + '].[' + RTRIM(obj.name) + '].[' + RTRIM(idx.name) + '];') AS sqltext
    FROM
      sys.index_columns AS idxc
    JOIN
      sys.indexes AS idx ON ((idx.index_id=idxc.index_id)
                         AND (idx.object_id=idxc.object_id))
    JOIN
      sys.objects AS obj ON idxc.object_id=obj.object_id
    JOIN
      sys.columns AS col ON ((col.column_id=idxc.column_id)
                         AND (col.object_id=idxc.object_id))
    JOIN
      sys.schemas AS sch ON obj.schema_id=sch.schema_id
    WHERE
      (sch.name=@schemaname)
      AND (obj.name=@tablename)
      AND (col.name=@columnname)
      AND (idx.is_unique_constraint=0)
      AND (idx.is_primary_key=0)
      AND (obj.type='U')
    ORDER BY
      sqltext;

    -- Create indexes
    WITH Create_Indexes AS
    (
      SELECT
        'A' AS rowtype
        ,T.object_id
        ,T.index_id
        ,T.IdxLevel
        ,T.KeyOrdinal
        ,T.IsUnique
        ,T.IsClustered
        ,T.SchemaName
        ,T.TableName
        ,CAST('CREATE ' + T.IsUnique + T.IsClustered +
              'INDEX [' + RTRIM(T.IndexName) + '] ON [' + RTRIM(T.SchemaName) + '].[' +
              RTRIM(T.TableName) + '] ( 'AS VARCHAR(MAX)) AS sqltext
      FROM
        (SELECT
           DISTINCT
           idx.object_id
           ,idx.index_id
           ,CAST(0 AS INTEGER) AS IdxLevel
           ,CAST(0 AS INTEGER) AS KeyOrdinal
           ,CAST(CASE (idx.is_unique)
                   WHEN 1 THEN 'UNIQUE '
                   WHEN 0 THEN ''
                   ELSE ''
                 END AS VARCHAR(MAX)) AS IsUnique
           ,CAST(CASE (idx.type)
                   WHEN 1 THEN 'CLUSTERED '
                   WHEN 2 THEN 'NONCLUSTERED '
                   ELSE ''
                 END AS VARCHAR(MAX)) AS IsClustered
           ,idx.name AS IndexName
           ,sch.name AS SchemaName
           ,obj.name AS TableName
         FROM
           sys.index_columns AS idxc
         JOIN
           sys.indexes AS idx ON ((idx.index_id=idxc.index_id) AND (idx.object_id=idxc.object_id))
         JOIN
           sys.objects AS obj ON idxc.object_id=obj.object_id
         JOIN
           sys.columns AS col ON ((col.column_id=idxc.column_id) AND (col.object_id=idxc.object_id))
         JOIN
           sys.schemas AS sch ON obj.schema_id=sch.schema_id
         WHERE
           (sch.name=@schemaname)
           AND (obj.name=@tablename)
           AND (col.name=@columnname)
           AND (idx.is_unique_constraint=0)
           AND (idx.is_primary_key=0)
           AND (obj.type='U')
           AND NOT EXISTS (SELECT
                             [object_id]
                           FROM
                             sys.index_columns AS ic
                           WHERE (ic.is_included_column=1)
                             AND (idxc.[object_id]=ic.[object_id])
                             AND (idxc.index_id=ic.index_id)
                          )
        ) AS T
             
      UNION ALL 
      
      SELECT
        'R' AS RowType
        ,idxcol.object_id
        ,idxcol.index_id
        ,CAST(I.IdxLevel + 1 AS INTEGER) AS IdxLevel
        ,CAST(idxcol.key_ordinal AS INTEGER) AS KeyOrdinal
        ,CAST('' AS VARCHAR(MAX)) AS IsUnique
        ,CAST('' AS VARCHAR(MAX)) AS IsClustered
        ,I.SchemaName
        ,I.TableName
        ,CAST(I.sqltext + CASE (idxcol.key_ordinal)
                            WHEN 1 THEN ''
                            ELSE ','
                          END + ' [' + RTRIM(col.name) + '] ' AS VARCHAR(MAX)) AS sqltext
      FROM
        Create_Indexes AS I
      JOIN
        sys.index_columns AS idxcol ON ((idxcol.object_id=I.object_id) AND (idxcol.index_id=I.index_id))
      JOIN
        sys.columns AS col ON ((col.column_id=idxcol.column_id) AND (col.object_id=idxcol.object_id))
      WHERE
        (idxcol.key_ordinal=I.KeyOrdinal + 1)
    ),
    Create_Indexes2 AS
    (
      SELECT
        MAX(Create_Indexes.KeyOrdinal) AS MaxKeyOrdinal
        ,Create_Indexes.object_id
        ,Create_Indexes.index_id
      FROM
        Create_Indexes
      JOIN
        sys.objects AS O ON (O.object_id=Create_Indexes.object_id)
      WHERE
        (Create_Indexes.RowType='R')
      GROUP BY
        Create_Indexes.object_id
        ,Create_Indexes.index_id
    )
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      Create_Indexes.SchemaName
      ,Create_Indexes.TableName
      ,'IDX' AS objecttype
      ,'C' AS operationtype
      ,Create_Indexes.sqltext + ')'
    FROM
      Create_Indexes2
    JOIN
      Create_Indexes ON ((Create_Indexes.object_id=Create_Indexes2.object_id)
                     AND (Create_Indexes.index_id=Create_Indexes2.index_id)
                     AND (Create_Indexes.KeyOrdinal=Create_Indexes2.MaxKeyOrdinal));

    -- Views section
    -- Refresh views
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      V.TABLE_SCHEMA
      ,V.TABLE_NAME
      ,'VW' AS objecttype
      ,'R' AS OperationType
      ,('EXECUTE sp_refreshview ''[' + RTRIM(V.TABLE_SCHEMA) + '].[' + RTRIM(V.TABLE_NAME) + ']'';') AS sqltext
    FROM
      INFORMATION_SCHEMA.VIEWS AS V
    WHERE
      (V.IS_UPDATABLE='NO');

    DECLARE
      @sqldrop NVARCHAR(MAX) = ''
      --,@sqldropfk NVARCHAR(MAX) = ''
      --,@sqldroppk NVARCHAR(MAX) = ''
      --,@sqldropuq NVARCHAR(MAX) = ''
      --,@sqldropck NVARCHAR(MAX) = ''
      --,@sqldropdf NVARCHAR(MAX) = ''
      --,@sqldropidx NVARCHAR(MAX) = ''
      --,@sqldropstats NVARCHAR(MAX) = ''

      ,@sqlcreate NVARCHAR(MAX) = ''
      --,@sqlcreatefk NVARCHAR(MAX) = ''
      --,@sqlcreatepk NVARCHAR(MAX) = ''
      --,@sqlcreateuq NVARCHAR(MAX) = ''
      --,@sqlcreateck NVARCHAR(MAX) = ''
      --,@sqlcreatedf NVARCHAR(MAX) = ''
      --,@sqlcreateidx NVARCHAR(MAX) = ''
      --,@sqlcreatestats NVARCHAR(MAX) = ''

      ,@sqlaltertable NVARCHAR(MAX) = ''
      ,@sqlrenametable NVARCHAR(MAX) = ''

      ,@crlf NVARCHAR(2) = CHAR(13)+CHAR(10)
      ,@trancount INTEGER = @@TRANCOUNT
      ,@olddatatype SYSNAME
      --,@tmpNewDataType SYSNAME;

    --------------------------------------------------------
    -- DROP statements for the following objects
    --
    -- Foreign key (FK)
    -- Primary key (PK)
    -- Unique constraints (UQ)
    -- Check constraints (CK)
    -- Default constraints (DF)
    -- Indexes (not related to unique constraints, IDX)
    -- Statistics
    --------------------------------------------------------

    IF (@executionmode = 1)
    BEGIN
      IF (@trancount = 0)
        -- Opening an explicit transaction to avoid auto commits
        BEGIN TRANSACTION
    END

    DECLARE C_SQL_DROP CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='FK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='PK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='UQ')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='CK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='DF')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='IDX')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='STATS')
        AND (operationtype='D');
    
    OPEN C_SQL_DROP;

    -- First fetch
    FETCH NEXT FROM C_SQL_DROP INTO @sqldrop

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      IF (@executionmode = 0)
        PRINT(@sqldrop);
      ELSE IF (@executionmode = 1)
        EXEC(@sqldrop);
      FETCH NEXT FROM C_SQL_DROP INTO @sqldrop
    END;
    
    CLOSE C_SQL_DROP;
    DEALLOCATE C_SQL_DROP;

    SET @sqlaltertable = 'ALTER TABLE [' + @schemaname + '].[' + @tablename + 
                         '] ALTER COLUMN [' + @columnname + 
                         '] ' + @datatype + ';' + @CRLF;

    -- ALTER TABLE
    INSERT INTO #tmp_usp_alter_column
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    ) VALUES
    (
      @schemaname
      ,@tablename
      ,'COL'
      ,'A'
      ,@sqlaltertable
    );
	  
    IF (@executionmode = 0)
      PRINT(@sqlaltertable);
    ELSE IF (@executionmode = 1)
      EXEC(@sqlaltertable);

    IF (@columnname <> @columnrename) AND
       (LTRIM(RTRIM(@columnrename)) <> '')
    BEGIN
      SET @sqlrenametable = 'EXEC sp_rename ''[' + @schemaname + '].[' + @tablename +'].[' + @columnname + ']'', ''[' +
                                                   @schemaname + '].[' + @tablename +'].[' + @columnrename + ']''' + @CRLF;	  

      -- Rename
      INSERT INTO #tmp_usp_alter_column
      (
        schemaname
        ,tablename
        ,objecttype
        ,operationtype
        ,sqltext
      ) VALUES
      (
        @schemaname
        ,@tablename
        ,'COL'
        ,'R'
        ,@sqlrenametable
      );

      IF (@executionmode = 0)
        PRINT(@sqlrenametable);
      ELSE IF (@executionmode = 1)
        EXEC(@sqlrenametable);
    END;

    --------------------------------------------------------
    -- CREATE statements for the following objects
    --
    -- Foreign key (FK)
    -- Primary key (PK)
    -- Unique constraints (UQ)
    -- Check constraints (CK)
    -- Default constraints (DF)
    -- Indexes (not related to unique constraints, IDX)
    -- Statistics
    --------------------------------------------------------
    DECLARE C_SQL_CREATE CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='FK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='PK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='UQ')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='CK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='DF')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='IDX')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_usp_alter_column
      WHERE
        (objecttype='STATS')
        AND (operationtype='C');
    
    OPEN C_SQL_CREATE;

    -- First fetch
    FETCH NEXT FROM C_SQL_CREATE INTO @sqlcreate

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      IF (@executionmode = 0)
        PRINT(@sqlcreate);
      ELSE IF (@executionmode = 1)
        EXEC(@sqlcreate);

      FETCH NEXT FROM C_SQL_CREATE INTO @sqlcreate;
    END;
    
    CLOSE C_SQL_CREATE;
    DEALLOCATE C_SQL_CREATE;

    --PRINT(@sqldropfk + @sqldroppk + @sqldropuq + @sqldropck + @sqldropdf + @sqldropidx + @sqldropstats);
    --PRINT(@sqlcreatefk + @sqlcreatepk + @sqlcreateuq + @sqlcreateck + @sqlcreatedf + @sqlcreateidx + @sqlcreatestats);
    IF (@executionmode = 0)
      SELECT * FROM #tmp_usp_alter_column;

    IF (@executionmode = 1) AND
       (@trancount = 0) AND
       (@@ERROR = 0)
      COMMIT TRANSACTION;

    SET NOCOUNT OFF;
  END TRY
  BEGIN CATCH
    IF (@executionmode = 1) AND
       (@trancount = 0)
      ROLLBACK TRANSACTION;

    -- Error handling
    DECLARE
      @ErrorMessage NVARCHAR(MAX)
      ,@ErrorSeverity INTEGER
      ,@ErrorState INTEGER;

    SELECT 
      @ErrorMessage = ERROR_MESSAGE()
      ,@ErrorSeverity = ERROR_SEVERITY()
      ,@ErrorState = ERROR_STATE();

    SET NOCOUNT OFF;

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[SplitSingleValueIntoRows]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SPLITS a CLOB or single value into rows
-- EXEC [dbo].[SplitSingleValueIntoRows]
CREATE   PROCEDURE [dbo].[SplitSingleValueIntoRows]--(
	--  @DatasourceName				NVARCHAR(MAX)
	--, @RelativeFilePath				NVARCHAR(MAX)
	--, @EndOfLineDelimeter			NVARCHAR(2)
	--, @EndOfFieldDelimeter			NVARCHAR(2)
--) 
--RETURNS TABLE
AS
BEGIN
--RETURN

	DECLARE @crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
	declare @RelativeFilePath NVARCHAR(MAX) = 'sample/csv/sample1.csv'
	declare @DatasourceName NVARCHAR(MAX) = 'AcAzDevelopmentSampleDataSource'
	DECLARE @xml XML
	
	SELECT @xml =
		--value 
	--FROM 
		--STRING_SPLIT((
		--		SELECT 
					BulkColumn 
				FROM 
					OPENROWSET (
						BULK '@RelativeFilePath'
					--,	DATA_SOURCE = @DatasourceName
					,	SINGLE_CLOB
					)  AS rowset;
		--	), @crlf)
	--)
	SELECT @xml;

END
GO
/****** Object:  StoredProcedure [dbo].[String_or_binary_data_truncated]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[String_or_binary_data_truncated]
@String VARCHAR(MAX)
AS
 
DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
             ,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST(('<a>'+REPLACE(@String,'(','</a><a>')
           +'</a>') AS XML)
 
SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)
 
;WITH CTE AS
     (SELECT
     (CASE
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))>0)
     THEN 1
     WHEN CHARINDEX('VALUES',A.value('.', 'varchar(max)'))>0
     THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=2  THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=3  THEN 3
     END) AS[Batch Number],
     REPLACE(REPLACE(A.value('.', 'varchar(max)')
     ,'INSERT INTO',''),'VALUES ','') AS [Column]
     FROM @Xml.nodes('A') AS FN(A))
 
, [CTE2] AS
(
    SELECT
    [Batch Number],
    CAST('' + REPLACE([Column], ',' , '')
    + '' AS XML)
    AS [Column name And Data]
    FROM  [CTE]
)
,[CTE3] AS
(
    SELECT [Batch Number],
    ROW_NUMBER() OVER(PARTITION BY [Batch Number]
    ORDER BY [Batch Number] DESC) AS [Row Number],
    Split.a.value('.', 'VARCHAR(MAX)') AS [Column name And Data]
FROM [CTE2]
CROSS APPLY [Column name And Data].nodes('/M')Split(A))
 
SELECT
 ISNULL(B.[Column name And Data],C.name) AS [Column Name]
,A.[Column name And Data] AS [Column Data]
,C.max_length As [Column Length]
,DATALENGTH(A.[Column name And Data])
AS [Column Data Length]
 
FROM [CTE3] A
LEFT JOIN [CTE3] B
ON A.[Batch Number]=2 AND B.[Batch Number]=3
AND A.[Row Number] =B.[Row Number]
LEFT JOIN sys.columns C
ON C.object_id =(
    SELECT object_ID(LTRIM(RTRIM([Column name And Data])))
    FROM [CTE3] WHERE [Batch Number]=1
)
AND (C.name = B.[Column name And Data]
OR  (C.column_id =A.[Row Number]
And A.[Batch Number]<>1))
WHERE a.[Batch Number] <>1
AND DATALENGTH(A.[Column name And Data]) >C.max_length
AND C.system_type_id IN (167,175,231,239)
AND C.max_length>0
 

GO
/****** Object:  StoredProcedure [dbo].[StringOrBinaryTruncated]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CREATE SCHEMA tool
--go

--String or binary data would be truncated (Error number 8152) is a very common error. It usually happens when we try to insert any data in string (varchar,nvarchar,char,nchar) data type column which is more than size of the column. So you need to check the data size with respect to the column width and identify which column is creating problem and fix it. It is very simple if you are dealing with less columns in a table. But it becomes nightmare if you are dealing with inert into query with huge number of columns and you need to check one by one column. I received this query from one of my Blog readers Mr Ram Kumar asking if there is a shortcut to resolve this issue and give the column name along with the data creating problems. I started searching for the solution but could not get proper one. So I started developing this solution.
--Before proceeding with the solution, I would like to create a sample to demonstrate the problem.

--This script is compatible with SQL Server 2005 and above.
--DROP TABLE tbl_sample
--GO
--CREATE TABLE dbo.tbl_sample
--(
-- [ID] INT,
-- [NAME] VARCHAR(10),
--)
--GO
--INSERT INTO tool.tbl_sample VALUES (1,'Bob Jack Creasey')
--GO
--INSERT INTO tool.tbl_sample ([ID],[NAME]) VALUES (2,'Frank Richard Wedge')
--GO
--OUTPUT
--Msg 8152, Level 16, State 14, Line 1
--String or binary data would be truncated.
--The statement has been terminated.
--Msg 8152, Level 16, State 14, Line 2
--String or binary data would be truncated.
--The statement has been terminated.

--DROP PROCEDURE usp_String_or_binary_data_truncated
--GO
CREATE   PROCEDURE [dbo].[StringOrBinaryTruncated]
	@String VARCHAR(MAX)
AS
 
DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
             ,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST(('<a>'+REPLACE(@String,'(','</a><a>')
           +'</a>') AS XML)
 
SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)
 
;WITH CTE AS
     (SELECT
     (CASE
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))>0)
     THEN 1
     WHEN CHARINDEX('VALUES',A.value('.', 'varchar(max)'))>0
     THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=2  THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=3  THEN 3
     END) AS[Batch Number],
     REPLACE(REPLACE(A.value('.', 'varchar(max)')
     ,'INSERT INTO',''),'VALUES ','') AS [Column]
     FROM @Xml.nodes('A') AS FN(A))
 
, [CTE2] AS
(
    SELECT
    [Batch Number],
    CAST('' + REPLACE([Column], ',' , '')
    + '' AS XML)
    AS [Column name And Data]
    FROM  [CTE]
)
,[CTE3] AS
(
    SELECT [Batch Number],
    ROW_NUMBER() OVER(PARTITION BY [Batch Number]
    ORDER BY [Batch Number] DESC) AS [Row Number],
    Split.a.value('.', 'VARCHAR(MAX)') AS [Column name And Data]
FROM [CTE2]
CROSS APPLY [Column name And Data].nodes('/M')Split(A))
 
SELECT
 ISNULL(B.[Column name And Data],C.name) AS [Column Name]
,A.[Column name And Data] AS [Column Data]
,C.max_length As [Column Length]
,DATALENGTH(A.[Column name And Data])
AS [Column Data Length]
 
FROM [CTE3] A
LEFT JOIN [CTE3] B
ON A.[Batch Number]=2 AND B.[Batch Number]=3
AND A.[Row Number] =B.[Row Number]
LEFT JOIN sys.columns C
ON C.object_id =(
    SELECT object_ID(LTRIM(RTRIM([Column name And Data])))
    FROM [CTE3] WHERE [Batch Number]=1
)
AND (C.name = B.[Column name And Data]
OR  (C.column_id =A.[Row Number]
And A.[Batch Number]<>1))
WHERE a.[Batch Number] <>1
AND DATALENGTH(A.[Column name And Data]) >C.max_length
AND C.system_type_id IN (167,175,231,239)
AND C.max_length>0
 


EXEC dbo.GetStringOrBinaryTruncated 'INSERT INTO tbl_sample VALUES (1,''Bob Jack Creasey'')'
GO
/****** Object:  StoredProcedure [dbo].[usp_String_or_binary_data_truncated]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--–DROP PROCEDURE usp_String_or_binary_data_truncated
--–GO
CREATE   PROCEDURE [dbo].[usp_String_or_binary_data_truncated]
@String VARCHAR(MAX)
AS

DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST((''+REPLACE(@String,'(','')
+'') AS XML)

SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)

;WITH CTE AS
(SELECT
(CASE
WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))>0)
THEN 1
WHEN CHARINDEX('VALUES',A.value('.', 'varchar(max)'))>0
THEN 2
WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
AND @TCount=2 THEN 2
WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
AND @TCount=3 THEN 3
END) AS[Batch Number],
REPLACE(REPLACE(A.value('.', 'varchar(max)')
,'INSERT INTO',''),'VALUES ','') AS [Column]
FROM @Xml.nodes('A') AS FN(A))

, [CTE2] AS
(
SELECT
[Batch Number],
CAST('' + REPLACE([Column], ',' , '')
+ '' AS XML)
AS [Column name And Data]
FROM [CTE]
)
,[CTE3] AS
(
SELECT [Batch Number],
ROW_NUMBER() OVER(PARTITION BY [Batch Number]
ORDER BY [Batch Number] DESC) AS [Row Number],
Split.a.value('.', 'VARCHAR(MAX)') AS [Column name And Data]
FROM [CTE2]
CROSS APPLY [Column name And Data].nodes('/M')Split(A))

SELECT
ISNULL(A.[Column name And Data],C.name) AS [Column Name]
,B.[Column name And Data] AS [Column Data]
,C.max_length As [Column Length]
,DATALENGTH(B.[Column name And Data])
AS [Column Data Length]

FROM [CTE3] A
LEFT JOIN [CTE3] B
ON A.[Batch Number]=2 AND B.[Batch Number]=3
AND A.[Row Number] =B.[Row Number]
LEFT JOIN sys.columns C
ON C.object_id =(
SELECT object_ID(LTRIM(RTRIM([Column name And Data])))
FROM [CTE3] WHERE [Batch Number]=1
)
AND (C.name = LTRIM(RTRIM(A.[Column name And Data]))
OR (C.column_id =A.[Row Number]
And A.[Batch Number]=1))
WHERE a.[Batch Number]= 1
AND DATALENGTH(B.[Column name And Data]) >C.max_length
AND C.system_type_id IN (167,175,231,239)
AND C.max_length>0
GO
/****** Object:  StoredProcedure [inout].[BulkInsertBlob]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Here the Stored procedure have 3 parameters 

Delimited_FilePath - The name of the CSV File that already in the blob container
SAS_Token - For accessing any blob within the container (Private container) we need a SAS token. (You can refer here on how to generate the SAS token)
Location - The URL of the Azure Storage Account along with the container

exec BulkInsertBlob 'inputblob.csv','st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D','https://testingstorageaccount.blob.core.windows.net/testing'
The parameters we are using are:

?Storage Account Name: https://testingstorageaccount.blob.core.windows.net/
Container Name: testing
SAS Token: st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D
FileName: inputblob.csv
*/


CREATE   PROCEDURE [inout].[BulkInsertBlob]
(
 @SchemaName SYSNAME ,
 @Tablename SYSNAME,
 @Delimited_FilePath VARCHAR(300), 
 @SAS_Token  VARCHAR(MAX),
 @Location  VARCHAR(MAX)
)
AS
BEGIN
 
BEGIN TRY
 
 --Create new External Data Source & Credential for the Blob, custom for the current upload
 DECLARE @CrtDSSQL NVARCHAR(MAX), @DrpDSSQL NVARCHAR(MAX), @ExtlDS SYSNAME, @DBCred SYSNAME, @BulkInsSQL NVARCHAR(MAX) ;
 
 SELECT @ExtlDS = 'MyAzureBlobStorage'
 SELECT @DBCred = 'MyAzureBlobStorageCredential'
 
 SET @DrpDSSQL = N'
 IF EXISTS ( SELECT 1 FROM sys.external_data_sources WHERE Name = ''' + @ExtlDS + ''' )
 BEGIN
 DROP EXTERNAL DATA SOURCE ' + @ExtlDS + ' ;
 END;
 
 IF EXISTS ( SELECT 1 FROM sys.database_scoped_credentials WHERE Name = ''' + @DBCred + ''' )
 BEGIN
 DROP DATABASE SCOPED CREDENTIAL ' + @DBCred + ';
 END;
 ';
 
 SET @CrtDSSQL = @DrpDSSQL + N'
 CREATE DATABASE SCOPED CREDENTIAL ' + @DBCred + '
 WITH IDENTITY = ''SHARED ACCESS SIGNATURE'',
 SECRET = ''' + @SAS_Token + ''';
 
 CREATE EXTERNAL DATA SOURCE ' + @ExtlDS + '
 WITH (
 TYPE = BLOB_STORAGE,
 LOCATION = ''' + @Location + ''' ,
 CREDENTIAL = ' + @DBCred + '
 );
 ';
 
 --PRINT @CrtDSSQL
 EXEC (@CrtDSSQL);
 
  
 --Bulk Insert the data from CSV file into interim table
 SET @BulkInsSQL = N'
 BULK INSERT ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
 FROM ''' + @Delimited_FilePath + '''
 WITH ( DATA_SOURCE = ''' + @ExtlDS + ''',
 Format=''CSV'',
 FIELDTERMINATOR = '','',
 --ROWTERMINATOR = ''\n''
 ROWTERMINATOR = ''0x0a''
 );
 ';
 
 --PRINT @BulkInsSQL
 EXEC (@BulkInsSQL);
 
 END TRY
 BEGIN CATCH
 
 PRINT @@ERROR
 END CATCH
 END;
GO
/****** Object:  StoredProcedure [inout].[ns_txt_file_read]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @t VARCHAR(MAX) 
EXEC ns_txt_file_read 'c:\temp\SampleTextDoc.txt', @t output 
SELECT @t AS [SampleTextDoc.txt]  
*/
CREATE PROC [inout].[ns_txt_file_read]  
    @os_file_name NVARCHAR(256) 
   ,@text_file VARCHAR(MAX) OUTPUT  
/* Reads a text file into @text_file 
* 
* Transactions: may be in a transaction but is not affected 
* by the transaction. 
* 
* Error Handling: Errors are not trapped and are thrown to 
* the caller. 
* 
* Example: 
    declare @t varchar(max) 
    exec ns_txt_file_read 'c:\temp\SampleTextDoc.txt', @t output 
    select @t as [SampleTextDoc.txt] 
* 
* History: 
* WHEN       WHO        WHAT 
* ---------- ---------- --------------------------------------- 
* 2007-02-06 anovick    Initial coding 
**************************************************************/  
AS  
DECLARE @sql NVARCHAR(MAX) 
      , @parmsdeclare NVARCHAR(4000)  

SET NOCOUNT ON  

SET @sql = 'select @text_file=(select * from openrowset ( 
           bulk ''' + @os_file_name + ''' 
           ,SINGLE_CLOB) x 
           )' 

SET @parmsdeclare = '@text_file varchar(max) OUTPUT'  

EXEC sp_executesql @stmt = @sql 
                 , @params = @parmsdeclare 
                 , @text_file = @text_file OUTPUT 
GO
/****** Object:  StoredProcedure [inout].[SetJsonArmIn]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [inout].[SetJsonArmIn] @JsonString [nvarchar](max) AS
BEGIN
	TRUNCATE TABLE [inout].[JsonArmIn]

	INSERT INTO inout.[JsonArmIn] ([JsonArmString])
	SELECT @JsonString 

END

select * from [inout].[JsonArmIn]
GO
/****** Object:  StoredProcedure [inout].[SetJsonIn]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [inout].[SetJsonIn] @JsonString [nvarchar](max) AS
BEGIN
	TRUNCATE TABLE [inout].[JsonIn]

	INSERT INTO inout.JsonIn (JsonString)
	SELECT @JsonString 

END
GO
/****** Object:  StoredProcedure [inout].[XmlFileImport]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [inout].[XmlFileImport]

(

	@XML_FILE NVARCHAR(MAX)

)

AS

-- Setup XML variable to be used to hold contents of XML file.

DECLARE @xml XML 

/* Read the XML file into the XML variable.  This is done via a bulk insert using the OPENROWSET()

function.   Because this stored proc is to be re-used with different XML files, ideally you want to pass

the XML file path as a variable.  However, because the OPENROWSET() function won't accept

variables as a parameter, the command needs to be built as a string and then passed to the

sp_executesql system stored procedure.  The results are then passed back by an output variable.

*/

-- The command line

DECLARE @COMMAND NVARCHAR(MAX)

-- The definition of the parameters used within the command line

DECLARE @PARAM_DEF NVARCHAR(500)

-- The parameter used to pass the file name into the command

DECLARE @FILEVAR NVARCHAR(MAX)

-- The output variable that holds the results of the OPENROWSET()

DECLARE @XML_OUT XML 

SET @FILEVAR = @XML_FILE

SET @PARAM_DEF = N'@XML_FILE NVARCHAR(MAX), @XML_OUT XML OUTPUT'

SET @COMMAND = N'SELECT @XML_OUT = BulkColumn FROM OPENROWSET(BULK ''' +  @XML_FILE + ''', SINGLE_BLOB) ROW_SET';

EXEC sp_executesql @COMMAND, @PARAM_DEF, @XML_FILE = @FILEVAR,@XML_OUT = @xml OUTPUT;

--SELECT @xml
GO
/****** Object:  StoredProcedure [mssql].[ShowDateType]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [mssql].[ShowDateType]
AS 
BEGIN
-- SQL Server string to date / datetime conversion - datetime string format sql server

-- MSSQL string to datetime conversion - convert char to date - convert varchar to date

-- Subtract 100 from style number (format) for yy instead yyyy (or ccyy with century)

SELECT convert(datetime, 'Oct 23 2012 11:01AM', 100) -- mon dd yyyy hh:mmAM (or PM)

SELECT convert(datetime, 'Oct 23 2012 11:01AM') -- 2012-10-23 11:01:00.000

 

-- Without century (yy) string date conversion - convert string to datetime function

SELECT convert(datetime, 'Oct 23 12 11:01AM', 0) -- mon dd yy hh:mmAM (or PM)

SELECT convert(datetime, 'Oct 23 12 11:01AM') -- 2012-10-23 11:01:00.000

 

-- Convert string to datetime sql - convert string to date sql - sql dates format

-- T-SQL convert string to datetime - SQL Server convert string to date

SELECT convert(datetime, '10/23/2016', 101) -- mm/dd/yyyy

SELECT convert(datetime, '2016.10.23', 102) -- yyyy.mm.dd ANSI date with century

SELECT convert(datetime, '23/10/2016', 103) -- dd/mm/yyyy

SELECT convert(datetime, '23.10.2016', 104) -- dd.mm.yyyy

SELECT convert(datetime, '23-10-2016', 105) -- dd-mm-yyyy

-- mon types are nondeterministic conversions, dependent on language setting

SELECT convert(datetime, '23 OCT 2016', 106) -- dd mon yyyy

SELECT convert(datetime, 'Oct 23, 2016', 107) -- mon dd, yyyy

-- 2016-10-23 00:00:00.000

SELECT convert(datetime, '20:10:44', 108) -- hh:mm:ss

-- 1900-01-01 20:10:44.000

 

-- mon dd yyyy hh:mm:ss:mmmAM (or PM) - sql time format - SQL Server datetime format

SELECT convert(datetime, 'Oct 23 2016 11:02:44:013AM', 109)

-- 2016-10-23 11:02:44.013

SELECT convert(datetime, '10-23-2016', 110) -- mm-dd-yyyy

SELECT convert(datetime, '2016/10/23', 111) -- yyyy/mm/dd

-- YYYYMMDD ISO date format works at any language setting - international standard

SELECT convert(datetime, '20161023')

SELECT convert(datetime, '20161023', 112) -- ISO yyyymmdd

-- 2016-10-23 00:00:00.000

SELECT convert(datetime, '23 Oct 2016 11:02:07:577', 113) -- dd mon yyyy hh:mm:ss:mmm

-- 2016-10-23 11:02:07.577

SELECT convert(datetime, '20:10:25:300', 114) -- hh:mm:ss:mmm(24h)

-- 1900-01-01 20:10:25.300

SELECT convert(datetime, '2016-10-23 20:44:11', 120) -- yyyy-mm-dd hh:mm:ss(24h)

-- 2016-10-23 20:44:11.000

SELECT convert(datetime, '2016-10-23 20:44:11.500', 121) -- yyyy-mm-dd hh:mm:ss.mmm

-- 2016-10-23 20:44:11.500

 

-- Style 126 is ISO 8601 format: international standard - works with any language setting

SELECT convert(datetime, '2008-10-23T18:52:47.513', 126) -- yyyy-mm-ddThh:mm:ss(.mmm)

-- 2008-10-23 18:52:47.513

SELECT convert(datetime, N'23 ???? 1429  6:52:47:513PM', 130) -- Islamic/Hijri date

SELECT convert(datetime, '23/10/1429  6:52:47:513PM',    131) -- Islamic/Hijri date

 

-- Convert DDMMYYYY format to datetime - sql server to date / datetime

SELECT convert(datetime, STUFF(STUFF('31012016',3,0,'-'),6,0,'-'), 105)

-- 2016-01-31 00:00:00.000

-- SQL Server T-SQL string to datetime conversion without century - some exceptions

-- nondeterministic means language setting dependent such as Mar/Mär/mars/márc

SELECT convert(datetime, 'Oct 23 16 11:02:44AM') -- Default

SELECT convert(datetime, '10/23/16', 1) -- mm/dd/yy U.S.

SELECT convert(datetime, '16.10.23', 2) -- yy.mm.dd ANSI

SELECT convert(datetime, '23/10/16', 3) -- dd/mm/yy UK/FR

SELECT convert(datetime, '23.10.16', 4) -- dd.mm.yy German

SELECT convert(datetime, '23-10-16', 5) -- dd-mm-yy Italian

SELECT convert(datetime, '23 OCT 16', 6) -- dd mon yy non-det.

SELECT convert(datetime, 'Oct 23, 16', 7) -- mon dd, yy non-det.

SELECT convert(datetime, '20:10:44', 8) -- hh:mm:ss

SELECT convert(datetime, 'Oct 23 16 11:02:44:013AM', 9) -- Default with msec

SELECT convert(datetime, '10-23-16', 10) -- mm-dd-yy U.S.

SELECT convert(datetime, '16/10/23', 11) -- yy/mm/dd Japan

SELECT convert(datetime, '161023', 12) -- yymmdd ISO

SELECT convert(datetime, '23 Oct 16 11:02:07:577', 13) -- dd mon yy hh:mm:ss:mmm EU dflt

SELECT convert(datetime, '20:10:25:300', 14) -- hh:mm:ss:mmm(24h)

SELECT convert(datetime, '2016-10-23 20:44:11',20) -- yyyy-mm-dd hh:mm:ss(24h) ODBC can.

SELECT convert(datetime, '2016-10-23 20:44:11.500', 21)-- yyyy-mm-dd hh:mm:ss.mmm ODBC

------------

-- SQL Datetime Data Type: Combine date & time string into datetime - sql hh mm ss

-- String to datetime - mssql datetime - sql convert date - sql concatenate string

DECLARE @DateTimeValue varchar(32), @DateValue char(8), @TimeValue char(6)

 

SELECT @DateValue = '20120718',

       @TimeValue = '211920'

SELECT @DateTimeValue =

convert(varchar, convert(datetime, @DateValue), 111)

+ ' ' + substring(@TimeValue, 1, 2)

+ ':' + substring(@TimeValue, 3, 2)

+ ':' + substring(@TimeValue, 5, 2)

SELECT

DateInput = @DateValue, TimeInput = @TimeValue,

DateTimeOutput = @DateTimeValue;

/*

DateInput   TimeInput   DateTimeOutput

20120718    211920      2012/07/18 21:19:20 */


/* DATETIME 8 bytes internal storage structure
   o 1st 4 bytes: number of days after the base date 1900-01-01

   o 2nd 4 bytes: number of clock-ticks (3.33 milliseconds) since midnight

DATETIME2 8 bytes (precision > 4) internal storage structure

   o 1st byte: precision like 7

   o middle 4 bytes: number of time units (100ns smallest) since midnight

   o last 3 bytes: number of days after the base date 0001-01-01

DATE 3 bytes internal storage structure
   o 3 bytes integer: number of days after the first date 0001-01-01
   o Note: hex byte order reversed

 

SMALLDATETIME 4 bytes internal storage structure
   o 1st 2 bytes: number of days after the base date 1900-01-01

   o 2nd 2 bytes: number of minutes since midnight   */       

SELECT CONVERT(binary(8), getdate()) -- 0x00009E4D 00C01272

SELECT CONVERT(binary(4), convert(smalldatetime,getdate())) -- 0x9E4D 02BC

-- This is how a datetime looks in 8 bytes

DECLARE @dtHex binary(8)= 0x00009966002d3344;

DECLARE @dt datetime = @dtHex

SELECT @dt   -- 2007-07-09 02:44:34.147

------------ */

------------

-- SQL Server 2012 New Date & Time Related Functions

------------

SELECT DATEFROMPARTS ( 2016, 10, 23 ) AS RealDate; -- 2016-10-23

 

SELECT DATETIMEFROMPARTS ( 2016, 10, 23, 10, 10, 10, 500 ) AS RealDateTime; -- 2016-10-23 10:10:10.500

 

SELECT EOMONTH('20140201');       -- 2014-02-28

SELECT EOMONTH('20160201');       -- 2016-02-29

SELECT EOMONTH('20160201',1);     -- 2016-03-31

 

SELECT FORMAT ( getdate(), 'yyyy/MM/dd hh:mm:ss tt', 'en-US' );   -- 2016/07/30 03:39:48 AM

SELECT FORMAT ( getdate(), 'd', 'en-US' );                        -- 7/30/2016

 

SELECT PARSE('SAT, 13 December 2014' AS datetime USING 'en-US') AS [Date&Time]; 

-- 2014-12-13 00:00:00.000

 

SELECT TRY_PARSE('SAT, 13 December 2014' AS datetime USING 'en-US') AS [Date&Time]; 

-- 2014-12-13 00:00:00.000

 

SELECT TRY_CONVERT(datetime, '13 December 2014' ) AS [Date&Time];  -- 2014-12-13 00:00:00.000

SELECT CONVERT(datetime2, sysdatetime()) AS [DateTime2];  -- 2016-02-12 13:09:24.0642891

------------

 

-- SQL convert seconds to HH:MM:SS - sql times format - sql hh mm

DECLARE  @Seconds INT

SET @Seconds = 20000

SELECT HH = @Seconds / 3600, MM = (@Seconds%3600) / 60, SS = (@Seconds%60)

/* HH    MM    SS

  5     33    20   */

------------

-- SQL Server Date Only from DATETIME column - get date only

-- T-SQL just date - truncate time from datetime - remove time part

------------

DECLARE @Now datetime = CURRENT_TIMESTAMP -- getdate()

SELECT  DateAndTime       = @Now      -- Date portion and Time portion

       ,DateString        = REPLACE(LEFT(CONVERT (varchar, @Now, 112),10),' ','-')

       ,[Date]            = CONVERT(DATE, @Now)  -- SQL Server 2008 and on - date part

       ,Midnight1         = dateadd(day, datediff(day,0, @Now), 0)

       ,Midnight2         = CONVERT(DATETIME,CONVERT(int, @Now))

       ,Midnight3         = CONVERT(DATETIME,CONVERT(BIGINT,@Now) &                                                           (POWER(Convert(bigint,2),32)-1))

/* DateAndTime    DateString  Date  Midnight1   Midnight2   Midnight3

2010-11-02 08:00:33.657 20101102    2010-11-02  2010-11-02 00:00:00.000 2010-11-02 00:00:00.000      2010-11-02 00:00:00.000 */


-- SQL date yyyy mm dd - sqlserver yyyy mm dd - date format yyyymmdd

SELECT CONVERT(VARCHAR(10), GETDATE(), 111) AS [YYYY/MM/DD]

/*  YYYY/MM/DD

    2015/07/11    */

SELECT CONVERT(VARCHAR(10), GETDATE(), 112) AS [YYYYMMDD]

/*  YYYYMMDD

    20150711     */

SELECT REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/',' ') AS [YYYY MM DD]

/* YYYY MM DD

   2015 07 11    */
-- Converting to special (non-standard) date fomats: DD-MMM-YY
SELECT UPPER(REPLACE(CONVERT(VARCHAR,GETDATE(),6),' ','-'))
-- 07-MAR-14
------------

-- SQL convert date string to datetime - time set to 00:00:00.000 or 12:00AM

PRINT CONVERT(datetime,'07-10-2012',110)        -- Jul 10 2012 12:00AM

PRINT CONVERT(datetime,'2012/07/10',111)        -- Jul 10 2012 12:00AM

PRINT CONVERT(datetime,'20120710',  112)        -- Jul 10 2012 12:00AM          

------------

-- UNIX to SQL Server datetime conversion      

declare @UNIX bigint  = 1477216861;

select dateadd(ss,@UNIX,'19700101'); -- 2016-10-23 10:01:01.000
------------

-- String to date conversion - sql date yyyy mm dd - sql date formatting

-- SQL Server cast string to date - sql convert date to datetime

SELECT [Date] = CAST (@DateValue AS datetime)

-- 2012-07-18 00:00:00.000

 

-- SQL convert string date to different style - sql date string formatting

SELECT CONVERT(varchar, CONVERT(datetime, '20140508'), 100)

-- May  8 2014 12:00AM

-- SQL Server convert date to integer

DECLARE @Date datetime; SET @Date = getdate();

SELECT DateAsInteger = CAST (CONVERT(varchar,@Date,112) as INT);

-- Result: 20161225

 

-- SQL Server convert integer to datetime

DECLARE @iDate int

SET @iDate = 20151225

SELECT IntegerToDatetime = CAST(convert(varchar,@iDate) as datetime)

-- 2015-12-25 00:00:00.000

 

-- Alternates: date-only datetime values

-- SQL Server floor date - sql convert datetime

SELECT [DATE-ONLY]=CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))

SELECT [DATE-ONLY]=CONVERT(DATETIME, FLOOR(CONVERT(MONEY, GETDATE())))

-- SQL Server cast string to datetime

-- SQL Server datetime to string convert

SELECT [DATE-ONLY]=CAST(CONVERT(varchar, GETDATE(), 101) AS DATETIME)

-- SQL Server dateadd function - T-SQL datediff function

-- SQL strip time from date - MSSQL strip time from datetime

SELECT getdate() ,dateadd(dd, datediff(dd, 0, getdate()), 0)

-- Results: 2016-01-23 05:35:52.793 2016-01-23 00:00:00.000

-- String date  - 10 bytes of storage

SELECT [STRING DATE]=CONVERT(varchar,  GETDATE(), 110)

SELECT [STRING DATE]=CONVERT(varchar,  CURRENT_TIMESTAMP, 110)

-- Same results: 01-02-2012

 

-- SQL Server cast datetime as string - sql datetime formatting

SELECT stringDateTime=CAST (getdate() as varchar) -- Dec 29 2012  3:47AM

----------

-- SQL date range BETWEEN operator

----------

-- SQL date range select - date range search - T-SQL date range query

-- Count Sales Orders for 2003 OCT-NOV

DECLARE  @StartDate DATETIME,  @EndDate DATETIME

SET @StartDate = convert(DATETIME,'10/01/2003',101)

SET @EndDate   = convert(DATETIME,'11/30/2003',101)

 

SELECT @StartDate, @EndDate

-- 2003-10-01 00:00:00.000  2003-11-30 00:00:00.000

SELECT dateadd(DAY,1,@EndDate),

       dateadd(ms,-3,dateadd(DAY,1,@EndDate))

-- 2003-12-01 00:00:00.000  2003-11-30 23:59:59.997

 

-- MSSQL date range select using >= and <

SELECT [Sales Orders for 2003 OCT-NOV] = COUNT(* )

FROM   Sales.SalesOrderHeader

WHERE  OrderDate >= @StartDate AND OrderDate < dateadd(DAY,1,@EndDate)

/* Sales Orders for 2003 OCT-NOV

   3668 */

 

-- Equivalent date range query using BETWEEN comparison

-- It requires a bit of trick programming

SELECT [Sales Orders for 2003 OCT-NOV] = COUNT(* )

FROM   Sales.SalesOrderHeader

WHERE  OrderDate BETWEEN @StartDate AND dateadd(ms,-3,dateadd(DAY,1,@EndDate))

-- 3668

 

 

----------

-- Calculate week ranges in a year

----------

--DECLARE @Year INT = '2016';

--WITH cteDays AS (SELECT DayOfYear=Dateadd(dd, number,

--                 CONVERT(DATE, CONVERT(char(4),@Year)+'0101'))

--                 FROM extdsrc_master.dbo.spt_values WHERE type='P'),

--CTE AS (SELECT DayOfYear, WeekOfYear=DATEPART(week,DayOfYear)

--        FROM cteDays WHERE YEAR(DayOfYear)= @YEAR)

--SELECT WeekOfYear, StartOfWeek=MIN(DayOfYear), EndOfWeek=MAX(DayOfYear)

--FROM CTE  GROUP BY WeekOfYear ORDER BY WeekOfYear

------------

-- Date validation function ISDATE - returns 1 or 0 - SQL datetime functions

------------

DECLARE @StringDate varchar(32)

SET @StringDate = '2011-03-15 18:50'

IF EXISTS( SELECT * WHERE ISDATE(@StringDate) = 1)

    PRINT 'VALID DATE: ' + @StringDate

ELSE

    PRINT 'INVALID DATE: ' + @StringDate



-- Result: VALID DATE: 2011-03-15 18:50

 

--DECLARE @StringDate varchar(32)

SET @StringDate = '20112-03-15 18:50'

IF EXISTS( SELECT * WHERE ISDATE(@StringDate) = 1)

    PRINT 'VALID DATE: ' + @StringDate

ELSE  PRINT 'INVALID DATE: ' + @StringDate

-- Result: INVALID DATE: 20112-03-15 18:50

-- First and last day of date periods - SQL Server 2008 and on code

SET @Date  = '20161023'

SELECT ReferenceDate   = @Date 

SELECT FirstDayOfYear  = CONVERT(DATE, dateadd(yy, datediff(yy,0, @Date),0))

SELECT LastDayOfYear   = CONVERT(DATE, dateadd(yy, datediff(yy,0, @Date)+1,-1))

SELECT FDofSemester = CONVERT(DATE, dateadd(qq,((datediff(qq,0,@Date)/2)*2),0))

SELECT LastDayOfSemester 

= CONVERT(DATE, dateadd(qq,((datediff(qq,0,@Date)/2)*2)+2,-1))

SELECT FirstDayOfQuarter  = CONVERT(DATE, dateadd(qq, datediff(qq,0, @Date),0))

-- 2016-10-01

SELECT LastDayOfQuarter = CONVERT(DATE, dateadd(qq, datediff(qq,0,@Date)+1,-1))

-- 2016-12-31

SELECT FirstDayOfMonth = CONVERT(DATE, dateadd(mm, datediff(mm,0, @Date),0))

SELECT LastDayOfMonth  = CONVERT(DATE, dateadd(mm, datediff(mm,0, @Date)+1,-1))

SELECT FirstDayOfWeek  = CONVERT(DATE, dateadd(wk, datediff(wk,0, @Date),0))

SELECT LastDayOfWeek   = CONVERT(DATE, dateadd(wk, datediff(wk,0, @Date)+1,-1))

-- 2016-10-30

 

-- Month sequence generator - sequential numbers / dates

--SET @Date  = '2000-01-01'

--SELECT MonthStart=dateadd(MM, number, @Date)

--FROM  master.dbo.spt_values

--WHERE type='P' AND  dateadd(MM, number, @Date) <= CURRENT_TIMESTAMP

--ORDER BY MonthStart

/* MonthStart

2000-01-01

2000-02-01

2000-03-01 ....*/

 
-- Selected named date styles
------------


-- US-Style

SELECT @DateTimeValue = '10/23/2016'

SELECT StringDate=@DateTimeValue,

[US-Style] = CONVERT(datetime, @DatetimeValue)

 

SELECT @DateTimeValue = '10/23/2016 23:01:05'

SELECT StringDate = @DateTimeValue,

[US-Style] = CONVERT(datetime, @DatetimeValue)

 

-- UK-Style, British/French - convert string to datetime sql

-- sql convert string to datetime

SELECT @DateTimeValue = '23/10/16 23:01:05'

SELECT StringDate = @DateTimeValue,

[UK-Style] = CONVERT(datetime, @DatetimeValue, 3)

 

SELECT @DateTimeValue = '23/10/2016 04:01 PM'

SELECT StringDate = @DateTimeValue,

[UK-Style] = CONVERT(datetime, @DatetimeValue, 103)

 

-- German-Style

SELECT @DateTimeValue = '23.10.16 23:01:05'

SELECT StringDate = @DateTimeValue,

[German-Style] = CONVERT(datetime, @DatetimeValue, 4)

 

SELECT @DateTimeValue = '23.10.2016 04:01 PM'

SELECT StringDate = @DateTimeValue,

[German-Style] = CONVERT(datetime, @DatetimeValue, 104)

------------ 

 

-- Double conversion to US-Style 107 with century: Oct 23, 2016

SET @DateTimeValue='10/23/16'

SELECT StringDate=@DateTimeValue,

[US-Style] = CONVERT(varchar, CONVERT(datetime, @DateTimeValue),107)

 

-- Using DATEFORMAT - UK-Style - SQL dateformat

SET @DateTimeValue='23/10/16'

SET DATEFORMAT dmy

SELECT StringDate=@DateTimeValue,

[Date Time] = CONVERT(datetime, @DatetimeValue)

-- Using DATEFORMAT - US-Style

SET DATEFORMAT mdy
-- Finding out date format for a session

SELECT session_id, date_format from sys.dm_exec_sessions

------------

  -- Convert date string from DD/MM/YYYY UK format to MM/DD/YYYY US format
DECLARE @UKdate char(10) = '15/03/2016'
SELECT CONVERT(CHAR(10), CONVERT(datetime, @UKdate,103),101)

-- 03/15/2016

-- DATEPART datetime function example - SQL Server datetime functions

--SELECT * FROM Northwind.dbo.Orders

--WHERE DATEPART(YEAR, OrderDate) = '1996' AND

--      DATEPART(MONTH,OrderDate) = '07'   AND

--      DATEPART(DAY, OrderDate)  = '10'

 

---- Alternate syntax for DATEPART example

--SELECT * FROM Northwind.dbo.Orders

--WHERE YEAR(OrderDate)         = '1996' AND

--      MONTH(OrderDate)        = '07'   AND

--      DAY(OrderDate)          = '10'
--------------

---- T-SQL calculate the number of business days function / UDF - exclude SAT & SUN

--------------

--CREATE FUNCTION fnBusinessDays (@StartDate DATETIME, @EndDate   DATETIME)

--RETURNS INT AS

--  BEGIN

--    IF (@StartDate IS NULL OR @EndDate IS NULL)  RETURN (0)

--    DECLARE  @i INT = 0;

--    WHILE (@StartDate <= @EndDate)

--      BEGIN

--        SET @i = @i + CASE

--                        WHEN datepart(dw,@StartDate) BETWEEN 2 AND 6 THEN 1

--                        ELSE 0

--                      END 

--        SET @StartDate = @StartDate + 1

--      END  -- while 

--    RETURN (@i)

--  END -- function



--SELECT dbo.fnBusinessDays('2016-01-01','2016-12-31')

---- 261

--------------

---- T-SQL DATENAME function usage for weekdays

--SELECT DayName=DATENAME(weekday, OrderDate), SalesPerWeekDay = COUNT(*)

--FROM AdventureWorks2008.Sales.SalesOrderHeader

--GROUP BY DATENAME(weekday, OrderDate), DATEPART(weekday,OrderDate)

--ORDER BY DATEPART(weekday,OrderDate)

--/* DayName   SalesPerWeekDay

--Sunday      4482

--Monday      4591

--Tuesday     4346.... */

 

---- DATENAME application for months

--SELECT MonthName=DATENAME(month, OrderDate), SalesPerMonth = COUNT(*)

--FROM AdventureWorks2008.Sales.SalesOrderHeader

--GROUP BY DATENAME(month, OrderDate), MONTH(OrderDate) ORDER BY MONTH(OrderDate)

/* MonthName      SalesPerMonth

January           2483

February          2686

March             2750

April             2740....  */

 

-- Getting month name from month number

SELECT DATENAME(MM,dateadd(MM,7,-1))  -- July

      -- ARTICLE - Essential SQL Server Date, Time and DateTime Functions
       --ARTICLE - Demystifying the SQL Server DATETIME Datatype

------------
-- Extract string date from text with PATINDEX pattern matching

-- Apply sql server string to date conversion

------------

CREATE TABLE InsiderTransaction (

      InsiderTransactionID int identity primary key,

      TradeDate datetime,

      TradeMsg varchar(256),

      ModifiedDate datetime default (getdate()))

-- Populate table with dummy data

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC Hammer, Bruce D. CSO 09-02-08 Buy 2,000 6.10')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC Schmidt, Steven CFO 08-25-08 Buy 2,500 6.70')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC  Hammer, Bruce D. CSO  08-20-08 Buy 3,000 8.59')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC Walters,  Jeff CTO 08-15-08  Sell 5,648 8.49')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN  QABC  Walters, Jeff CTO   08-15-08 Option Execute 5,648 2.15')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC Hammer, Bruce D. CSO 07-31-08  Buy 5,000 8.05')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC Lennot, Mark B. Director  08-31-07 Buy 1,500 9.97')

INSERT InsiderTransaction (TradeMsg) VALUES(

'INSIDER TRAN QABC  O''Neal, Linda COO  08-01-08 Sell 5,000 6.50') 

 

-- Extract dates from stock trade message text

-- Pattern match for MM-DD-YY using the PATINDEX string function

SELECT TradeDate=substring(TradeMsg,

       patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg),8)

FROM InsiderTransaction

WHERE  patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg) > 0

/* Partial results

TradeDate

09-02-08

08-25-08

08-20-08 */

 

-- Update table with extracted date

-- Convert string date to datetime

UPDATE InsiderTransaction

SET TradeDate = convert(datetime,  substring(TradeMsg,

       patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg),8))

WHERE  patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg) > 0

 

SELECT * FROM InsiderTransaction ORDER BY TradeDate desc

/* Partial results

InsiderTransactionID    TradeDate   TradeMsg    ModifiedDate

1     2008-09-02 00:00:00.000 INSIDER TRAN QABC Hammer, Bruce D. CSO 09-02-08 Buy 2,000 6.10      2008-12-22 20:25:19.263

2     2008-08-25 00:00:00.000 INSIDER TRAN QABC Schmidt, Steven CFO 08-25-08 Buy 2,500 6.70      2008-12-22 20:25:19.263 */

-- Cleanup task

DROP TABLE InsiderTransaction

 

/************

VALID DATE RANGES FOR DATE / DATETIME DATA TYPES

 

DATE (3 bytes) date range:

January 1, 1 A.D. through December 31, 9999 A.D.

 

SMALLDATETIME (4 bytes) date range:

January 1, 1900 through June 6, 2079

 

DATETIME (8 bytes) date range:

January 1, 1753 through December 31, 9999

 

DATETIME2 (6-8 bytes) date range:

January 1, 1 A.D. through December 31, 9999 A.D.

 

-- The statement below will give a date range error

SELECT CONVERT(smalldatetime, '2110-01-01')

/* Msg 242, Level 16, State 3, Line 1

The conversion of a varchar data type to a smalldatetime data type

resulted in an out-of-range value. */

************/



-- SQL CONVERT DATE/DATETIME script applying table variable

------------

-- SQL Server convert date

-- Datetime column is converted into date only string column

DECLARE @sqlConvertDate TABLE ( DatetimeColumn datetime,

                                DateColumn char(10));

INSERT @sqlConvertDate (DatetimeColumn) SELECT GETDATE()

 

UPDATE @sqlConvertDate

SET DateColumn = CONVERT(char(10), DatetimeColumn, 111)

SELECT * FROM @sqlConvertDate

 

-- SQL Server convert datetime - String date column converted into datetime column

UPDATE @sqlConvertDate

SET DatetimeColumn = CONVERT(Datetime, DateColumn, 111)

SELECT * FROM @sqlConvertDate

 

-- Equivalent formulation - SQL Server cast datetime

UPDATE @sqlConvertDate

SET DatetimeColumn = CAST(DateColumn AS datetime)

SELECT * FROM @sqlConvertDate

/* First results

DatetimeColumn                DateColumn

2012-12-25 15:54:10.363       2012/12/25 */

/* Second results:

DatetimeColumn                DateColumn

2012-12-25 00:00:00.000       2012/12/25  */

------------

-- SQL date sequence generation with dateadd & table variable

-- SQL Server cast datetime to string - SQL Server insert default values method

DECLARE @Sequence table (Sequence int identity(1,1))

DECLARE @i int; SET @i = 0

WHILE ( @i < 500)

BEGIN

      INSERT @Sequence DEFAULT VALUES

      SET @i = @i + 1

END

SELECT DateSequence = CAST(dateadd(day, Sequence,getdate()) AS varchar)

FROM @Sequence

/* Partial results:

DateSequence

Dec 31 2008  3:02AM

Jan  1 2009  3:02AM

Jan  2 2009  3:02AM

Jan  3 2009  3:02AM

Jan  4 2009  3:02AM */

 

-- SETTING FIRST DAY OF WEEK TO SUNDAY

SET DATEFIRST 7;

SELECT @@DATEFIRST

-- 7

SELECT CAST('2016-10-23' AS date) AS SelectDate

    ,DATEPART(dw, '2016-10-23') AS DayOfWeek;

-- 2016-10-23     1

 

------------

-- SQL Last Week calculations

------------

-- SQL last Friday - Implied string to datetime conversions in dateadd & datediff

DECLARE @BaseFriday CHAR(8), @LastFriday datetime, @LastMonday datetime

SET @BaseFriday = '19000105'

SELECT @LastFriday = dateadd(dd,

          (datediff (dd, @BaseFriday, CURRENT_TIMESTAMP) / 7) * 7, @BaseFriday)

SELECT [Last Friday] = @LastFriday

-- Result: 2008-12-26 00:00:00.000

 

-- SQL last Monday (last week's Monday)

SELECT @LastMonday=dateadd(dd,

          (datediff (dd, @BaseFriday, CURRENT_TIMESTAMP) / 7) * 7 - 4, @BaseFriday)

SELECT [Last Monday]= @LastMonday 

-- Result: 2008-12-22 00:00:00.000

 

-- SQL last week - SUN - SAT

SELECT [Last Week] = CONVERT(varchar,dateadd(day, -1, @LastMonday), 101)+ ' - ' +

                     CONVERT(varchar,dateadd(day, 1,  @LastFriday), 101)

-- Result: 12/21/2008 - 12/27/2008

 

-----------------

-- Specific day calculations

------------

-- First day of current month

SELECT dateadd(month, datediff(month, 0, getdate()), 0)

 -- 15th day of current month

SELECT dateadd(day,14,dateadd(month,datediff(month,0,getdate()),0))

-- First Monday of current month

SELECT dateadd(day, (9-datepart(weekday, 

       dateadd(month, datediff(month, 0, getdate()), 0)))%7, 

       dateadd(month, datediff(month, 0, getdate()), 0))

-- Next Monday calculation from the reference date which was a Monday

SET @Now = GETDATE();

DECLARE @NextMonday datetime = dateadd(dd, ((datediff(dd, '19000101', @Now)

                               / 7) * 7) + 7, '19000101');

SELECT [Now]=@Now, [Next Monday]=@NextMonday

-- Last Friday of current month

SELECT dateadd(day, -7+(6-datepart(weekday, 

       dateadd(month, datediff(month, 0, getdate())+1, 0)))%7, 

       dateadd(month, datediff(month, 0, getdate())+1, 0))

-- First day of next month

SELECT dateadd(month, datediff(month, 0, getdate())+1, 0)

-- 15th of next month

SELECT dateadd(day,14, dateadd(month, datediff(month, 0, getdate())+1, 0))

-- First Monday of next month

SELECT dateadd(day, (9-datepart(weekday, 

       dateadd(month, datediff(month, 0, getdate())+1, 0)))%7, 

       dateadd(month, datediff(month, 0, getdate())+1, 0))

 

------------

-- SQL Last Date calculations

------------

-- Last day of prior month - Last day of previous month

SELECT convert( varchar, dateadd(dd,-1,dateadd(mm, datediff(mm,0,getdate() ), 0)),101)

-- 01/31/2019

-- Last day of current month

SELECT convert( varchar, dateadd(dd,-1,dateadd(mm, datediff(mm,0,getdate())+1, 0)),101)

-- 02/28/2019

-- Last day of prior quarter - Last day of previous quarter

SELECT convert( varchar, dateadd(dd,-1,dateadd(qq, datediff(qq,0,getdate() ), 0)),101)

-- 12/31/2018

-- Last day of current quarter - Last day of current quarter

SELECT convert( varchar, dateadd(dd,-1,dateadd(qq, datediff(qq,0,getdate())+1, 0)),101)

-- 03/31/2019

-- Last day of prior year - Last day of previous year

SELECT convert( varchar, dateadd(dd,-1,dateadd(yy, datediff(yy,0,getdate() ), 0)),101)

-- 12/31/2018

-- Last day of current year

SELECT convert( varchar, dateadd(dd,-1,dateadd(yy, datediff(yy,0,getdate())+1, 0)),101)

-- 12/31/2019

------------

-- SQL Server dateformat and language setting

------------

-- T-SQL set language - String to date conversion

SET LANGUAGE us_english

SELECT CAST('2018-03-15' AS datetime)

-- 2018-03-15 00:00:00.000

 

SET LANGUAGE british

SELECT CAST('2018-03-15' AS datetime)

/* Msg 242, Level 16, State 3, Line 2

The conversion of a varchar data type to a datetime data type resulted in

an out-of-range value.

*/

SELECT CAST('2018-15-03' AS datetime)

-- 2018-03-15 00:00:00.000

 

SET LANGUAGE us_english

 

-- SQL dateformat with language dependency

SELECT name, alias, dateformat

FROM sys.syslanguages

WHERE langid in (0,1,2,4,5,6,7,10,11,13,23,31)



/* 

name        alias             dateformat

us_english  English           mdy

Deutsch     German            dmy

Français    French            dmy

Dansk       Danish            dmy

Español     Spanish           dmy

Italiano    Italian           dmy

Nederlands  Dutch             dmy

Suomi       Finnish           dmy

Svenska     Swedish           ymd

magyar      Hungarian         ymd

British     British English   dmy

Arabic      Arabic            dmy */

------------

 

-- Generate list of months

;WITH CTE AS (

      SELECT      1 MonthNo, CONVERT(DATE, '19000101') MonthFirst

      UNION ALL

      SELECT      MonthNo+1, DATEADD(Month, 1, MonthFirst)

      FROM  CTE WHERE   Month(MonthFirst) < 12   )

SELECT      MonthNo AS MonthNumber, DATENAME(MONTH, MonthFirst) AS MonthName

FROM  CTE ORDER BY MonthNo

/* MonthNumber    MonthName

      1           January

      2           February

      3           March  ... */

------------

END
GO
/****** Object:  StoredProcedure [tool].[CreateBCPFormatFile]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC tool.CreateBCPFormatFile
					@Delimiter = ','
				,	@Table = 'Customers'
				,	@Schema = 'Sales'
*/
CREATE   PROCEDURE [tool].[CreateBCPFormatFile]
	
    @Delimiter    NVARCHAR(6)       = ',',
    @Table        SYSNAME           = NULL,
	@Schema			SYSNAME			= NULL
AS

SET NOCOUNT ON;


DECLARE @Header       NVARCHAR(MAX)		= '' 


DECLARE

		@AddField		BIT,
		@CarryOver		BIT,
		@Column			NVARCHAR(255),
		@Field			NVARCHAR(255),
		@FieldNum		INT,
		@Length			VARCHAR(5),
		@Pos			INT,
		@Start			INT,
		@StartQuote		BIT,
		@Stop			INT,
		@TableId		INT,
		@TermChar		VARCHAR(6),
		@Terminator		VARCHAR(6),
		@Version		NVARCHAR(128),
		
--    constants...
		@Collation		NVARCHAR(35),
		@Quote			CHAR(1),
		@Quote_E		CHAR(2),
		@SQLChar		CHAR(7)


SELECT @Header += '"' + col.name + '"' + ',' FROM sys.columns AS col INNER JOIN sys.tables AS tab ON tab.object_id = col.object_id
					INNER JOIN sys.schemas AS sch ON sch.schema_id = tab.schema_id
				WHERE tab.name = @Table
				AND sch.name = @Schema

SET @Header = SUBSTRING(@Header, 1, LEN(@Header) - 1)



DECLARE    @Format    TABLE
			(    
				rowId			SMALLINT    IDENTITY PRIMARY KEY,
				colName			SYSNAME        NOT NULL,
				terminator		VARCHAR(6)    NOT NULL,
				colOrder		VARCHAR(5)    NOT NULL,
				fileLength		VARCHAR(5)    NOT NULL
			);

--    initialize variables
SELECT    @AddField		= 0
    ,    @CarryOver		= 0
    ,    @Column        = ''
    ,    @FieldNum		= 1
    ,    @Length        = ''
    ,    @StartQuote    = 0
    ,    @TableId		= OBJECT_ID(@Table)
    ,    @TermChar		= CASE @Delimiter WHEN CHAR(9) THEN '\t' ELSE @Delimiter END
    ,    @Terminator    = ''
    ,    @Version		= CONVERT(NVARCHAR(128), SERVERPROPERTY(N'ProductVersion'))
    --    constants...
    ,    @Collation		= CONVERT(NVARCHAR(128), SERVERPROPERTY(N'Collation'))
    ,    @Quote			= '"'
    ,    @Quote_E		= '\"'
    ,    @SQLChar		= 'SQLCHAR'

--    get the SQL Engine version...
SET @Version = LEFT(@Version, CHARINDEX('.', @Version) + 1);

-- create the header list containing all columns in the table if null is passed in
IF @Header IS NULL
BEGIN
   SELECT @Header = COALESCE (@Header + ', ', '') + Name 
   FROM syscolumns 
   WHERE id = @TableID 
   ORDER BY ColID
END



WHILE CHARINDEX(@Delimiter, @Header) > 0
BEGIN
    SET @Pos		= CHARINDEX(@Delimiter, @Header);                --    find the next delimiter
    SET @Field		= LEFT(@Header, @Pos - 1);                        --    collect that value
    SET @Header		= SUBSTRING(@Header, @Pos + 1, LEN(@Header));    --    shorten the header by the field just removed...
    SET @AddField	= 0;
    SET @CarryOver	=	CASE LEN(@Column)
							WHEN 0 THEN 0
							ELSE 1 
						END;

    SET @StartQuote	=   CASE LEFT(@Field, 1) 
							WHEN @Quote THEN 1
							ELSE 0 
						END;

    SET @Column     =    @Column + REPLACE(@Field, @Quote, '') + ' ';        --    remove quotes

    SET @Length     =    CAST(LEN(@Column) AS VARCHAR(5));        --    default length is the lenght from the "column"

    IF (@StartQuote = 1 OR @CarryOver = 1)
    BEGIN
        IF RIGHT(@Field, 1) = @Quote
        BEGIN
            SET @AddField		=    1;
            SET @Terminator		=    @Quote_E + @TermChar
									+	CASE LEFT(@Header, 1)
											WHEN @Quote THEN @Quote_E
											ELSE '' 
										END;
        END;
    END;
    ELSE
    BEGIN
        SET @AddField			=    1;
        SET @Terminator			=    @TermChar
									+	CASE LEFT(@Header, 1)
											WHEN @Quote THEN @Quote_E
											ELSE '' 
										END;
    END;


    IF (@AddField = 1)
    BEGIN
        SET @Column = RTRIM(@Column);
        IF(@FieldNum = 1 AND CHARINDEX(@Quote, @Field) > 0)
        BEGIN
            --    add an "dummy column" if it's the first field and it starts with a quote
            INSERT @Format VALUES('dummy_col', @Quote_E, 0, 0);
        END;


        --    add the column to the database
        INSERT @Format VALUES(@Column, @Terminator, @FieldNum, @Length);
        SET @FieldNum    = @FieldNum + 1;
        SET @Terminator = '';
        SET @Column        = '';
    END;
END;

--    the part of the header is the last field...
SET @Column        =    REPLACE(@Header, @Quote, '');
SET @Length        =    CAST(LEN(@Column) AS VARCHAR(5));
SET @Terminator    =    CASE RIGHT(@Header, 1)
							WHEN @Quote THEN @Quote_E
							ELSE '' 
						END + '\r\n'


INSERT @Format VALUES(@Column, @Terminator, @FieldNum, @Length)

--    return the resulting format file definition...
SELECT    FileOrder
    ,    FileType
    ,    PrefixLength    
    ,    FileLength
    ,    Terminator
    ,    ColumnOrder
    ,    ColumnName
    ,    ColumnCollation
FROM
	(    
		SELECT  
				0            AS TYPE
            ,   0            AS rowId
            ,   LEFT(@Version, 6)    AS FileOrder
            ,   ''            AS FileType
            ,   ''            AS PrefixLength    
            ,   ''            AS FileLength
            ,   ''            AS Terminator
            ,   ''            AS ColumnOrder
            ,   ''            AS ColumnName
            ,   ''            AS ColumnCollation

        UNION ALL

        SELECT   
				1            AS TYPE
            ,   0            AS rowId
            ,   CAST(@FieldNum AS VARCHAR(6))
            ,   ''            AS FileType
            ,   ''            AS PrefixLength    
            ,   ''            AS FileLength
            ,   ''            AS Terminator
            ,   ''            AS ColumnOrder
            ,   ''            AS ColumnName
            ,   ''            AS ColumnCollation

        UNION ALL

        SELECT   
				2            AS TYPE
            ,   f.rowId
            ,   CAST(f.rowId AS VARCHAR(6))
            ,   @SQLChar    AS FileType
            ,   '0'            AS PrefixLength    
            ,   ISNULL(c.max_length, f.FileLength)
            ,   '"' + ISNULL(Terminator, '') + '"'
            ,   ISNULL(c.column_id, f.colOrder)
            ,   ISNULL(c.name, f.colName)
            ,   ISNULL(c.collation_name, @Collation)
        FROM    @Format        f
        LEFT OUTER JOIN
            (    
				SELECT   
						CAST(column_id AS VARCHAR(5))    AS column_id
                    ,   name
                    ,   CAST(max_length AS VARCHAR(5))    AS max_length
                    ,   ISNULL(collation_name, '""')    AS collation_name
                FROM    sys.columns
                WHERE   OBJECT_ID = @TableId
            )    c ON f.colName = c.name
    )    f
ORDER BY f.TYPE, f.rowId;

RETURN @@ERROR;


/*
Sample:        @Header        = '"DVD_Title","Studio",Released,"Status","Sound","Versions",Price,"Rating","Year","Genre","Aspect","UPC",DVD_ReleaseDate,ID,Timestamp,Updated'
               @Delimiter    = ','
               @Table        = 'dbo.test_table'    --[optional] uses data from sys.columns for file length and position
                                                        otherwise it uses "column name" as length if table isn't 
                                                        found or column isn't matched
            create table dbo.test_table
                (    DVD_Title        varchar(128)
                ,    Studio            varchar(30)
                ,    Released        datetime
                ,    Status            varchar(10)
                ,    Sound            varchar(10)
                ,    Versions        varchar(10)
                ,    Price            money
                ,    Rating            varchar(10)
                ,    Year            char(4)
                ,    Genre            varchar(10)
                ,    Aspect            varchar(15)
                ,    UPC                varchar(25)
                ,    DVD_ReleaseDate    datetime
                ,    ID                int primary key
                ,    Timestamp        timestamp
                ,    Updated            smallint
                )



Yields the result set for a format file:
--		9.0                            
--		16                            
--		1     SQLCHAR    0    0      "\""       0    dummy_col           SQL_Latin1_General_CP1_CI_AS
--		2     SQLCHAR    0    128    "\",\""    1    DVD_Title           SQL_Latin1_General_CP1_CI_AS
--		3     SQLCHAR    0    30     "\","      2    Studio              SQL_Latin1_General_CP1_CI_AS
--		4     SQLCHAR    0    8      ",\""      3    Released            ""
--		5     SQLCHAR    0    10     "\",\""    4    Status              SQL_Latin1_General_CP1_CI_AS
--		6     SQLCHAR    0    10     "\",\""    5    Sound               SQL_Latin1_General_CP1_CI_AS
--		7     SQLCHAR    0    10     "\","      6    Versions            SQL_Latin1_General_CP1_CI_AS
--		8     SQLCHAR    0    8      ",\""      7    Price               ""
--		9     SQLCHAR    0    10     "\",\""    8    Rating              SQL_Latin1_General_CP1_CI_AS
--		10    SQLCHAR    0    4      "\",\""    9    Year                SQL_Latin1_General_CP1_CI_AS
--		11    SQLCHAR    0    10     "\",\""    10  Genre               SQL_Latin1_General_CP1_CI_AS
--		12    SQLCHAR    0    15     "\",\""    11  Aspect              SQL_Latin1_General_CP1_CI_AS
--		13    SQLCHAR    0    25     "\","      12  UPC                 SQL_Latin1_General_CP1_CI_AS
--		14    SQLCHAR    0    8      ","        13  DVD_ReleaseDate     ""
--		15    SQLCHAR    0    4      ","        14  ID                  ""
--		16    SQLCHAR    0    8      ","        15  Timestamp           ""
--		17    SQLCHAR    0    2      "\r\n"     16  Updated             ""    
*/
GO
/****** Object:  StoredProcedure [tool].[GetDdl]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--#############################################################################
--if you are going to put this in MASTER, and want it to be able to query
--each database's sys.indexes, you MUST mark it as a system procedure:
--EXECUTE sp_ms_marksystemobject 'sp_GetDDL'
--#############################################################################
CREATE PROCEDURE [tool].[GetDdl]
  @TBL                VARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON
  DECLARE     @TBLNAME                VARCHAR(200),
              @SCHEMANAME             VARCHAR(255),
              @STRINGLEN              INT,
              @TABLE_ID               INT,
              @FINALSQL               VARCHAR(MAX),
              @CONSTRAINTSQLS         VARCHAR(MAX),
              @CHECKCONSTSQLS         VARCHAR(MAX),
              @RULESCONSTSQLS         VARCHAR(MAX),
              @FKSQLS                 VARCHAR(MAX),
              @TRIGGERSTATEMENT       VARCHAR(MAX),
              @EXTENDEDPROPERTIES     VARCHAR(MAX),
              @INDEXSQLS              VARCHAR(MAX),
              @MARKSYSTEMOBJECT       VARCHAR(MAX),
              @vbCrLf                 CHAR(2),
              @ISSYSTEMOBJECT         INT,
              @PROCNAME               VARCHAR(256),
              @input                  VARCHAR(MAX),
              @ObjectTypeFound        VARCHAR(255),
              @ObjectDataTypeLen      INT

--##############################################################################
-- INITIALIZE
--##############################################################################
  SET @input = ''
  --new code: determine whether this proc is marked as a system proc with sp_ms_marksystemobject,
  --which flips the is_ms_shipped bit in sys.objects
    SELECT @ISSYSTEMOBJECT = ISNULL(is_ms_shipped,0),@PROCNAME = ISNULL(name,'sp_GetDDL') FROM sys.objects WHERE OBJECT_ID = @@PROCID
  IF @ISSYSTEMOBJECT IS NULL 
    SELECT @ISSYSTEMOBJECT = ISNULL(is_ms_shipped,0),@PROCNAME = ISNULL(name,'sp_GetDDL') FROM sys.objects WHERE OBJECT_ID = @@PROCID
  IF @ISSYSTEMOBJECT IS NULL 
    SET @ISSYSTEMOBJECT = 0  
  IF @PROCNAME IS NULL
    SET @PROCNAME = 'sp_GetDDL'
  --SET @TBL =  '[DBO].[WHATEVER1]'
  --does the tablename contain a schema?
  SET @vbCrLf = CHAR(13) + CHAR(10)
  SELECT @SCHEMANAME = ISNULL(PARSENAME(@TBL,2),'tool') ,
         @TBLNAME    = PARSENAME(@TBL,1)
  SELECT
    @TBLNAME    = [name],
    @TABLE_ID   = [OBJECT_ID]
  FROM sys.objects OBJS
  WHERE [TYPE]          IN ('S','U')
    AND [name]          <>  'dtproperties'
    AND [name]           =  @TBLNAME
    AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME) ;

 SELECT @ObjectDataTypeLen = MAX(LEN(name)) from sys.types
--##############################################################################
-- Check If TEMP TableName is Valid
--##############################################################################
  IF LEFT(@TBLNAME,1) = '#'
    BEGIN
      PRINT '--TEMP TABLE  ' + quotename(@TBLNAME) + '  FOUND'
      IF OBJECT_ID('tempdb..' + quotename(@TBLNAME)) IS NOT NULL
        BEGIN
          PRINT '--GOIN TO TEMP PROCESSING'
          GOTO TEMPPROCESS
        END
    END
  ELSE
    BEGIN
      PRINT '--Non-Temp Table, ' + quotename(@TBLNAME) + ' continue Processing'
    END
--##############################################################################
-- Check If TableName is Valid
--##############################################################################
  IF ISNULL(@TABLE_ID,0) = 0
    BEGIN
      --V309 code: see if it is an object and not a table.
      SELECT
        @TBLNAME    = [name],
        @TABLE_ID   = [OBJECT_ID],
        @ObjectTypeFound = type_desc
      FROM sys.objects OBJS
      --WHERE [type_desc]     IN('SQL_STORED_PROCEDURE','VIEW','SQL_TRIGGER','AGGREGATE_FUNCTION','SQL_INLINE_TABLE_VALUED_FUNCTION','SQL_TABLE_VALUED_FUNCTION','SQL_SCALAR_FUNCTION','SYNONYMN')
      WHERE [TYPE]          IN ('P','V','TR','AF','IF','FN','TF','SN')
        AND [name]          <>  'dtproperties'
        AND [name]           =  @TBLNAME
        AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME) ;
      IF ISNULL(@TABLE_ID,0) <> 0  
        BEGIN
          --adding a drop statement.
          --adding a sp_ms_marksystemobject if needed

          SELECT @MARKSYSTEMOBJECT = CASE 
                                       WHEN is_ms_shipped = 1 
                                       THEN '
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  ''' + quotename(@SCHEMANAME) +'.' + quotename(@TBLNAME) + '''
--#################################################################################################
' 
                                       ELSE '
GO
' 
                                     END 
          FROM sys.objects OBJS 
          WHERE object_id = @TABLE_ID

          --adding a drop statement.
          --adding a drop statement.
          IF @ObjectTypeFound = 'SYNONYM'
            BEGIN
               SELECT @FINALSQL = 
                'IF EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                                + name 
                                + ''''
                                + ' AND base_object_name <> ''' + base_object_name + ''')'
                                + @vbCrLf
                                + '  DROP SYNONYM ' + quotename(name) + ''
                                + @vbCrLf
                                +'GO'
                                + @vbCrLf
                                +'IF NOT EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                                + name 
                                + ''')'
                                + @vbCrLf
                                + 'CREATE SYNONYM ' + quotename(name) + ' FOR ' + base_object_name +';'
                                from sys.synonyms
                                WHERE  [name]   =  @TBLNAME
                                AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME);
            END
          ELSE
            BEGIN
          SELECT @FINALSQL = 
          'IF OBJECT_ID(''' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
          + 'DROP ' + CASE 
                        WHEN OBJS.[type] IN ('P')
                        THEN ' PROCEDURE '
                        WHEN OBJS.[type] IN ('V')
                        THEN ' VIEW      '
                        WHEN OBJS.[type] IN ('TR')
                        THEN ' TRIGGER   '
                        ELSE ' FUNCTION  '
                      END 
                      + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf + 'GO' + @vbcrlf
          + def.definition + @MARKSYSTEMOBJECT
          FROM sys.objects OBJS 
            INNER JOIN sys.sql_modules def
              ON OBJS.object_id = def.object_id
          WHERE OBJS.[type]          IN ('P','V','TR','AF','IF','FN','TF')
            AND OBJS.[name]          <>  'dtproperties'
            AND OBJS.[name]           =  @TBLNAME
            AND OBJS.[schema_id] =  SCHEMA_ID(@SCHEMANAME) ;
            END
          SET @input = @FINALSQL  
          
        SELECT @input AS Item
         RETURN;
        END
      ELSE
        BEGIN
        SET @FINALSQL = 'Object ' + quotename(@SCHEMANAME) + '.' + quotename(@TBLNAME) + ' does not exist in Database ' + quotename(DB_NAME())   + ' '  
                      + CASE 
                          WHEN @ISSYSTEMOBJECT = 0 THEN @vbCrLf + ' (also note that ' + @PROCNAME + ' is not marked as a system proc and cross db access to sys.tables will fail.)'
                          ELSE ''
                        END
      IF LEFT(@TBLNAME,1) = '#' 
        SET @FINALSQL = @FINALSQL + ' OR in The tempdb database.'
      SELECT @FINALSQL AS Item;
      RETURN 0
        END  
      
    END
--##############################################################################
-- Valid Table, Continue Processing
--##############################################################################
 SELECT 
   @FINALSQL =  'IF OBJECT_ID(''' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
              + 'DROP TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf + 'GO' + @vbcrlf
              + 'CREATE TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ( '
  --removed invalid code here which potentially selected wrong table--thanks David Grifiths @SSC!
  SELECT
    @STRINGLEN = MAX(LEN(COLS.[name])) + 1
  FROM sys.objects OBJS
    INNER JOIN sys.columns COLS
      ON  OBJS.[object_id] = COLS.[object_id]
      AND OBJS.[object_id] = @TABLE_ID;
--##############################################################################
--Get the columns, their definitions and defaults.
--##############################################################################
  SELECT
    @FINALSQL = @FINALSQL
    + CASE
        WHEN COLS.[is_computed] = 1
        THEN @vbCrLf
             + QUOTENAME(COLS.[name])
             + ' '
             + SPACE(@STRINGLEN - LEN(COLS.[name]))
             + 'AS ' + ISNULL(CALC.definition,'')
             + CASE 
                 WHEN CALC.is_persisted = 1 
                 THEN ' PERSISTED'
                 ELSE ''
               END
        ELSE @vbCrLf
             + QUOTENAME(COLS.[name])
             + ' '
             + SPACE(@STRINGLEN - LEN(COLS.[name]))
             + UPPER(TYPE_NAME(COLS.[user_type_id]))
             + CASE
-- data types with precision and scale  IE DECIMAL(18,3), NUMERIC(10,2)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('decimal','numeric')
               THEN '('
                    + CONVERT(VARCHAR,COLS.[precision])
                    + ','
                    + CONVERT(VARCHAR,COLS.[scale])
                    + ') '
                    + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[precision])
                    + ','
                    + CONVERT(VARCHAR,COLS.[scale])))
                    + SPACE(7)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + CASE
                        WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 0
                        THEN ''
                        ELSE ' IDENTITY('
                               + CONVERT(VARCHAR,ISNULL(IDENT_SEED(@TBLNAME),1) )
                               + ','
                               + CONVERT(VARCHAR,ISNULL(IDENT_INCR(@TBLNAME),1) )
                               + ')'
                        END
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
-- data types with scale  IE datetime2(7),TIME(7)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('datetime2','datetimeoffset','time')
               THEN CASE 
                      WHEN COLS.[scale] < 7 THEN
                      '('
                      + CONVERT(VARCHAR,COLS.[scale])
                      + ') '
                    ELSE 
                      '    '
                    END
                    + SPACE(4)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + '        '
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--data types with no/precision/scale,IE  FLOAT
               WHEN  TYPE_NAME(COLS.[user_type_id]) IN ('float') --,'real')
               THEN
               --addition: if 53, no need to specifically say (53), otherwise display it
                    CASE
                      WHEN COLS.[precision] = 53
                      THEN SPACE(11 - LEN(CONVERT(VARCHAR,COLS.[precision])))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,COLS.[precision])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[precision])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      END
--data type with max_length		ie CHAR (44), VARCHAR(40), BINARY(5000),
--##############################################################################
-- COLLATE STATEMENTS
-- personally i do not like collation statements,
-- but included here to make it easy on those who do
--##############################################################################
               WHEN  TYPE_NAME(COLS.[user_type_id]) IN ('char','varchar','binary','varbinary')
               THEN CASE
                      WHEN  COLS.[max_length] = -1
                      THEN  '(max)'
                            + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[max_length])))
                            + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                            ----collate to comment out when not desired
                            --+ CASE
                            --    WHEN COLS.collation_name IS NULL
                            --    THEN ''
                            --    ELSE ' COLLATE ' + COLS.collation_name
                            --  END
                            + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN COLS.[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
                      ELSE '('
                           + CONVERT(VARCHAR,COLS.[max_length])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[max_length])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--data type with max_length ( BUT DOUBLED) ie NCHAR(33), NVARCHAR(40)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('nchar','nvarchar')
               THEN CASE
                      WHEN  COLS.[max_length] = -1
                      THEN '(max)'
                           + SPACE(5 - LEN(CONVERT(VARCHAR,(COLS.[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN  ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,(COLS.[max_length] / 2))
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,(COLS.[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END

               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('datetime','money','text','image','real')
               THEN SPACE(18 - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + '              '
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--  other data type 	IE INT, DATETIME, MONEY, CUSTOM DATA TYPE,...
               ELSE SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                            + CASE
                                WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 0
                                THEN '              '
                                ELSE ' IDENTITY('
                                     + CONVERT(VARCHAR,ISNULL(IDENT_SEED(@TBLNAME),1) )
                                     + ','
                                     + CONVERT(VARCHAR,ISNULL(IDENT_INCR(@TBLNAME),1) )
                                     + ')'
                              END
                            + SPACE(2)
                            + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN COLS.[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
               END
             + CASE
                 WHEN COLS.[default_object_id] = 0
                 THEN ''
                 --ELSE ' DEFAULT '  + ISNULL(def.[definition] ,'')
                 --optional section in case NAMED default constraints are needed:
                 ELSE '  CONSTRAINT ' + quotename(DEF.name) + ' DEFAULT ' + ISNULL(DEF.[definition] ,'')
                        --i thought it needed to be handled differently! NOT!
               END  --CASE cdefault
      END --iscomputed
    + ','
    FROM sys.columns COLS
      LEFT OUTER JOIN  sys.default_constraints  DEF
        ON COLS.[default_object_id] = DEF.[object_id]
      LEFT OUTER JOIN sys.computed_columns CALC
         ON  COLS.[object_id] = CALC.[object_id]
         AND COLS.[column_id] = CALC.[column_id]
    WHERE COLS.[object_id]=@TABLE_ID
    ORDER BY COLS.[column_id]
--##############################################################################
--used for formatting the rest of the constraints:
--##############################################################################
  SELECT
    @STRINGLEN = MAX(LEN([name])) + 1
  FROM sys.objects OBJS
--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
  DECLARE @Results  TABLE (
                    [SCHEMA_ID]             INT,
                    [SCHEMA_NAME]           VARCHAR(255),
                    [OBJECT_ID]             INT,
                    [OBJECT_NAME]           VARCHAR(255),
                    [index_id]              INT,
                    [index_name]            VARCHAR(255),
                    [ROWS]                  BIGINT,
                    [SizeMB]                DECIMAL(19,3),
                    [IndexDepth]            INT,
                    [TYPE]                  INT,
                    [type_desc]             VARCHAR(30),
                    [fill_factor]           INT,
                    [is_unique]             INT,
                    [is_primary_key]        INT ,
                    [is_unique_constraint]  INT,
                    [index_columns_key]     VARCHAR(MAX),
                    [index_columns_include] VARCHAR(MAX),
                    [has_filter] bit ,
                    [filter_definition] VARCHAR(MAX),
                    [currentFilegroupName]  varchar(128),
                    [CurrentCompression]    varchar(128))
  INSERT INTO @Results
    SELECT
      SCH.schema_id, SCH.[name] AS SCHEMA_NAME,
      OBJS.[object_id], OBJS.[name] AS OBJECT_NAME,
      IDX.index_id, ISNULL(IDX.[name], '---') AS index_name,
      partitions.ROWS, partitions.SizeMB, INDEXPROPERTY(OBJS.[object_id], IDX.[name], 'IndexDepth') AS IndexDepth,
      IDX.type, IDX.type_desc, IDX.fill_factor,
      IDX.is_unique, IDX.is_primary_key, IDX.is_unique_constraint,
      ISNULL(Index_Columns.index_columns_key, '---') AS index_columns_key,
      ISNULL(Index_Columns.index_columns_include, '---') AS index_columns_include,
      IDX.[has_filter],
      IDX.[filter_definition],
      filz.name,
      ISNULL(p.data_compression_desc,'')
    FROM sys.objects OBJS
      INNER JOIN sys.schemas SCH ON OBJS.schema_id=SCH.schema_id
      INNER JOIN sys.indexes IDX ON OBJS.[object_id]=IDX.[object_id]
      INNER JOIN sys.filegroups filz ON IDX.data_space_id = filz.data_space_id
      INNER JOIN sys.partitions p     ON  IDX.object_id =  p.object_id  AND IDX.index_id = p.index_id
      INNER JOIN (
                  SELECT
                    [object_id], index_id, SUM(row_count) AS ROWS,
                    CONVERT(NUMERIC(19,3), CONVERT(NUMERIC(19,3), SUM(in_row_reserved_page_count+lob_reserved_page_count+row_overflow_reserved_page_count))/CONVERT(NUMERIC(19,3), 128)) AS SizeMB
                  FROM sys.dm_db_partition_stats STATS
                  GROUP BY [OBJECT_ID], index_id
                 ) AS partitions 
        ON  IDX.[object_id]=partitions.[object_id] 
        AND IDX.index_id=partitions.index_id

    CROSS APPLY (
                 SELECT
                   LEFT(index_columns_key, LEN(index_columns_key)-1) AS index_columns_key,
                  LEFT(index_columns_include, LEN(index_columns_include)-1) AS index_columns_include
                 FROM
                      (
                       SELECT
                              (
                              SELECT QUOTENAME(COLS.[name]) + CASE WHEN IXCOLS.is_descending_key = 0 THEN ' asc' ELSE ' desc' END + ',' + ' '
                               FROM sys.index_columns IXCOLS
                                 INNER JOIN sys.columns COLS
                                   ON  IXCOLS.column_id   = COLS.column_id
                                   AND IXCOLS.[object_id] = COLS.[object_id]
                               WHERE IXCOLS.is_included_column = 0
                                 AND IDX.[object_id] = IXCOLS.[object_id] 
                                 AND IDX.index_id = IXCOLS.index_id
                               ORDER BY key_ordinal
                               FOR XML PATH('')
                              ) AS index_columns_key,
                             (
                             SELECT QUOTENAME(COLS.[name]) + ',' + ' '
                              FROM sys.index_columns IXCOLS
                                INNER JOIN sys.columns COLS
                                  ON  IXCOLS.column_id   = COLS.column_id
                                  AND IXCOLS.[object_id] = COLS.[object_id]
                              WHERE IXCOLS.is_included_column = 1
                                AND IDX.[object_id] = IXCOLS.[object_id] 
                                AND IDX.index_id = IXCOLS.index_id
                              ORDER BY index_column_id
                              FOR XML PATH('')
                             ) AS index_columns_include
                      ) AS Index_Columns
                ) AS Index_Columns
    WHERE SCH.[name]  LIKE CASE 
                                     WHEN @SCHEMANAME = '' 
                                     THEN SCH.[name] 
                                     ELSE @SCHEMANAME 
                                   END
    AND OBJS.[name] LIKE CASE 
                                  WHEN @TBLNAME = ''  
                                  THEN OBJS.[name] 
                                  ELSE @TBLNAME 
                                END
    ORDER BY 
      SCH.[name], 
      OBJS.[name], 
      IDX.[name]
--@Results table has both PK,s Uniques and indexes in thme...pull them out for adding to funal results:
  SET @CONSTRAINTSQLS = ''
  SET @INDEXSQLS      = ''

--##############################################################################
--constriants
--column store indexes are different: the "include" columns for normal indexes as scripted above are the columnstores indexed columns
--add a CASE for that situation.
--##############################################################################
  SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS 
         + CASE
             WHEN is_primary_key = 1 OR is_unique = 1
             THEN @vbCrLf
                  + 'CONSTRAINT   ' + quotename(index_name) + ' '
                  + CASE  
                      WHEN is_primary_key = 1 
                      THEN ' PRIMARY KEY ' 
                      ELSE CASE  
                             WHEN is_unique = 1     
                             THEN ' UNIQUE      '      
                             ELSE '' 
                           END 
                    END
                  + type_desc 
                  + CASE 
                      WHEN type_desc='NONCLUSTERED' 
                      THEN '' 
                      ELSE '   ' 
                    END
                  + ' (' + index_columns_key + ')'
                  + CASE 
                      WHEN index_columns_include <> '---' 
                      THEN ' INCLUDE (' + index_columns_include + ')' 
                      ELSE '' 
                    END
                  + CASE
                      WHEN [has_filter] = 1 
                      THEN ' ' + [filter_definition]
                      ELSE ' '
                    END
                  + CASE WHEN fill_factor <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN fill_factor <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN fill_factor <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN fill_factor <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN fill_factor  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
                      
             ELSE ''
           END + ','
  FROM @RESULTS
  WHERE [type_desc] != 'HEAP'
    AND is_primary_key = 1 
    OR  is_unique = 1
  ORDER BY 
    is_primary_key DESC,
    is_unique DESC
--##############################################################################
--indexes
--##############################################################################
  SELECT @INDEXSQLS = @INDEXSQLS 
         + CASE
             WHEN is_primary_key = 0 OR is_unique = 0
             THEN @vbCrLf
                  + 'CREATE ' + type_desc + ' INDEX ' + quotename(index_name) + ' '
                  + @vbCrLf
                  + '   ON ' 
                  + quotename([schema_name]) + '.' + quotename([OBJECT_NAME])
                  + CASE 
                        WHEN [CurrentCompression] = 'COLUMNSTORE'
                        THEN ' (' + index_columns_include + ')' 
                        ELSE ' (' + index_columns_key + ')'
                    END
                  + CASE 
                      WHEN [CurrentCompression] = 'COLUMNSTORE'
                      THEN ''
                      ELSE
                        CASE
                     WHEN index_columns_include <> '---' 
                     THEN @vbCrLf + '   INCLUDE (' + index_columns_include + ')' 
                     ELSE '' 
                   END
                    END
                  --2008 filtered indexes syntax
                  + CASE 
                      WHEN has_filter = 1 
                      THEN @vbCrLf + '   WHERE ' + filter_definition
                      ELSE ''
                    END
                  + CASE WHEN fill_factor <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN fill_factor <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN fill_factor <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression]+' '
                                    WHEN fill_factor <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN fill_factor  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression]+' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
           END
  FROM @RESULTS
  WHERE [type_desc] != 'HEAP'
    AND is_primary_key = 0 
    AND is_unique = 0
  ORDER BY 
    is_primary_key DESC,
    is_unique DESC

  IF @INDEXSQLS <> ''
    SET @INDEXSQLS = @vbCrLf + 'GO' + @vbCrLf + @INDEXSQLS
--##############################################################################
--CHECK Constraints
--##############################################################################
  SET @CHECKCONSTSQLS = ''
  SELECT
    @CHECKCONSTSQLS = @CHECKCONSTSQLS
    + @vbCrLf
    + ISNULL('CONSTRAINT   ' + quotename(OBJS.[name]) + ' '
    + SPACE(@STRINGLEN - LEN(OBJS.[name]))
    + ' CHECK ' + ISNULL(CHECKS.definition,'')
    + ',','')
  FROM sys.objects OBJS
    INNER JOIN sys.check_constraints CHECKS ON OBJS.[object_id] = CHECKS.[object_id]
  WHERE OBJS.type = 'C'
    AND OBJS.parent_object_id = @TABLE_ID
--##############################################################################
--FOREIGN KEYS
--##############################################################################
  SET @FKSQLS = '' ;
    SELECT
    @FKSQLS=@FKSQLS
    + @vbCrLf + Command FROM
(
SELECT
  DISTINCT
  --FK must be added AFTER the PK/unique constraints are added back.
  850 AS ExecutionOrder,
  'CONSTRAINT ' 
  + QUOTENAME(conz.name) 
  + ' FOREIGN KEY (' 
  + ChildCollection.ChildColumns 
  + ') REFERENCES ' 
  + QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.referenced_object_id)) 
  + ' (' + ParentCollection.ParentColumns 
  + ') ' 

  +  CASE conz.update_referential_action
                                        WHEN 0 THEN '' --' ON UPDATE NO ACTION '
                                        WHEN 1 THEN ' ON UPDATE CASCADE '
                                        WHEN 2 THEN ' ON UPDATE SET NULL '
                                        ELSE ' ON UPDATE SET DEFAULT '
                                    END
                  + CASE conz.delete_referential_action
                                        WHEN 0 THEN '' --' ON DELETE NO ACTION '
                                        WHEN 1 THEN ' ON DELETE CASCADE '
                                        WHEN 2 THEN ' ON DELETE SET NULL '
                                        ELSE ' ON DELETE SET DEFAULT '
                                    END
                  + CASE conz.is_not_for_replication
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
  + ',' AS Command
FROM   sys.foreign_keys conz
       INNER JOIN sys.foreign_key_columns colz
         ON conz.object_id = colz.constraint_object_id
      
       INNER JOIN (--gets my child tables column names   
SELECT
 conz.name,
 --technically, FK's can contain up to 16 columns, but real life is often a single column. coding here is for all columns
 ChildColumns = STUFF((SELECT 
                         ',' + QUOTENAME(REFZ.name)
                       FROM   sys.foreign_key_columns fkcolz
                              INNER JOIN sys.columns REFZ
                                ON fkcolz.parent_object_id = REFZ.object_id
                                   AND fkcolz.parent_column_id = REFZ.column_id
                       WHERE fkcolz.parent_object_id = conz.parent_object_id
                           AND fkcolz.constraint_object_id = conz.object_id
                         ORDER  BY
                        fkcolz.constraint_column_id
                      FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
FROM   sys.foreign_keys conz
      INNER JOIN sys.foreign_key_columns colz
        ON conz.object_id = colz.constraint_object_id
        WHERE conz.parent_object_id= @TABLE_ID
GROUP  BY
conz.name,
conz.parent_object_id,--- without GROUP BY multiple rows are returned
 conz.object_id
    ) ChildCollection
         ON conz.name = ChildCollection.name
       INNER JOIN (--gets the parent tables column names for the FK reference
                  SELECT
                     conz.name,
                     ParentColumns = STUFF((SELECT
                                              ',' + REFZ.name
                                            FROM   sys.foreign_key_columns fkcolz
                                                   INNER JOIN sys.columns REFZ
                                                     ON fkcolz.referenced_object_id = REFZ.object_id
                                                        AND fkcolz.referenced_column_id = REFZ.column_id
                                            WHERE  fkcolz.referenced_object_id = conz.referenced_object_id
                                              AND fkcolz.constraint_object_id = conz.object_id
                                            ORDER BY fkcolz.constraint_column_id
                                            FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
                   FROM   sys.foreign_keys conz
                          INNER JOIN sys.foreign_key_columns colz
                            ON conz.object_id = colz.constraint_object_id
                           -- AND colz.parent_column_id 
                   GROUP  BY
                    conz.name,
                    conz.referenced_object_id,--- without GROUP BY multiple rows are returned
                    conz.object_id
                  ) ParentCollection
         ON conz.name = ParentCollection.name
)MyAlias


--##############################################################################
--RULES
--##############################################################################
  SET @RULESCONSTSQLS = ''
  SELECT
    @RULESCONSTSQLS = @RULESCONSTSQLS
    + ISNULL(
             @vbCrLf
             + 'if not exists(SELECT [name] FROM sys.objects WHERE TYPE=''R'' AND schema_id = ' + CONVERT(VARCHAR(30),OBJS.schema_id) + ' AND [name] = ''' + quotename(OBJECT_NAME(COLS.[rule_object_id])) + ''')' + @vbCrLf
             + MODS.definition  + @vbCrLf + 'GO' +  @vbCrLf
             + 'EXEC sp_binderule  ' + quotename(OBJS.[name]) + ', ''' + quotename(OBJECT_NAME(COLS.[object_id])) + '.' + quotename(COLS.[name]) + '''' + @vbCrLf + 'GO' ,'')
  FROM sys.columns COLS 
    INNER JOIN sys.objects OBJS
      ON OBJS.[object_id] = COLS.[object_id]
    INNER JOIN sys.sql_modules MODS
      ON COLS.[rule_object_id] = MODS.[object_id]
  WHERE COLS.[rule_object_id] <> 0
    AND COLS.[object_id] = @TABLE_ID
--##############################################################################
--TRIGGERS
--##############################################################################
  SET @TRIGGERSTATEMENT = ''
  SELECT
    @TRIGGERSTATEMENT = @TRIGGERSTATEMENT +  @vbCrLf + MODS.[definition] + @vbCrLf + 'GO'
  FROM sys.sql_modules MODS
  WHERE [OBJECT_ID] IN(SELECT
                         [OBJECT_ID]
                       FROM sys.objects OBJS
                       WHERE TYPE = 'TR'
                       AND [parent_object_id] = @TABLE_ID)
  IF @TRIGGERSTATEMENT <> ''
    SET @TRIGGERSTATEMENT = @vbCrLf + 'GO' + @vbCrLf + @TRIGGERSTATEMENT
--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
  SET @EXTENDEDPROPERTIES = ''
  SELECT  @EXTENDEDPROPERTIES =
          @EXTENDEDPROPERTIES + @vbCrLf +
         'EXEC sys.sp_addextendedproperty
          @name = N''' + [name] + ''', @value = N''' + REPLACE(CONVERT(VARCHAR(MAX),[VALUE]),'''','''''') + ''',
          @level0type = N''SCHEMA'', @level0name = ' + quotename(@SCHEMANAME) + ',
          @level1type = N''TABLE'', @level1name = ' + quotename(@TBLNAME) + ';'
 --SELECT objtype, objname, name, value
  FROM fn_listextendedproperty (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, NULL, NULL);
  --OMacoder suggestion for column extended properties http://www.sqlservercentral.com/Forums/FindPost1651606.aspx
   ;WITH obj AS (
	SELECT split.a.value('.', 'VARCHAR(20)') AS name
	FROM ( 
		SELECT CAST ('<M>' + REPLACE('column,constraint,index,trigger,parameter', ',', '</M><M>') + '</M>' AS XML) AS data 
		) AS A 
		CROSS APPLY data.nodes ('/M') AS split(a)
	)
  SELECT 
  @EXTENDEDPROPERTIES =
		 @EXTENDEDPROPERTIES + @vbCrLf + @vbCrLf +
         'EXEC sys.sp_addextendedproperty
         @name = N''' + lep.[name] + ''', @value = N''' + REPLACE(convert(varchar(max),lep.[value]),'''','''''') + ''',
         @level0type = N''SCHEMA'', @level0name = ' + quotename(@SCHEMANAME) + ',
         @level1type = N''TABLE'', @level1name = ' + quotename(@TBLNAME) + ',
         @level2type = N''' + UPPER(obj.name)  + ''', @level2name = ' + quotename(lep.[objname]) + ';'
  --SELECT objtype, objname, name, value
  FROM obj 
	CROSS APPLY fn_listextendedproperty (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, obj.name, NULL) AS lep;  
  
  IF @EXTENDEDPROPERTIES <> ''
    SET @EXTENDEDPROPERTIES = @vbCrLf + 'GO' + @vbCrLf + @EXTENDEDPROPERTIES
--##############################################################################
--FINAL CLEANUP AND PRESENTATION
--##############################################################################
--at this point, there is a trailing comma, or it blank
  SELECT
    @FINALSQL = @FINALSQL
                + @CONSTRAINTSQLS
                + @CHECKCONSTSQLS
                + @FKSQLS
--note that this trims the trailing comma from the end of the statements
  SET @FINALSQL = SUBSTRING(@FINALSQL,1,LEN(@FINALSQL) -1) ;
  SET @FINALSQL = @FINALSQL + ')' + @vbCrLf ;

  SET @input = @vbCrLf
       + @FINALSQL
       + @INDEXSQLS
       + @RULESCONSTSQLS
       + @TRIGGERSTATEMENT
       + @EXTENDEDPROPERTIES

  SELECT @input AS Item;
  RETURN 0;     
--##############################################################################
-- END Normal Table Processing
--############################################################################## 
    
--simple, primitive version to get the results of a TEMP table from the TEMP db.  
--##############################################################################
-- NEW Temp Table Logic
--##############################################################################     
TEMPPROCESS:
  SELECT @TABLE_ID = OBJECT_ID('tempdb..' + @TBLNAME)

--##############################################################################
-- Valid temp Table, Continue Processing
--##############################################################################
SELECT 
  @FINALSQL =  'IF OBJECT_ID(''tempdb.' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
               + 'DROP TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf + 'GO' + @vbcrlf
               + 'CREATE TABLE ' + quotename(@SCHEMANAME) + '.' + quotename(@TBLNAME) + ' ( '
  --removed invalud cide here which potentially selected wrong table--thansk David Grifiths @SSC!
  SELECT
    @STRINGLEN = MAX(LEN(COLS.[name])) + 1
  FROM tempdb.sys.objects OBJS
    INNER JOIN tempdb.sys.columns COLS
      ON  OBJS.[object_id] = COLS.[object_id]
      AND OBJS.[object_id] = @TABLE_ID;
--##############################################################################
--Get the columns, their definitions and defaults.
--##############################################################################
  SELECT
    @FINALSQL = @FINALSQL
    + CASE
        WHEN COLS.[is_computed] = 1
        THEN @vbCrLf
             + QUOTENAME(COLS.[name])
             + ' '
             + SPACE(@STRINGLEN - LEN(COLS.[name]))
             + 'AS ' + ISNULL(CALC.definition,'')
              + CASE 
                 WHEN CALC.is_persisted = 1 
                 THEN ' PERSISTED'
                 ELSE ''
               END
        ELSE @vbCrLf
             + QUOTENAME(COLS.[name])
             + ' '
             + SPACE(@STRINGLEN - LEN(COLS.[name]))
             + UPPER(TYPE_NAME(COLS.[user_type_id]))
             + CASE
-- data types with precision and scale  IE DECIMAL(18,3), NUMERIC(10,2)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('decimal','numeric')
               THEN '('
                    + CONVERT(VARCHAR,COLS.[precision])
                    + ','
                    + CONVERT(VARCHAR,COLS.[scale])
                    + ') '
                    + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[precision])
                    + ','
                    + CONVERT(VARCHAR,COLS.[scale])))
                    + SPACE(7)
                    + SPACE(16 - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + CASE
                        WHEN COLS.is_identity = 1
                        THEN ' IDENTITY(1,1)'
                        ELSE ''
                        ----WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 1
                        ----THEN ' IDENTITY('
                        ----       + CONVERT(VARCHAR,ISNULL(IDENT_SEED('tempdb..' + @TBLNAME),1) )
                        ----       + ','
                        ----       + CONVERT(VARCHAR,ISNULL(IDENT_INCR('tempdb..' + @TBLNAME),1) )
                        ----       + ')'
                        ----ELSE ''
                        END
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
-- data types with scale  IE datetime2(7),TIME(7)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('datetime2','datetimeoffset','time')
               THEN CASE 
                      WHEN COLS.[scale] < 7 THEN
                      '('
                      + CONVERT(VARCHAR,COLS.[scale])
                      + ') '
                    ELSE 
                      '    '
                    END
                    + SPACE(4)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + '        '
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
--data types with no/precision/scale,IE  FLOAT
               WHEN  TYPE_NAME(COLS.[user_type_id]) IN ('float') --,'real')
               THEN
               --addition: if 53, no need to specifically say (53), otherwise display it
                    CASE
                      WHEN COLS.[precision] = 53
                      THEN SPACE(11 - LEN(CONVERT(VARCHAR,COLS.[precision])))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,COLS.[precision])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[precision])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      END
--ie VARCHAR(40)
--##############################################################################
-- COLLATE STATEMENTS in tempdb!
-- personally i do not like collation statements,
-- but included here to make it easy on those who do
--##############################################################################

               WHEN  TYPE_NAME(COLS.[user_type_id]) IN ('char','varchar','binary','varbinary')
               THEN CASE
                      WHEN  COLS.[max_length] = -1
                      THEN  '(max)'
                            + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[max_length])))
                            + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                            ----collate to comment out when not desired
                            --+ CASE
                            --    WHEN COLS.collation_name IS NULL
                            --    THEN ''
                            --    ELSE ' COLLATE ' + COLS.collation_name
                            --  END
                            + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN COLS.[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
                      ELSE '('
                           + CONVERT(VARCHAR,COLS.[max_length])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,COLS.[max_length])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--data type with max_length ( BUT DOUBLED) ie NCHAR(33), NVARCHAR(40)
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('nchar','nvarchar')
               THEN CASE
                      WHEN  COLS.[max_length] = -1
                      THEN '(max)'
                           + SPACE(5 - LEN(CONVERT(VARCHAR,(COLS.[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           -- --collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN  ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,(COLS.[max_length] / 2))
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,(COLS.[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                           -- --collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN COLS.[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--  other data type 	IE INT, DATETIME, MONEY, CUSTOM DATA TYPE,...
               WHEN TYPE_NAME(COLS.[user_type_id]) IN ('datetime','money','text','image','real')
               THEN SPACE(18 - LEN(TYPE_NAME(COLS.[user_type_id])))
                    + '              '
                    + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN COLS.[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--IE INT
               ELSE SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME(COLS.[user_type_id])))
                            + CASE
                                WHEN COLS.is_identity = 1
                                THEN ' IDENTITY(1,1)'
                                ELSE '              '
                                ----WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 1
                                ----THEN ' IDENTITY('
                                ----     + CONVERT(VARCHAR,ISNULL(IDENT_SEED('tempdb..' + @TBLNAME),1) )
                                ----     + ','
                                ----     + CONVERT(VARCHAR,ISNULL(IDENT_INCR('tempdb..' + @TBLNAME),1) )
                                ----     + ')'
                                ----ELSE '              '
                              END
                            + SPACE(2)
                            + CASE  WHEN COLS.[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN COLS.[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
               END
             + CASE
                 WHEN COLS.[default_object_id] = 0
                 THEN ''
                 ELSE ' DEFAULT '  + ISNULL(DEF.[definition] ,'')
                 --optional section in case NAMED default cosntraints are needed:
                 --ELSE ' CONSTRAINT [' + DEF.name + '] DEFAULT '+ REPLACE(REPLACE(ISNULL(DEF.[definition] ,''),'((','('),'))',')')
                        --i thought it needed to be handled differently! NOT!
               END  --CASE cdefault



      END --iscomputed
    + ','
    FROM tempdb.sys.columns COLS
      LEFT OUTER JOIN  tempdb.sys.default_constraints  DEF
        ON COLS.[default_object_id] = DEF.[object_id]
      LEFT OUTER JOIN tempdb.sys.computed_columns CALC
         ON  COLS.[object_id] = CALC.[object_id]
         AND COLS.[column_id] = CALC.[column_id]
    WHERE COLS.[object_id]=@TABLE_ID
    ORDER BY COLS.[column_id]
--##############################################################################
--used for formatting the rest of the constraints:
--##############################################################################
  SELECT
    @STRINGLEN = MAX(LEN([name])) + 1
  FROM tempdb.sys.objects OBJS
--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
  DECLARE @Results2  TABLE (
                    [SCHEMA_ID]             INT,
                    [SCHEMA_NAME]           VARCHAR(255),
                    [OBJECT_ID]             INT,
                    [OBJECT_NAME]           VARCHAR(255),
                    [index_id]              INT,
                    [index_name]            VARCHAR(255),
                    [ROWS]                  BIGINT,
                    [SizeMB]                DECIMAL(19,3),
                    [IndexDepth]            INT,
                    [TYPE]                  INT,
                    [type_desc]             VARCHAR(30),
                    [fill_factor]           INT,
                    [is_unique]             INT,
                    [is_primary_key]        INT ,
                    [is_unique_constraint]  INT,
                    [index_columns_key]     VARCHAR(MAX),
                    [index_columns_include] VARCHAR(MAX),
                    [has_filter] bit ,
                    [filter_definition] VARCHAR(MAX),
                    [currentFilegroupName]  varchar(128),
                    [CurrentCompression]    varchar(128))
  INSERT INTO @Results2
    SELECT
      SCH.schema_id, SCH.[name] AS SCHEMA_NAME,
      OBJS.[object_id], OBJS.[name] AS OBJECT_NAME,
      IDX.index_id, ISNULL(IDX.[name], '---') AS index_name,
      partitions.ROWS, partitions.SizeMB, INDEXPROPERTY(OBJS.[object_id], IDX.[name], 'IndexDepth') AS IndexDepth,
      IDX.type, IDX.type_desc, IDX.fill_factor,
      IDX.is_unique, IDX.is_primary_key, IDX.is_unique_constraint,
      ISNULL(Index_Columns.index_columns_key, '---') AS index_columns_key,
      ISNULL(Index_Columns.index_columns_include, '---') AS index_columns_include,
      IDX.has_filter,
      IDX.filter_definition,
      filz.name,
      ISNULL(p.data_compression_desc,'')
    FROM tempdb.sys.objects OBJS
      INNER JOIN tempdb.sys.schemas SCH ON OBJS.schema_id=SCH.schema_id
      INNER JOIN tempdb.sys.indexes IDX ON OBJS.[object_id]=IDX.[object_id]
      INNER JOIN sys.filegroups filz ON IDX.data_space_id = filz.data_space_id
      INNER JOIN sys.partitions p     ON  IDX.object_id =  p.object_id  AND IDX.index_id = p.index_id
      INNER JOIN (
                  SELECT
                    [object_id], index_id, SUM(row_count) AS ROWS,
                    CONVERT(NUMERIC(19,3), CONVERT(NUMERIC(19,3), SUM(in_row_reserved_page_count+lob_reserved_page_count+row_overflow_reserved_page_count))/CONVERT(NUMERIC(19,3), 128)) AS SizeMB
                  FROM tempdb.sys.dm_db_partition_stats STATS
                  GROUP BY [OBJECT_ID], index_id
                 ) AS partitions 
        ON  IDX.[object_id]=partitions.[object_id] 
        AND IDX.index_id=partitions.index_id
    CROSS APPLY (
                 SELECT
                   LEFT(index_columns_key, LEN(index_columns_key)-1) AS index_columns_key,
                  LEFT(index_columns_include, LEN(index_columns_include)-1) AS index_columns_include
                 FROM
                      (
                       SELECT
                              (
                              SELECT QUOTENAME(COLS.[name]) + CASE WHEN IXCOLS.is_descending_key = 0 THEN ' asc' ELSE ' desc' END + ',' + ' '
                               FROM tempdb.sys.index_columns IXCOLS
                                 INNER JOIN tempdb.sys.columns COLS
                                   ON  IXCOLS.column_id   = COLS.column_id
                                   AND IXCOLS.[object_id] = COLS.[object_id]
                               WHERE IXCOLS.is_included_column = 0
                                 AND IDX.[object_id] = IXCOLS.[object_id] 
                                 AND IDX.index_id = IXCOLS.index_id
                               ORDER BY key_ordinal
                               FOR XML PATH('')
                              ) AS index_columns_key,
                             (
                             SELECT QUOTENAME(COLS.[name]) + ',' + ' '
                              FROM tempdb.sys.index_columns IXCOLS
                                INNER JOIN tempdb.sys.columns COLS
                                  ON  IXCOLS.column_id   = COLS.column_id
                                  AND IXCOLS.[object_id] = COLS.[object_id]
                              WHERE IXCOLS.is_included_column = 1
                                AND IDX.[object_id] = IXCOLS.[object_id] 
                                AND IDX.index_id = IXCOLS.index_id
                              ORDER BY index_column_id
                              FOR XML PATH('')
                             ) AS index_columns_include
                      ) AS Index_Columns
                ) AS Index_Columns
    WHERE SCH.[name]  LIKE CASE 
                                     WHEN @SCHEMANAME = '' 
                                     THEN SCH.[name] 
                                     ELSE @SCHEMANAME 
                                   END
    AND OBJS.[name] LIKE CASE 
                                  WHEN @TBLNAME = ''  
                                  THEN OBJS.[name] 
                                  ELSE @TBLNAME 
                                END
    ORDER BY 
      SCH.[name], 
      OBJS.[name], 
      IDX.[name]
--@Results2 table has both PK,s Uniques and indexes in thme...pull them out for adding to funal results:
  SET @CONSTRAINTSQLS = ''
  SET @INDEXSQLS      = ''

--##############################################################################
--constriants
--##############################################################################
  SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS 
         + CASE
             WHEN is_primary_key = 1 OR is_unique = 1
             THEN @vbCrLf
                  + 'CONSTRAINT   ' + quotename(index_name) + ' '
                  + SPACE(@STRINGLEN - LEN(index_name))
                  + CASE  
                      WHEN is_primary_key = 1 
                      THEN ' PRIMARY KEY ' 
                      ELSE CASE  
                             WHEN is_unique = 1     
                             THEN ' UNIQUE      '      
                             ELSE '' 
                           END 
                    END
                  + type_desc 
                  + CASE 
                      WHEN type_desc='NONCLUSTERED' 
                      THEN '' 
                      ELSE '   ' 
                    END
                  + ' (' + index_columns_key + ')'
                  + CASE 
                      WHEN index_columns_include <> '---' 
                      THEN ' INCLUDE (' + index_columns_include + ')' 
                      ELSE '' 
                    END
                  + CASE
                      WHEN [has_filter] = 1 
                      THEN ' ' + [filter_definition]
                      ELSE ' '
                    END
                  + CASE WHEN fill_factor <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN fill_factor <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN fill_factor <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN fill_factor <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN fill_factor  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
             ELSE ''
           END + ','
  FROM @Results2
  WHERE [type_desc] != 'HEAP'
    AND is_primary_key = 1 
    OR  is_unique = 1
  ORDER BY 
    is_primary_key DESC,
    is_unique DESC
--##############################################################################
--indexes
--##############################################################################
  SELECT @INDEXSQLS = @INDEXSQLS 
         + CASE
             WHEN is_primary_key = 0 OR is_unique = 0
             THEN @vbCrLf
                  + 'CREATE ' + type_desc + ' INDEX ' + quotename(index_name) + ' '
                  + @vbCrLf
                  + '   ON ' 
                  + quotename([schema_name]) + '.' + quotename([OBJECT_NAME])
                  + CASE 
                        WHEN [CurrentCompression] = 'COLUMNSTORE'
                        THEN ' (' + index_columns_include + ')' 
                        ELSE ' (' + index_columns_key + ')'
                    END
                  + CASE 
                      WHEN [CurrentCompression] = 'COLUMNSTORE'
                      THEN ''
                      ELSE
                        CASE
                     WHEN index_columns_include <> '---' 
                     THEN @vbCrLf + '   INCLUDE (' + index_columns_include + ')' 
                     ELSE '' 
                   END
                    END
                  --2008 filtered indexes syntax
                  + CASE 
                      WHEN has_filter = 1 
                      THEN @vbCrLf + '   WHERE ' + filter_definition
                      ELSE ''
                    END
                  + CASE WHEN fill_factor <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN fill_factor <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN fill_factor <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN fill_factor <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN fill_factor  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
           END
  FROM @Results2
  WHERE [type_desc] != 'HEAP'
    AND is_primary_key = 0 
    AND is_unique = 0
  ORDER BY 
    is_primary_key DESC,
    is_unique DESC

  IF @INDEXSQLS <> ''
    SET @INDEXSQLS = @vbCrLf + 'GO' + @vbCrLf + @INDEXSQLS
--##############################################################################
--CHECK Constraints
--##############################################################################
  SET @CHECKCONSTSQLS = ''
  SELECT
    @CHECKCONSTSQLS = @CHECKCONSTSQLS
    + @vbCrLf
    + ISNULL('CONSTRAINT   ' + quotename(OBJS.[name]) + ' '
    + SPACE(@STRINGLEN - LEN(OBJS.[name]))
    + ' CHECK ' + ISNULL(CHECKS.definition,'')
    + ',','')
  FROM tempdb.sys.objects OBJS
    INNER JOIN tempdb.sys.check_constraints CHECKS ON OBJS.[object_id] = CHECKS.[object_id]
  WHERE OBJS.type = 'C'
    AND OBJS.parent_object_id = @TABLE_ID
--##############################################################################
--FOREIGN KEYS
--##############################################################################
  SET @FKSQLS = '' ;
    SELECT
    @FKSQLS=@FKSQLS
    + @vbCrLf + Command FROM
(
SELECT
  DISTINCT
  --FK must be added AFTER the PK/unique constraints are added back.
  850 AS ExecutionOrder,
  'CONSTRAINT ' 
  + QUOTENAME(conz.name) 
  + ' FOREIGN KEY (' 
  + ChildCollection.ChildColumns 
  + ') REFERENCES ' 
  + QUOTENAME(SCHEMA_NAME(conz.schema_id)) 
  + '.' 
  + QUOTENAME(OBJECT_NAME(conz.referenced_object_id)) 
  + ' (' + ParentCollection.ParentColumns 
  + ') ' 
   +  CASE conz.update_referential_action
                                        WHEN 0 THEN '' --' ON UPDATE NO ACTION '
                                        WHEN 1 THEN ' ON UPDATE CASCADE '
                                        WHEN 2 THEN ' ON UPDATE SET NULL '
                                        ELSE ' ON UPDATE SET DEFAULT '
                                    END
                  + CASE conz.delete_referential_action
                                        WHEN 0 THEN '' --' ON DELETE NO ACTION '
                                        WHEN 1 THEN ' ON DELETE CASCADE '
                                        WHEN 2 THEN ' ON DELETE SET NULL '
                                        ELSE ' ON DELETE SET DEFAULT '
                                    END
                  + CASE conz.is_not_for_replication
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
  + ',' AS Command
FROM   sys.foreign_keys conz
       INNER JOIN sys.foreign_key_columns colz
         ON conz.object_id = colz.constraint_object_id
      
       INNER JOIN (--gets my child tables column names   
SELECT
 conz.name,
 --technically, FK's can contain up to 16 columns, but real life is often a single column. coding here is for all columns
 ChildColumns = STUFF((SELECT 
                         ',' + QUOTENAME(REFZ.name)
                       FROM   sys.foreign_key_columns fkcolz
                              INNER JOIN sys.columns REFZ
                                ON fkcolz.parent_object_id = REFZ.object_id
                                   AND fkcolz.parent_column_id = REFZ.column_id
                       WHERE fkcolz.parent_object_id = conz.parent_object_id
                           AND fkcolz.constraint_object_id = conz.object_id
                         ORDER  BY
                        fkcolz.constraint_column_id
                       FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
FROM   sys.foreign_keys conz
      INNER JOIN sys.foreign_key_columns colz
        ON conz.object_id = colz.constraint_object_id
 WHERE conz.parent_object_id= @TABLE_ID
GROUP  BY
conz.name,
conz.parent_object_id,--- without GROUP BY multiple rows are returned
 conz.object_id
    ) ChildCollection
         ON conz.name = ChildCollection.name
       INNER JOIN (--gets the parent tables column names for the FK reference
                  SELECT
                     conz.name,
                     ParentColumns = STUFF((SELECT
                                              ',' + REFZ.name
                                            FROM   sys.foreign_key_columns fkcolz
                                                   INNER JOIN sys.columns REFZ
                                                     ON fkcolz.referenced_object_id = REFZ.object_id
                                                        AND fkcolz.referenced_column_id = REFZ.column_id
                                            WHERE  fkcolz.referenced_object_id = conz.referenced_object_id
                                              AND fkcolz.constraint_object_id = conz.object_id
                                            ORDER BY fkcolz.constraint_column_id
                                            FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
                   FROM   sys.foreign_keys conz
                          INNER JOIN sys.foreign_key_columns colz
                            ON conz.object_id = colz.constraint_object_id
                           -- AND colz.parent_column_id 
                   GROUP  BY
                    conz.name,
                    conz.referenced_object_id,--- without GROUP BY multiple rows are returned
                    conz.object_id
                  ) ParentCollection
         ON conz.name = ParentCollection.name
)MyAlias

--##############################################################################
--RULES
--##############################################################################
  SET @RULESCONSTSQLS = ''
  SELECT
    @RULESCONSTSQLS = @RULESCONSTSQLS
    + ISNULL(
             @vbCrLf
             + 'if not exists(SELECT [name] FROM tempdb.sys.objects WHERE TYPE=''R'' AND schema_id = ' + CONVERT(VARCHAR(30),OBJS.schema_id) + ' AND [name] = ''' + quotename(OBJECT_NAME(COLS.[rule_object_id])) + ''')' + @vbCrLf
             + MODS.definition  + @vbCrLf + 'GO' +  @vbCrLf
             + 'EXEC sp_binderule  ' + quotename(OBJS.[name]) + ', ''' + quotename(OBJECT_NAME(COLS.[object_id])) + '.' + quotename(COLS.[name]) + '''' + @vbCrLf + 'GO' ,'')
  FROM tempdb.sys.columns COLS 
    INNER JOIN tempdb.sys.objects OBJS
      ON OBJS.[object_id] = COLS.[object_id]
    INNER JOIN tempdb.sys.sql_modules MODS
      ON COLS.[rule_object_id] = MODS.[object_id]
  WHERE COLS.[rule_object_id] <> 0
    AND COLS.[object_id] = @TABLE_ID
--##############################################################################
--TRIGGERS
--##############################################################################
  SET @TRIGGERSTATEMENT = ''
  SELECT
    @TRIGGERSTATEMENT = @TRIGGERSTATEMENT +  @vbCrLf + MODS.[definition] + @vbCrLf + 'GO'
  FROM tempdb.sys.sql_modules MODS
  WHERE [OBJECT_ID] IN(SELECT
                         [OBJECT_ID]
                       FROM tempdb.sys.objects OBJS
                       WHERE TYPE = 'TR'
                       AND [parent_object_id] = @TABLE_ID)
  IF @TRIGGERSTATEMENT <> ''
    SET @TRIGGERSTATEMENT = @vbCrLf + 'GO' + @vbCrLf + @TRIGGERSTATEMENT
--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
  SET @EXTENDEDPROPERTIES = ''
  SELECT  @EXTENDEDPROPERTIES =
          @EXTENDEDPROPERTIES + @vbCrLf +
         'EXEC tempdb.sys.sp_addextendedproperty
          @name = N''' + [name] + ''', @value = N''' + REPLACE(CONVERT(VARCHAR(MAX),[VALUE]),'''','''''') + ''',
          @level0type = N''SCHEMA'', @level0name = ' + quotename(@SCHEMANAME + ',
          @level1type = N''TABLE'', @level1name = [' + @TBLNAME) + '];'
 --SELECT objtype, objname, name, value
  FROM fn_listextendedproperty (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, NULL, NULL);
  --OMacoder suggestion for column extended properties http://www.sqlservercentral.com/Forums/FindPost1651606.aspx
  SELECT @EXTENDEDPROPERTIES =
         @EXTENDEDPROPERTIES + @vbCrLf +
         'EXEC sys.sp_addextendedproperty
         @name = N''' + [name] + ''', @value = N''' + REPLACE(convert(varchar(max),[value]),'''','''''') + ''',
         @level0type = N''SCHEMA'', @level0name = ' + quotename(@SCHEMANAME) + ',
         @level1type = N''TABLE'', @level1name = ' + quotename(@TBLNAME) + ',
         @level2type = N''COLUMN'', @level2name = ' + quotename([objname]) + ';'
  --SELECT objtype, objname, name, value
  FROM fn_listextendedproperty (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, 'column', NULL)
  IF @EXTENDEDPROPERTIES <> ''
    SET @EXTENDEDPROPERTIES = @vbCrLf + 'GO' + @vbCrLf + @EXTENDEDPROPERTIES
--##############################################################################
--FINAL CLEANUP AND PRESENTATION
--##############################################################################
--at this point, there is a trailing comma, or it blank
  SELECT
    @FINALSQL = @FINALSQL
                + @CONSTRAINTSQLS
                + @CHECKCONSTSQLS
                + @FKSQLS
--note that this trims the trailing comma from the end of the statements
  SET @FINALSQL = SUBSTRING(@FINALSQL,1,LEN(@FINALSQL) -1) ;
  SET @FINALSQL = @FINALSQL + ')' + @vbCrLf ;

  SET @input = @vbCrLf
       + @FINALSQL
       + @INDEXSQLS
       + @RULESCONSTSQLS
       + @TRIGGERSTATEMENT
       + @EXTENDEDPROPERTIES
  SELECT @input AS Item;
         
  RETURN 0;     
END --PROC

GO
/****** Object:  StoredProcedure [tool].[GetTableDiff]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [tool].[GetTableDiff]
AS

DECLARE 
	@DATABASE_LEFT		SYSNAME = ''
,	@DATABASE_RIGHT		SYSNAME = ''
,	@SCHEMA_LEFT		SYSNAME = 'ini'
,	@SCHEMA_RIGHT		SYSNAME = 'ext'
,	@ENTITY_LEFT		SYSNAME = 'BSEG_Accounting_Segment'
,	@ENTITY_RIGHT		SYSNAME = 'BSEG_Accounting_Segment'

DECLARE 
	@sql_statement 		NVARCHAR(MAX)
	
SET @sql_statement = '
	SELECT ENTLEFT.name as ENTLEFT_ColumnName, 
	ENTRIGHT.name as ENTRIGHT_ColumnName, 
	ENTLEFT.is_nullable as ENTLEFT_is_nullable, 
	ENTRIGHT.is_nullable as ENTRIGHT_is_nullable, 
	ENTLEFT.system_type_name as ENTLEFT_Datatype, 
	ENTRIGHT.system_type_name as ENTRIGHT_Datatype, 
	ENTLEFT.is_identity_column as ENTLEFT_is_identity, 
	ENTRIGHT.is_identity_column as ENTRIGHT_is_identity ,
	IIF(ENTLEFT.system_type_name = ENTRIGHT.system_type_name, 1, 0) AS is_system_type_match
	FROM sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_LEFT) + '.' + QUOTENAME(@ENTITY_LEFT) + 
			''', NULL, 0) AS ENTLEFT 
	FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (
		N''SELECT * FROM ' + 
			QUOTENAME(@SCHEMA_RIGHT) + '.' + QUOTENAME(@ENTITY_RIGHT) + 
		''', NULL, 0) AS ENTRIGHT
	ON ENTLEFT.name = ENTRIGHT.name
'
PRINT(@sql_statement)
EXECUTE sp_executesql
	@stmt = @sql_statement
	
GO
/****** Object:  StoredProcedure [tool].[RenameColumn]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [tool].[RenameColumn]
(
  @schemaname SYSNAME
  ,@tablename SYSNAME
  ,@columnname SYSNAME
  ,@columnrename SYSNAME = @columnname
  ,@datatype SYSNAME
  ,@executionmode bit = 0
)
AS BEGIN

  -- Check input parameters
  IF (LTRIM(RTRIM(ISNULL(@schemaname, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter schema name (@schemaname) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@tablename, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter table name (@tablename) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@columnname, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter column name (@columnname) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@columnrename, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter column rename (@columnrename), if specified, it can not be empty.', 16, 1);
    RETURN;
  END;

  IF (LTRIM(RTRIM(ISNULL(@datatype, ''))) = '')
  BEGIN
    RAISERROR(N'The parameter data type (@datatype) is not specified or is empty.', 16, 1);
    RETURN;
  END;

  IF NOT EXISTS (SELECT
                   ORDINAL_POSITION
                 FROM
                   INFORMATION_SCHEMA.COLUMNS
                 WHERE
                   (TABLE_SCHEMA=@schemaname)
                   AND (TABLE_NAME=@tablename)
                   AND (COLUMN_NAME=@columnname))
  BEGIN
    RAISERROR(N'The object has not been found.', 16, 1);
    RETURN;
  END;

  -- Let's go!
  BEGIN TRY
    SET NOCOUNT ON;

    -- Create temporary table
    CREATE TABLE #tmp_uRenameColumn
    (
      schemaname SYSNAME NOT NULL
      ,tablename SYSNAME NOT NULL
      ,objecttype SYSNAME NOT NULL
      ,operationtype NVARCHAR(1) NOT NULL
      ,sqltext NVARCHAR(MAX) NOT NULL
    );

    -- Foreign key section
    -- Drop foreign key
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      schemap.name AS schemaname
      ,objp.name AS tablename
      ,'FK' AS objecttype
      ,'D' AS operationtype,
      ('ALTER TABLE [' + RTRIM(schemap.name) + '].[' + RTRIM(objp.name) + '] ' +
       'DROP CONSTRAINT [' + RTRIM(constr.name) + '];') AS sqltext
    FROM
      sys.foreign_key_columns AS fkc
    JOIN
      sys.objects AS objp ON objp.object_id=fkc.parent_object_id
    JOIN
      sys.schemas AS schemap ON objp.schema_id=schemap.schema_id
    JOIN
      sys.objects AS objr ON objr.object_id=fkc.referenced_object_id
    JOIN
      sys.schemas AS schemar ON objr.schema_id=schemar.schema_id
    JOIN
      sys.columns AS colr ON colr.column_id=fkc.referenced_column_id and colr.object_id=fkc.referenced_object_id
    JOIN
      sys.columns AS colp ON colp.column_id=fkc.parent_column_id and colp.object_id=fkc.parent_object_id
    JOIN
      sys.objects AS constr ON constr.object_id=fkc.constraint_object_id
    WHERE
      -- ToDo
      ((schemar.name=@schemaname) AND (objr.name=@tablename) AND (colr.name=@columnname) AND (objr.type='U')) OR
      ((schemap.name=@schemaname) AND (objp.name=@tablename) AND (colp.name=@columnname) AND (objr.type='U'));

    -- Create foreign key
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      schemap.name AS schemaname
      ,objp.name AS tablename
      ,'FK' AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(schemap.name) + '].[' + RTRIM(objp.name) + '] ' + 
        CASE (fk.is_not_trusted)
          WHEN 0 THEN 'WITH CHECK ADD CONSTRAINT [' + RTRIM(constr.name) + '] '
          WHEN 1 THEN 'WITH NOCHECK ADD CONSTRAINT [' + RTRIM(constr.name) + '] '
        END +
        'FOREIGN KEY ([' + RTRIM(colp.name) + '])' + ' ' +
        'REFERENCES [' + RTRIM(schemar.name) + '].[' + RTRIM(objr.name) + ']([' + RTRIM(colr.name) + ']);') AS sqltext
    FROM
      sys.foreign_key_columns AS fkc
    JOIN
      sys.foreign_keys AS fk ON fkc.constraint_object_id=fk.object_id
    JOIN
      sys.objects AS objp ON objp.object_id=fkc.parent_object_id
    JOIN
      sys.schemas AS schemap ON objp.schema_id=schemap.schema_id
    JOIN
      sys.objects AS objr ON objr.object_id=fkc.referenced_object_id
    JOIN
      sys.schemas AS schemar ON objr.schema_id=schemar.schema_id
    JOIN
      sys.columns AS colr ON colr.column_id=fkc.referenced_column_id and colr.object_id=fkc.referenced_object_id
    JOIN
      sys.columns AS colp ON colp.column_id=fkc.parent_column_id and colp.object_id=fkc.parent_object_id
    JOIN
      sys.objects AS constr ON constr.object_id=fkc.constraint_object_id
    WHERE
      ((schemar.name=@schemaname) AND (objr.name=@tablename) AND (colr.name=@columnname) AND (objr.type='U')) OR
      ((schemap.name=@schemaname) AND (objp.name=@tablename) AND (colp.name=@columnname) AND (objr.type='U'));

    -- Default constraints section
    -- Drop default constraints
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      S.name AS schemaname
      ,O.name AS tablename
      ,'DF' AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(S.name) + '].[' + RTRIM(O.name) + '] ' +
        'DROP [' + RTRIM(DC.name) + '];') AS sqltext
    FROM
      sys.default_constraints AS DC
    JOIN
      sys.objects AS O ON DC.parent_object_id=O.object_id
    JOIN
      sys.schemas AS S ON O.schema_id=S.schema_id
    JOIN
      sys.columns AS Col ON Col.default_object_id=DC.object_id
    WHERE
      (S.name=@schemaname)
      AND (O.name=@tablename)
      AND (Col.name=@columnname)
      AND (DC.type='D')
      AND (O.type='U');

    -- Create default constraints
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      S.name AS schemaname
      ,O.name AS tablename
      ,'DF' AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(S.name) + '].[' + RTRIM(O.name) + '] ' +
        'ADD CONSTRAINT [' + RTRIM(DC.name) + '] ' +
        'DEFAULT ' + DC.definition + ' ' +
        'FOR [' + Col.name + '];') AS sqltext
    FROM
      sys.default_constraints AS DC
    JOIN
      sys.objects AS O ON DC.parent_object_id=O.object_id
    JOIN
      sys.schemas AS S ON O.schema_id=S.schema_id
    JOIN
      sys.columns AS Col ON Col.default_object_id=DC.object_id
    WHERE
      (S.name=@schemaname)
      AND (O.name=@tablename)
      AND (Col.name=@columnname)
      AND (DC.type='D')
      AND (O.type='U');

    -- Unique constraints and Primary keys section
    -- Drop unique constraints and primary keys
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      KCU.TABLE_SCHEMA AS schemaname
      ,KCU.TABLE_NAME AS tablename
      -- ToDo: Keep fixed objecttype code 
      ,KC.type AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(KCU.TABLE_SCHEMA) + '].[' + RTRIM(KCU.TABLE_NAME) + '] ' +
        'DROP CONSTRAINT [' + RTRIM(KCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
    JOIN
      sys.key_constraints AS KC ON KCU.CONSTRAINT_NAME=KC.name
    WHERE
      (KCU.TABLE_SCHEMA=@schemaname)
      AND (KCU.TABLE_NAME=@tablename)
      AND (KCU.COLUMN_NAME=@columnname)
      AND ((KC.type='UQ') OR (KC.type='PK'));

    -- Create unique constraints and primary keys
    WITH UQC_PK AS
    (
      SELECT
        DISTINCT
        'A' AS rowtype
        -- ToDo: Keep fixed objecttype code
        ,K.type AS objecttype
        ,KCU.TABLE_CATALOG
        ,KCU.TABLE_SCHEMA
        ,KCU.TABLE_NAME
        ,KCU.CONSTRAINT_NAME
        ,CAST(0 AS INTEGER) AS ordinal_position
        ,CAST('' AS VARCHAR(MAX)) AS COLUMN_NAME
        ,CAST('ALTER TABLE [' + RTRIM(KCU.TABLE_SCHEMA) + '].[' + RTRIM(KCU.TABLE_NAME) + '] ' +
              (CASE (K.type)
                 WHEN 'PK' THEN 'WITH NOCHECK '
                 ELSE ''
               END)  +
              'ADD CONSTRAINT [' + RTRIM(KCU.CONSTRAINT_NAME) + '] ' +
              (CASE (K.type)
                 WHEN 'UQ' THEN 'UNIQUE'
                 WHEN 'PK' THEN 'PRIMARY KEY'
               END)  + '('AS VARCHAR(MAX)) AS sqltext
      FROM
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
      JOIN
        sys.key_constraints AS K ON KCU.CONSTRAINT_NAME=K.name
      WHERE
        (KCU.TABLE_SCHEMA=@schemaname) 
        AND (KCU.TABLE_NAME=@tablename) 
        AND (KCU.COLUMN_NAME=@columnname) 
        AND ((K.type='UQ') OR (K.type='PK')) 

      UNION ALL

      SELECT
        'R' AS rowtype
        ,U.objecttype
        ,U.TABLE_CATALOG
        ,U.TABLE_SCHEMA
        ,U.TABLE_NAME
        ,U.CONSTRAINT_NAME
        ,KCU2.ORDINAL_POSITION
        ,U.COLUMN_NAME
        ,CAST(U.sqltext +
              CASE (KCU2.ordinal_position)
                WHEN 1 THEN ''
                ELSE ','
              END + ' [' + RTRIM(KCU2.COLUMN_NAME) + '] ' AS VARCHAR(MAX)) AS sqltext
      FROM
        UQC_PK AS U
      JOIN
        INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU2 ON (U.TABLE_CATALOG=KCU2.TABLE_CATALOG)
                                                   AND (U.TABLE_SCHEMA=KCU2.TABLE_SCHEMA)
                                                   AND (U.TABLE_NAME=KCU2.TABLE_NAME)
                                                   AND (U.CONSTRAINT_NAME=KCU2.CONSTRAINT_NAME)
      WHERE (KCU2.ordinal_position=U.ordinal_position + 1)
    ),
    UQC_PK2 AS
    (
      SELECT
        MAX(UQC_PK.ordinal_position) AS maxordinalposition
        ,UQC_PK.objecttype
        ,UQC_PK.TABLE_SCHEMA
        ,UQC_PK.TABLE_NAME
        ,UQC_PK.CONSTRAINT_NAME
      FROM
        UQC_PK
      WHERE
        (UQC_PK.rowtype='R')
      GROUP BY
        UQC_PK.objecttype
        ,UQC_PK.TABLE_SCHEMA
        ,UQC_PK.TABLE_NAME
        ,UQC_PK.CONSTRAINT_NAME
    )
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      UQC_PK.TABLE_SCHEMA
      ,UQC_PK.TABLE_NAME
      ,UQC_PK.objecttype
      ,'C'
      ,UQC_PK.sqltext + ') '
    FROM
      UQC_PK2
    JOIN
      UQC_PK ON (UQC_PK.CONSTRAINT_NAME=UQC_PK2.CONSTRAINT_NAME)
            AND (UQC_PK.TABLE_SCHEMA=UQC_PK2.TABLE_SCHEMA)
            AND (UQC_PK.TABLE_NAME=UQC_PK2.TABLE_NAME)
            AND (UQC_PK.ordinal_position=UQC_PK2.maxordinalposition);

    -- Check constraints section
    -- Drop check constraints
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      -- ToDo: Keep fixed objecttype code
      ,CHK.type AS objecttype
      ,'D' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        'DROP CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C');

    -- Create (enabled) check constraints
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      ,CHK.type AS objecttype
      ,'C' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        CASE (CHK.is_not_trusted)
          WHEN 0 THEN 'WITH CHECK ADD CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '] CHECK ' + RTRIM(CHK.Definition) + ';'
          WHEN 1 THEN 'WITH NOCHECK ADD CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '] CHECK ' + RTRIM(CHK.Definition) + ';'END ) AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C');

    -- Create (disabled) check constraints
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      CCU.TABLE_SCHEMA AS schemaname
      ,CCU.TABLE_NAME AS tablename
      ,CHK.type AS objecttype
      ,'I' AS operationtype
      ,('ALTER TABLE [' + RTRIM(CCU.TABLE_SCHEMA) + '].[' + RTRIM(CCU.TABLE_NAME) + '] ' +
        'NOCHECK CONSTRAINT [' + RTRIM(CCU.CONSTRAINT_NAME) + '];') AS sqltext
    FROM
      INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    JOIN
      sys.check_constraints AS CHK ON CCU.CONSTRAINT_NAME=CHK.name
    WHERE
      (CCU.TABLE_SCHEMA=@schemaname)
      AND (CCU.TABLE_NAME=@tablename)
      AND (CCU.COLUMN_NAME=@columnname)
      AND (CHK.type='C')
      AND (CHK.is_disabled=1);

    -- Statistics section
    -- Drop statistics
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      sch.name AS schemaname
      ,obj.name AS tablename
      ,'STATS' AS objecttype
      ,'D' AS operationtype
      ,'DROP STATISTICS [' + RTRIM(sch.name) + '].[' + RTRIM(obj.name) + '].[' + RTRIM(stat.name) + ']' AS SQLStr 
    FROM 
      sys.stats_columns AS statc 
    JOIN 
      sys.stats AS stat ON ((stat.stats_id=statc.stats_id) AND (stat.object_id=statc.object_id)) 
    JOIN 
      sys.objects AS obj ON statc.object_id=obj.object_id 
    JOIN 
      sys.columns AS col ON ((col.column_id=statc.column_id) AND (col.object_id=statc.object_id)) 
    JOIN 
      sys.schemas AS sch ON obj.schema_id=sch.schema_id 
    WHERE 
      (sch.name=@schemaname)
      AND (obj.name=@tablename)
      AND (col.name=@columnname)
      AND ((stat.auto_created=1) OR (stat.user_created=1))
      AND (obj.type='U');

    -- Create statistics
    WITH Stat AS 
    ( 
      SELECT 
        'A' AS RowType 
        ,T.object_id 
        ,T.stats_id 
        ,T.StatLevel 
        ,T.KeyOrdinal 
        ,T.SchemaName 
        ,T.TableName 
        ,CAST('CREATE ' +
              'STATISTICS [' + RTRIM(T.StatsName) + 
              '] ON [' + RTRIM(T.SchemaName) + 
              '].[' + RTRIM(T.TableName) +
              '] ( ' AS VARCHAR(MAX)) AS SQLStr 
      FROM 
      ( 
        SELECT 
          DISTINCT 
          stat.object_id 
          ,stat.stats_id 
          ,CAST(0 AS INTEGER) AS StatLevel 
          ,CAST(0 AS INTEGER) AS KeyOrdinal 
          ,stat.name AS StatsName 
          ,sch.name AS SchemaName 
          ,obj.name AS TableName 
        FROM 
          sys.stats_columns AS statc 
        JOIN 
          sys.stats AS stat ON ((stat.stats_id=statc.stats_id) 
                            AND (stat.object_id=statc.object_id)) 
        JOIN 
          sys.objects AS obj ON statc.object_id=obj.object_id 
        JOIN 
          sys.columns AS col ON ((col.column_id=statc.column_id) 
                             AND (col.object_id=statc.object_id)) 
        JOIN 
          sys.schemas AS sch ON obj.schema_id=sch.schema_id 
        WHERE 
          (sch.name=@schemaname)
          AND (obj.name=@tablename)
          AND (col.name=@columnname)
          AND (obj.type='U')
          AND ((stat.auto_created=1) OR (stat.user_created=1))
      ) AS T 

      UNION ALL 

      SELECT 
        'R' AS RowType 
        ,statcol.object_id 
        ,statcol.stats_id 
        ,CAST(S.StatLevel + 1 AS INTEGER) AS IdxLevel 
        ,CAST(statcol.stats_column_id AS INTEGER) KeyOrdinal 
        ,S.SchemaName 
        ,S.TableName 
        ,CAST(S.SQLStr + CASE (statcol.stats_column_id) WHEN 1 THEN '' ELSE ',' END + 
              ' [' + RTRIM(col.name) + 
              '] ' AS VARCHAR(MAX)) AS SQLStr 
      FROM 
        Stat AS S 
      JOIN 
        sys.stats_columns AS statcol ON ((statcol.object_id=S.object_id) 
                                     AND (statcol.stats_id=S.stats_id)) 
      JOIN 
        sys.columns AS col ON ((col.column_id=statcol.column_id) 
                           AND (col.object_id=statcol.object_id)) 
      WHERE 
        (statcol.stats_column_id=(S.KeyOrdinal + 1)) 
    ), 
    Stat2 AS 
    ( 
      SELECT 
        MAX(Stat.KeyOrdinal) AS MaxKeyOrdinal 
        ,Stat.object_id 
        ,Stat.stats_id 
      FROM 
        Stat 
      JOIN 
        sys.objects AS O ON O.object_id=Stat.object_id 
      WHERE 
        (Stat.RowType='R') 
      GROUP BY 
        Stat.object_id 
        ,Stat.stats_id 
    )
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      Stat.schemaname
      ,Stat.tablename
      ,'STATS' AS objecttype
      ,'C' AS operationtype
      ,Stat.SQLStr + ')'
    FROM 
      Stat2 
    JOIN 
      Stat ON ((Stat.object_id=Stat2.object_id) 
           AND (Stat.stats_id=Stat2.stats_id)) 
           AND (Stat.KeyOrdinal=Stat2.MaxKeyOrdinal);

    -- Indexes section
    -- Drop indexes
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      DISTINCT
      sch.name
      ,obj.name
      ,'IDX' AS objecttype
      ,'D' AS operationtype
      ,('DROP INDEX [' + RTRIM(sch.name) + '].[' + RTRIM(obj.name) + '].[' + RTRIM(idx.name) + '];') AS sqltext
    FROM
      sys.index_columns AS idxc
    JOIN
      sys.indexes AS idx ON ((idx.index_id=idxc.index_id)
                         AND (idx.object_id=idxc.object_id))
    JOIN
      sys.objects AS obj ON idxc.object_id=obj.object_id
    JOIN
      sys.columns AS col ON ((col.column_id=idxc.column_id)
                         AND (col.object_id=idxc.object_id))
    JOIN
      sys.schemas AS sch ON obj.schema_id=sch.schema_id
    WHERE
      (sch.name=@schemaname)
      AND (obj.name=@tablename)
      AND (col.name=@columnname)
      AND (idx.is_unique_constraint=0)
      AND (idx.is_primary_key=0)
      AND (obj.type='U')
    ORDER BY
      sqltext;

    -- Create indexes
    WITH Create_Indexes AS
    (
      SELECT
        'A' AS rowtype
        ,T.object_id
        ,T.index_id
        ,T.IdxLevel
        ,T.KeyOrdinal
        ,T.IsUnique
        ,T.IsClustered
        ,T.SchemaName
        ,T.TableName
        ,CAST('CREATE ' + T.IsUnique + T.IsClustered +
              'INDEX [' + RTRIM(T.IndexName) + '] ON [' + RTRIM(T.SchemaName) + '].[' +
              RTRIM(T.TableName) + '] ( 'AS VARCHAR(MAX)) AS sqltext
      FROM
        (SELECT
           DISTINCT
           idx.object_id
           ,idx.index_id
           ,CAST(0 AS INTEGER) AS IdxLevel
           ,CAST(0 AS INTEGER) AS KeyOrdinal
           ,CAST(CASE (idx.is_unique)
                   WHEN 1 THEN 'UNIQUE '
                   WHEN 0 THEN ''
                   ELSE ''
                 END AS VARCHAR(MAX)) AS IsUnique
           ,CAST(CASE (idx.type)
                   WHEN 1 THEN 'CLUSTERED '
                   WHEN 2 THEN 'NONCLUSTERED '
                   ELSE ''
                 END AS VARCHAR(MAX)) AS IsClustered
           ,idx.name AS IndexName
           ,sch.name AS SchemaName
           ,obj.name AS TableName
         FROM
           sys.index_columns AS idxc
         JOIN
           sys.indexes AS idx ON ((idx.index_id=idxc.index_id) AND (idx.object_id=idxc.object_id))
         JOIN
           sys.objects AS obj ON idxc.object_id=obj.object_id
         JOIN
           sys.columns AS col ON ((col.column_id=idxc.column_id) AND (col.object_id=idxc.object_id))
         JOIN
           sys.schemas AS sch ON obj.schema_id=sch.schema_id
         WHERE
           (sch.name=@schemaname)
           AND (obj.name=@tablename)
           AND (col.name=@columnname)
           AND (idx.is_unique_constraint=0)
           AND (idx.is_primary_key=0)
           AND (obj.type='U')
           AND NOT EXISTS (SELECT
                             [object_id]
                           FROM
                             sys.index_columns AS ic
                           WHERE (ic.is_included_column=1)
                             AND (idxc.[object_id]=ic.[object_id])
                             AND (idxc.index_id=ic.index_id)
                          )
        ) AS T
             
      UNION ALL 
      
      SELECT
        'R' AS RowType
        ,idxcol.object_id
        ,idxcol.index_id
        ,CAST(I.IdxLevel + 1 AS INTEGER) AS IdxLevel
        ,CAST(idxcol.key_ordinal AS INTEGER) AS KeyOrdinal
        ,CAST('' AS VARCHAR(MAX)) AS IsUnique
        ,CAST('' AS VARCHAR(MAX)) AS IsClustered
        ,I.SchemaName
        ,I.TableName
        ,CAST(I.sqltext + CASE (idxcol.key_ordinal)
                            WHEN 1 THEN ''
                            ELSE ','
                          END + ' [' + RTRIM(col.name) + '] ' AS VARCHAR(MAX)) AS sqltext
      FROM
        Create_Indexes AS I
      JOIN
        sys.index_columns AS idxcol ON ((idxcol.object_id=I.object_id) AND (idxcol.index_id=I.index_id))
      JOIN
        sys.columns AS col ON ((col.column_id=idxcol.column_id) AND (col.object_id=idxcol.object_id))
      WHERE
        (idxcol.key_ordinal=I.KeyOrdinal + 1)
    ),
    Create_Indexes2 AS
    (
      SELECT
        MAX(Create_Indexes.KeyOrdinal) AS MaxKeyOrdinal
        ,Create_Indexes.object_id
        ,Create_Indexes.index_id
      FROM
        Create_Indexes
      JOIN
        sys.objects AS O ON (O.object_id=Create_Indexes.object_id)
      WHERE
        (Create_Indexes.RowType='R')
      GROUP BY
        Create_Indexes.object_id
        ,Create_Indexes.index_id
    )
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      Create_Indexes.SchemaName
      ,Create_Indexes.TableName
      ,'IDX' AS objecttype
      ,'C' AS operationtype
      ,Create_Indexes.sqltext + ')'
    FROM
      Create_Indexes2
    JOIN
      Create_Indexes ON ((Create_Indexes.object_id=Create_Indexes2.object_id)
                     AND (Create_Indexes.index_id=Create_Indexes2.index_id)
                     AND (Create_Indexes.KeyOrdinal=Create_Indexes2.MaxKeyOrdinal));

    -- Views section
    -- Refresh views
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    )
    SELECT
      V.TABLE_SCHEMA
      ,V.TABLE_NAME
      ,'VW' AS objecttype
      ,'R' AS OperationType
      ,('EXECUTE sp_refreshview ''[' + RTRIM(V.TABLE_SCHEMA) + '].[' + RTRIM(V.TABLE_NAME) + ']'';') AS sqltext
    FROM
      INFORMATION_SCHEMA.VIEWS AS V
    WHERE
      (V.IS_UPDATABLE='NO');

    DECLARE
      @sqldrop NVARCHAR(MAX) = ''

      ,@sqlcreate NVARCHAR(MAX) = ''

      ,@sqlaltertable NVARCHAR(MAX) = ''
      ,@sqlrenametable NVARCHAR(MAX) = ''

      ,@crlf NVARCHAR(2) = CHAR(13)+CHAR(10)
      ,@trancount INTEGER = @@TRANCOUNT
      ,@olddatatype SYSNAME
      --,@tmpNewDataType SYSNAME;

    --------------------------------------------------------
    -- DROP statements for the following objects
    --
    -- Foreign key (FK)
    -- Primary key (PK)
    -- Unique constraints (UQ)
    -- Check constraints (CK)
    -- Default constraints (DF)
    -- Indexes (not related to unique constraints, IDX)
    -- Statistics
    --------------------------------------------------------

    IF (@executionmode = 1)
    BEGIN
      IF (@trancount = 0)
        -- Opening an explicit transaction to avoid auto commits
        BEGIN TRANSACTION
    END

    DECLARE C_SQL_DROP CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='FK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='PK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='UQ')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='CK')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='DF')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='IDX')
        AND (operationtype='D')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='STATS')
        AND (operationtype='D');
    
    OPEN C_SQL_DROP;

    -- First fetch
    FETCH NEXT FROM C_SQL_DROP INTO @sqldrop

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      IF (@executionmode = 0)
        PRINT(@sqldrop);
      ELSE IF (@executionmode = 1)
        EXEC(@sqldrop);
      FETCH NEXT FROM C_SQL_DROP INTO @sqldrop
    END;
    
    CLOSE C_SQL_DROP;
    DEALLOCATE C_SQL_DROP;

    SET @sqlaltertable = 'ALTER TABLE [' + @schemaname + '].[' + @tablename + 
                         '] ALTER COLUMN [' + @columnname + 
                         '] ' + @datatype + ';' + @CRLF;

    -- ALTER TABLE
    INSERT INTO #tmp_uRenameColumn
    (
      schemaname
      ,tablename
      ,objecttype
      ,operationtype
      ,sqltext
    ) VALUES
    (
      @schemaname
      ,@tablename
      ,'COL'
      ,'A'
      ,@sqlaltertable
    );
	  
    IF (@executionmode = 0)
      PRINT(@sqlaltertable);
    ELSE IF (@executionmode = 1)
      EXEC(@sqlaltertable);

    IF (@columnname <> @columnrename) AND
       (LTRIM(RTRIM(@columnrename)) <> '')
    BEGIN
      SET @sqlrenametable = 'EXEC sp_rename ''[' + @schemaname + '].[' + @tablename +'].[' + @columnname + ']'', ''[' +
                                                   @schemaname + '].[' + @tablename +'].[' + @columnrename + ']''' + @CRLF;	  

      -- Rename
      INSERT INTO #tmp_uRenameColumn
      (
        schemaname
        ,tablename
        ,objecttype
        ,operationtype
        ,sqltext
      ) VALUES
      (
        @schemaname
        ,@tablename
        ,'COL'
        ,'R'
        ,@sqlrenametable
      );

      IF (@executionmode = 0)
        PRINT(@sqlrenametable);
      ELSE IF (@executionmode = 1)
        EXEC(@sqlrenametable);
    END;

    --------------------------------------------------------
    -- CREATE statements for the following objects
    --
    -- Foreign key (FK)
    -- Primary key (PK)
    -- Unique constraints (UQ)
    -- Check constraints (CK)
    -- Default constraints (DF)
    -- Indexes (not related to unique constraints, IDX)
    -- Statistics
    --------------------------------------------------------
    DECLARE C_SQL_CREATE CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='FK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='PK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='UQ')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='CK')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='DF')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='IDX')
        AND (operationtype='C')
      UNION ALL
      SELECT
        sqltext
      FROM
        #tmp_uRenameColumn
      WHERE
        (objecttype='STATS')
        AND (operationtype='C');
    
    OPEN C_SQL_CREATE;

    -- First fetch
    FETCH NEXT FROM C_SQL_CREATE INTO @sqlcreate

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      IF (@executionmode = 0)
        PRINT(@sqlcreate);
      ELSE IF (@executionmode = 1)
        EXEC(@sqlcreate);

      FETCH NEXT FROM C_SQL_CREATE INTO @sqlcreate;
    END;
    
    CLOSE C_SQL_CREATE;
    DEALLOCATE C_SQL_CREATE;

    IF (@executionmode = 0)
      SELECT * FROM #tmp_uRenameColumn;

    IF (@executionmode = 1) AND
       (@trancount = 0) AND
       (@@ERROR = 0)
      COMMIT TRANSACTION;

    SET NOCOUNT OFF;
  END TRY
  BEGIN CATCH
    IF (@executionmode = 1) AND
       (@trancount = 0)
      ROLLBACK TRANSACTION;

    -- Error handling
    DECLARE
      @ErrorMessage NVARCHAR(MAX)
      ,@ErrorSeverity INTEGER
      ,@ErrorState INTEGER;

    SELECT 
      @ErrorMessage = ERROR_MESSAGE()
      ,@ErrorSeverity = ERROR_SEVERITY()
      ,@ErrorState = ERROR_STATE();

    SET NOCOUNT OFF;

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO
/****** Object:  StoredProcedure [tool].[RunBcpExport]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [tool].[RunBcpExport]
AS
declare @sql varchar(8000)
select @sql = 'bcp tempdb..vw_bcpMasterSysobjects out 
                 c:\bcp\sysobjects.txt -c -t, -T -S' + @@servername
exec xp_cmdshell @sql
GO
/****** Object:  StoredProcedure [tool].[TransferEntitiesToSchema]    Script Date: 2021-01-11 01:55:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC tool.TransferEntitiesToSchema @SourceSchemaName = 'BP', @TargetSchemaName = 'temptr'
CREATE   PROCEDURE [tool].[TransferEntitiesToSchema]
	@SourceSchemaName SYSNAME
,	@TargetSchemaName SYSNAME
AS

BEGIN

	DECLARE 
		@sql_execute BIT = 1
	,	@sql_debug BIT = 1
	,	@sql_log BIT = 1
	,   @sql_rc INT = 0
	,	@sql_statement NVARCHAR(MAX)
	,	@sql_message NVARCHAR(MAX)
	,	@sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec CURSOR
	,	@entity_name SYSNAME
	,	@schema_name SYSNAME


    DECLARE @log TABLE (
		LogID			INT IDENTITY(1,1)
	,	StepAction		NVARCHAR(100)
	,	StepName		NVARCHAR(100)
	,	StepDefinition	NVARCHAR(MAX)
	,	StepResult		BIT
	,	StepMessage		NVARCHAR(MAX)
	)

	SET @cursor_exec = CURSOR FOR 
	SELECT 
		s.name
	,	o.name
	FROM 
		sys.objects AS o
	INNER JOIN 
		sys.schemas	AS s
		ON s.schema_id = o.schema_id 
	WHERE 
		s.name = @SourceSchemaName
	AND
		o.is_ms_shipped = 0
	AND
		o.type IN ('U', 'V')

	OPEN @cursor_exec
	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @entity_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		-- Insert the table into the Entity Lineage table 
		SET @sql_statement =  'ALTER SCHEMA' + QUOTENAME(@TargetSchemaName)  + @sql_crlf
		SET @sql_statement += 'TRANSFER ' + QUOTENAME(@SourceSchemaName) + '.' + QUOTENAME(@entity_name)  + @sql_crlf + @sql_crlf

			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = @sql_statement
				RAISERROR(@sql_message, 0, 1) WITH NOWAIT
			END

			IF (@sql_execute = 1)
			BEGIN
				BEGIN TRY
					EXEC @sql_rc = sp_executesql 
									@stmt = @sql_statement
					
					-- Write the successful transfer of an object to the log file
					IF (@sql_log = 1)
					BEGIN
						INSERT INTO @log (StepAction, StepName, StepDefinition, StepResult, StepMessage)
						SELECT 'TRANSFER', QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name) , @sql_statement, @sql_rc, NULL
					END

				END TRY
				BEGIN CATCH
					-- Write the error in transfer of an object to the log file
					IF (@sql_log = 1)
					BEGIN
						INSERT INTO @log (StepAction, StepName, StepDefinition, StepResult, StepMessage)
						SELECT 'TRANSFER', QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name) , @sql_statement, @sql_rc, ERROR_MESSAGE()
					END
				END CATCH
		END
		

	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @entity_name


	END

	SELECT * FROM @log

END
GO
