CREATE PROCEDURE ##Set_ExtendedProperty
	@name				NVARCHAR(128)	
,	@value				sql_variant
,	@level0type			NVARCHAR(128)		= NULL	
,	@level0name			SYSNAME
,	@level1type			NVARCHAR(128)		= NULL
,	@level1name			SYSNAME
,	@level2type			NVARCHAR(128)		= NULL
,	@level2name			SYSNAME				= NULL

AS
BEGIN

	DECLARE @sql_message NVARCHAR(MAX)
	SET @level0type  = N'SCHEMA'
	SET @level1type  = N'VIEW'

	-- Add description to table object
	--sp_updateextendedproperty  
	--    [ @name = ]{ 'property_name' }   
	--    [ , [ @value = ]{ 'value' }  
	--        [, [ @level0type = ]{ 'level0_object_type' }  
	--         , [ @level0name = ]{ 'level0_object_name' }  
	--              [, [ @level1type = ]{ 'level1_object_type' }  
	--               , [ @level1name = ]{ 'level1_object_name' }  
	--                     [, [ @level2type = ]{ 'level2_object_type' }  
	--                      , [ @level2name = ]{ 'level2_object_name' }  
	--                     ]  
	--              ]  
	--        ]  
	--    ]  
	--Arguments
	--[ @name= ]{ 'property_name'}
	--Is the name of the property to be updated. property_name is sysname, and cannot be NULL.

	--[ @value= ]{ 'value'}
	--Is the value associated with the property. value is sql_variant, with a default of NULL. The size of value may not be more than 7,500 bytes.

	--[ @level0type= ]{ 'level0_object_type'}
	--Is the user or user-defined type. level0_object_type is varchar(128), with a default of NULL. Valid inputs are ASSEMBLY, CONTRACT, EVENT NOTIFICATION, FILEGROUP, MESSAGE TYPE, PARTITION FUNCTION, PARTITION SCHEME, PLAN GUIDE, REMOTE SERVICE BINDING, ROUTE, SCHEMA, SERVICE, USER, TRIGGER, TYPE, and NULL.

	-- Important

	--USER and TYPE as level-0 types will be removed in a future version of SQL Server. Avoid using these features in new development work, and plan to modify applications that currently use these features. Use SCHEMA as the level 0 type instead of USER. For TYPE, use SCHEMA as the level 0 type and TYPE as the level 1 type.

	--[ @level0name= ]{ 'level0_object_name'}
	--Is the name of the level 1 object type specified. level0_object_name is sysname with a default of NULL.

	--[ @level1type= ]{ 'level1_object_type'}
	--Is the type of level 1 object. level1_object_type is varchar(128) with a default of NULL. Valid inputs are AGGREGATE, DEFAULT, FUNCTION, LOGICAL FILE NAME, PROCEDURE, QUEUE, RULE, SYNONYM, TABLE, TABLE_TYPE, TYPE, VIEW, XML SCHEMA COLLECTION, and NULL.

	--[ @level1name= ]{ 'level1_object_name'}
	--Is the name of the level 1 object type specified. level1_object_name is sysname with a default of NULL.

	--[ @level2type= ]{ 'level2_object_type'}
	--Is the type of level 2 object. level2_object_type is varchar(128) with a default of NULL. Valid inputs are COLUMN, CONSTRAINT, EVENT NOTIFICATION, INDEX, PARAMETER, TRIGGER, and NULL.

	--[ @level2name= ]{ 'level2_object_name'}
	--Is the name of the level 2 object type specified. level2_object_name is sysname, with a default of NULL.

	-- Can also use sp_updateextendedproperty or sp_dropextendedproperty
	-- Checks if schema exists 
	IF NOT EXISTS (SELECT 1 FROM sys.schemas AS sch WHERE sch.name = @level0name)
	BEGIN
		
		SET @sql_message = N'The schema name ' + QUOTENAME(@level0name) + ' (schema) does not exists!'
		RAISERROR(@sql_message, 500001 ,1) WITH NOWAIT

	END

	-- Check if object does exist 
	-- TODO now we assuming its a VIEW but need to use the @level1type to figure that out
	IF NOT EXISTS (SELECT 1 FROM sys.objects AS obj WHERE obj.name = @level1name)
	BEGIN

		SET @sql_message = N'The schema name ' + QUOTENAME(@level1name) + ' (view) does not exists!'
		RAISERROR(@sql_message, 500001 ,1) WITH NOWAIT

	END

	-- Will not insert blank names
	IF(ISNULL(@name, '') != '')
	BEGIN

		-- Now check if teh extended property does exist
		-- Here we will handle it differently though
		--		EXISTS: Do update
		--		NOT EXITS: Do Insert
		--	Only for minor_id = 0 (thus tables/views/procs/functions)
		IF NOT EXISTS (
						SELECT 1 FROM 
							sys.extended_properties AS ept 
							INNER JOIN sys.objects AS obj ON obj.object_id = ept.major_id 
							INNER JOIN sys.schemas AS sch ON sch.schema_id = obj.schema_id
							WHERE 
								minor_id = 0
							AND 
								sch.name = @level0name
							AND 
								obj .name= @level1name
							AND
								ept.name = @name
		)
		-- INSERT PORTION
		BEGIN

			EXEC sys.sp_addextendedproperty 
				@name		= @name,				@value		= @value ,
				@level0type = @level0type,			@level0name	= @level0name, 
				@level1type = @level1type,			@level1name	= @level1name

		END
		ELSE
		-- UPDATE PORTION
		BEGIN
				EXEC sys.sp_updateextendedproperty 
				@name		= @name,				@value		= @value ,
				@level0type = @level0type,			@level0name	= @level0name, 
				@level1type = @level1type,			@level1name	= @level1name

		END
	END
	ELSE
	-- Blank @name sent
	BEGIN
		SET @sql_message = N'Please spesify a name value for the extended property'
		RAISERROR(@sql_message, 500001 ,1) WITH NOWAIT
	END
