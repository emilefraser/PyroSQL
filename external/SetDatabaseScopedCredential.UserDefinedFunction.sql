/****** Object:  UserDefinedFunction [DC].[udf_generate_ddl_AZSQL_DatabaseScopedCredential]    Script Date: 6/15/2020 01:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
/*
	SELECT [DDL].[GetExternalTable]('dbo', 'ServicePrincipals')
*/
CREATE OR ALTER FUNCTION [DDL].[GetExternalTable](
	@SchemaName SYSNAME = 'dbo'
,	@TableName	SYSNAME
)
RETURNS VARCHAR(MAX) 
AS
BEGIN

--declare @SchemaName SYSNAME = 'dbo'
--,	@TableName	SYSNAME = 'ServicePrincipals'

	-- Local Variable needed
	DECLARE @returnvalue NVARCHAR(MAX) = ''

	;WITH cte_parameters (sql_crlf, sql_tab, max_columnid) AS (
		SELECT 
			sql_crlf			= CHAR(13) + CHAR(10)
		,	sql_tab				= CHAR(9)
		,	max_columnid		= MAX(col.column_id)
		FROM
			sys.columns AS col
		INNER JOIN 
			sys.tables AS tab
			ON tab.object_id = col.object_id
		INNER JOIN 
			sys.schemas AS sch
			ON sch.schema_id = tab.schema_id
		WHERE
			tab.name = @TableName
		AND
			sch.name = @SchemaName
	), cte_datatype (DataTypeID, DataTypeClass, DataTypeName, DataTypeMaxLength, DataTypePrecision, DataTypeScale, DataTypeTemplate) AS (

		-- STRING TYPES
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'string'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision					-- total decimals
		,	DataTypeScale		= typ.scale						-- total digits
		,	DataTypeTemplate    = '{{datatype}}' + CASE typ.max_length
															WHEN 8000 THEN '({{length}})'
															WHEN 256 THEN ''
															ELSE ''
													END															
		FROM 
			sys.types AS typ
		WHERE
			typ.collation_name IS NOT NULL OR typ.max_length = 8000

		UNION ALL
			
		-- DATETIME TYPES
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'datetime'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}'
		FROM 
			sys.types AS typ
		WHERE
			typ.scale = 7 -- (date and time)
		OR
			typ.max_length = 3
		OR (
			typ.max_length = 8 
			AND typ.scale = 3
		)
		OR (
			typ.max_length = 4 
			AND typ.precision = 16
		)
		OR (
			typ.max_length = 8
		AND typ.precision = 0
		)
			
	
		UNION ALL

		--- MONEY
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'money'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}'
		FROM 
			sys.types AS typ
		WHERE
			typ.scale = 4

		UNION ALL
		
		-- DECIMAL
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'decimal'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}({{precision}},{{scale}})'
		FROM 
			sys.types AS typ
		WHERE
			typ.scale = 38

		UNION ALL 

		-- APPROXIMATE DECIMAL
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'approximation'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}'
		FROM 
			sys.types AS typ
		WHERE
			typ.scale = 0
		AND
			typ.precision > 20
			
		UNION ALL

		-- NUMERICS
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'number'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}'
		FROM 
			sys.types AS typ
		WHERE
			typ.scale = 0
		AND
			typ.precision > 0
		AND
			typ.precision < 20 /* float */
		AND
			typ.precision != 16
		AND
			typ.max_length != 3
			
		UNION ALL
		
		-- SPECIAL DATATYPES
		SELECT 
			DataTypeID			= typ.user_type_id
		,	DataTypeClass		= 'special'
		,	DataTypeName		= typ.name
		,	DataTypeMaxLength	= typ.max_length
		,	DataTypePrecision	= typ.precision			-- total decimals
		,	DataTypeScale		= typ.scale				-- total digits
		,   DataTypeTemplate	= '{{datatype}}'
		FROM 
			sys.types AS typ
		WHERE
			typ.max_length = -1 
			OR typ.max_length = 8016 
			OR typ.max_length = 892
			OR (typ.max_length = 16 and typ.collation_name IS NOT NULL)
			OR (typ.max_length = 16 AND typ.precision = 0)
	)
	SELECT 
		@returnvalue = @returnvalue + QUOTENAME(col.name) + ' ' + 
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										DataTypeTemplate
									,'{{datatype}}'
									, cte_dt.DataTypeName
									)
								, '{{precision}}'
								, cte_dt.DataTypePrecision
								)
							,'{{scale}}'
							,cte_dt.DataTypeScale
							)
						,'{{length}}'
						,cte_dt.DataTypeMaxLength
					)  
					+ IIF(col.is_nullable = 1, ' NULL', ' NOT NULL')
					+ IIF(col.column_id != cte_par.max_columnid, ',' + cte_par.sql_crlf, cte_par.sql_crlf)


	FROM 
		sys.tables as tab
	inner join 
		sys.schemas AS sch
		on sch.schema_id = tab.schema_id
	inner join
		sys.columns as col
		on col.object_id = tab.object_id
	LEFT JOIN 
		cte_datatype as cte_dt
		ON cte_dt.DataTypeID = col.user_type_id
		CROSS APPLY
		cte_parameters AS cte_par
WHERE
		sch.name = @SchemaName
	AND
		tab.name = @TableName
		/*
		SELECT 
		@returnvalue

	
	SELECT 
		@returnvalue = @returnvalue + REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										DataTypeTemplate
									,'{{datatype}}'
									, cte_dt.DataTypeName
									)
								, '{{precision}}'
								, cte_dt.DataTypePrecision
								)
							,'{{scale}}'
							,cte_dt.DataTypeScale
							)
						,'{{max_length}}'
						,cte_dt.DataTypeMaxLength
					)  
					+ IIF(col.is_nullable = 1, ' NULL', 'NOT NULL')
					---+ IIF(col.column_id != cte_par.max_columnid, ',' + cte_par.sql_crlf, cte_par.sql_crlf)


	FROM 
		sys.tables as tab
	inner join 
		sys.schemas AS sch
		on sch.schema_id = tab.schema_id
	inner join
		sys.columns as col
		on col.object_id = col.object_id
	LEFT JOIN 
		cte_datatype as cte_dt
		ON cte_dt.DataTypeID = col.user_type_id
	--CROSS APPLY
	--	cte_parameters AS cte_par
	WHERE
		sch.name = @SchemaName
	AND
		tab.name = @TableName
	ORDER BY  
		sch.name , tab.name, col.column_id
		*/
	RETURN @returnvalue

END
