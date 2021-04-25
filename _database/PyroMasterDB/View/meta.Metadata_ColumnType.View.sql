SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_ColumnType]'))
EXEC dbo.sp_executesql @statement = N'

-- SELECT * FROM [meta].[Metadata_ColumnType]

CREATE     VIEW [meta].[Metadata_ColumnType]
AS
SELECT 
	DatabaseName				= ''PyroMasterDB''
,	SystemColumnTypeId			= typ.system_type_id
,	UserColumnTypeId			= typ.user_type_id
,	ColumnTypeName				= typ.name
,	SchemaId					= typ.schema_id
,	SchemaName					= sch.name
,   TypeLengthMaximum			= typ.max_length
,   TypePrecision				= typ.precision
,   TypeScale					= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable					= typ.is_nullable
,   IsUserType					= typ.is_user_defined
,	IsAssemblyType				= typ.is_assembly_type
,	IsSchemaBound				= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroMasterDB].sys.types AS typ
INNER JOIN
	[PyroMasterDB].sys.schemas sch
	ON typ.schema_id = sch.schema_id
  
UNION ALL 

SELECT 
	DatabaseName		= ''PyroLandingZoneDB''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	ColumnTypeName		= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroLandingZoneDB].sys.types AS typ
INNER JOIN
	[PyroLandingZoneDB].sys.schemas sch
	ON typ.schema_id = sch.schema_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroSourceDB''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	ColumnTypeName		= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroLandingZoneDB].sys.types AS typ
INNER JOIN
	[PyroLandingZoneDB].sys.schemas sch
	ON typ.schema_id = sch.schema_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroModelDB''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	TypeName			= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroModelDB].sys.types AS typ
INNER JOIN
	[PyroModelDB].sys.schemas sch
	ON typ.schema_id = sch.schema_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroCustomerDB''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	ColumnTypeName		= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroCustomerDB].sys.types AS typ
INNER JOIN
	[PyroCustomerDB].sys.schemas sch
	ON typ.schema_id = sch.schema_id

UNION ALL

SELECT 
	DatabaseName		= ''AdventureWorks''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	ColumnTypeName		= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[AdventureWorks].sys.types AS typ
INNER JOIN
	[AdventureWorks].sys.schemas sch
	ON typ.schema_id = sch.schema_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroV1''
,	SystemColumnTypeId	= typ.system_type_id
,	UserColumnTypeId	= typ.user_type_id
,	ColumnTypeName		= typ.name
,	SchemaId			= typ.schema_id
,	SchemaName			= sch.name
,   TypeLengthMaximum	= typ.max_length
,   TypePrecision		= typ.precision
,   TypeScale			= typ.scale
,	TypeStandardTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(''|>PRECISION<|'' AS NVARCHAR(20)) + '','' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(''|>SCALE<|'' AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(''|>MAXLEN<|'' AS NVARCHAR(20))   
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,	TypeDefaultTemplate		= RTRIM(CONCAT(typ.name, '' '', 
								-- Numeric DataTypes
										CASE WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''decimal'', ''numeric'', ''money'', ''smallmoney'', ''float'', ''real'')
												THEN CASE WHEN typ.name IN (''decimal'', ''numeric'')
																	THEN ''('' + CAST(typ.precision AS NVARCHAR(20)) + '','' + CAST(typ.scale AS NVARCHAR(20)) + '')''
															WHEN typ.name IN (''float'', ''real'')  
																	THEN ''''
																	--THEN ''('' + CAST(f.[Precision] AS VARCHAR(5)) + '')''
															WHEN typ.name IN (''bigint'', ''int'', ''smallint'', ''tinyint'', ''bit'', ''money'', ''smallmoney'')
																	THEN ''''
																	ELSE ''''
														END 
						 
										-- Date/Time DataTypes
										WHEN typ.name IN (''datetime'', ''datetime2'', ''smalldatetime'', ''date'', ''time'', ''datetimeoffset'', ''timestamp'')
											THEN CASE WHEN typ.name IN (''datetime2'', ''datetimeoffset'', ''time'')
														THEN ''('' + CAST(typ.scale AS NVARCHAR(20)) + '')''
														WHEN typ.name IN (''datetime'', ''smalldatetime'', ''date'', ''time'')
														THEN ''''
														ELSE ''''
													END 		
								 
										-- char string types
										WHEN typ.name IN (''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'', ''binary'', ''text'', ''ntext'')
											THEN CASE WHEN typ.name IN (''varchar'', ''char'', ''varbinary'', ''binary'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length AS NVARCHAR(20))   
																	END + '')''  
														WHEN typ.name IN (''nvarchar'', ''nchar'')  
														THEN ''('' + CASE WHEN typ.max_length = -1   
																		THEN ''MAX''   
																		ELSE CAST(typ.max_length / 2 AS NVARCHAR(20))    
																	END + '')''
														WHEN typ.name IN (''binary'', ''text'', ''ntext'')  
														THEN ''''
														ELSE ''''
													END

										-- spatial
										WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
											THEN CASE WHEN typ.name IN (''geography'', ''geometry'', ''hierarchyid'')
														THEN ''''
														ELSE ''''
													END 

					
										-- other types
										WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
											THEN CASE WHEN typ.name IN (''sql_variant'',  ''uniqueidentifier'', ''xml'', ''image'', ''sysname'')
														THEN ''''
														ELSE ''''
												END 
									END
								))
,   IsNullable			= typ.is_nullable
,   IsUserType			= typ.is_user_defined
,	IsAssemblyType		= typ.is_assembly_type
,	IsSchemaBound		= IIF(typ.schema_id = 4, 0, 1)
FROM 
	[PyroV1].sys.types AS typ
INNER JOIN
	[PyroV1].sys.schemas sch
	ON typ.schema_id = sch.schema_id













' 
GO