END
GO

-- INSERT Neded Metadata into table   
DECLARE @RC INT
DECLARE @sql_statement NVARCHAR(MAX)
DECLARE @name_schema NVARCHAR(MAX)
DECLARE @name_view NVARCHAR(MAX)
DECLARE @fake int
DECLARE @sql_parameter NVARCHAR(MAX)

DROP TABLE IF EXISTS 
	##InfoMart_Register
SELECT --TOP 15
	v.name AS name_view
,	s.name AS name_schema
INTO 
	##InfoMart_Register
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

WHILE (@@FETCH_STATUS = 0)
BEGIN
		EXEC ##Set_ExtendedProperty
			@name				= 'Description'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Created Date'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Created By'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Updated Date'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Updated By'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL


	EXEC ##Set_ExtendedProperty
			@name				= 'Depends On'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Is Used For Reporting'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Is Sensitive Data'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Quality Score'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	EXEC ##Set_ExtendedProperty
			@name				= 'Complexity Score'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

			EXEC ##Set_ExtendedProperty
			@name				= 'Trustworthiness Score'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

			EXEC ##Set_ExtendedProperty
			@name				= 'Change History (Abbr.)'
		,	@value				= ''
		,	@level0type			= N'SCHEMA'
		,	@level0name			= @name_schema
		,	@level1type			= N'VIEW'
		,	@level1name			= @name_view
		,	@level2type			= NULL
		,	@level2name			= NULL

	FETCH NEXT FROM @curs_register
	INTO @name_schema, @name_view


END
--SELECT
--    definition,
--    uses_ansi_nulls,
--    uses_quoted_identifier,
--    is_schema_bound
--FROM
--    sys.sql_modules


--SET NOEXEC ON
--SET PARSEONLY OFF
--SET FMTONLY 
--SET NOCOUNT







--EXEC ##Set_ExtendedProperty
--	@name				= 'DescriptionA'
--,	@value				= ''
--,	@level0type			= N'SCHEMA'
--,	@level0name			= N'dbo'
--,	@level1type			= N'VIEW'
--,	@level1name			= N'vw_DimBusinessGlossary'
--,	@level2type			= NULL
--,	@level2name			= NULL
--GO

DROP PROCEDURE ##Set_ExtendedProperty
GO

/*
A Glossary containing business terms and definitions as well as the locatation of the icons that relate to these terms
A Glossary containing business terms and definitions as well as the locatation of the icons that relate to these terms
* Description
* 
* Created Date
* Created By
* Updated Date
* Updated By
* Is Used For Reporting
* Is Sensitive Data
* Quality Score
* Complexity Score
* Trustworthiness Score
* Change History (Abbr.)



*/