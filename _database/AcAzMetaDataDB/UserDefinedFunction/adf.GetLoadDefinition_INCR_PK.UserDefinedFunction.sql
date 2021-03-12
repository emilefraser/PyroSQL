SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetLoadDefinition_INCR_PK]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

/*
	Created By: Emile Fraser
	Date: 2020-11-01
	Description: Gets the Load Definition for ADF Incremental Load Using a Primary Key
	SELECT * FROM adf.LoadConfig WHERE SourceEntityName = ''EKKO''
	Test1: SELECT [adf].[GetLoadDefinition_INCR_PK](180, ''SOURCE'')
	Test2: SELECT [adf].[GetLoadDefinition_INCR_PK](5, ''TARGET'')

	TODO: Make the Waterfall field dynamic

	
*/
CREATE       FUNCTION [adf].[GetLoadDefinition_INCR_PK] (
	@LoadConfigID			INT		
,	@SourceOrTarget			NVARCHAR(6)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

		--SELECT ''''
			/*''SELECT '' +
				[adf].[GetQuotedObject] (@EntityName) + ''.'' + ''*'' +
				, BCPSGSG AS RevenueByPero
			'', GREATEST(
			  COALESCE(CONCAT(COALESCE("EKKO"."AEDAT", ''''''19000101''''''), COALESCE(NULL,''000000'')), 19000101000000)
			, COALESCE("CHANGE_VIEW"."LatestModifiedDateTime", 19000101000000)
			) AS "LatestModifiedDateTime"
			FROM 
				"SAPHANADB"."EKKO"
			LEFT JOIN 
				"SAPHANADB"."view_AzureDataFactorySource_Data_ChangeDocumentTracking_Latest" AS "CHANGE_VIEW"
				ON "EKKO"."MANDT"				= "CHANGE_VIEW"."Client"							
				AND "EKKO"."EBELN"				= "CHANGE_VIEW"."ObjectValue"
				AND "CHANGE_VIEW"."TableName"	= ''EKKO''
			WHERE 
				"LatestModifiedDateTime" >= 20200101000000
			AND
				"LatestModifiedDateTime" <= 20200921000000





			IIF(COALESCE(@StaticFieldList, '''') = '''', ''*'', @StaticFieldList) +
				'' FROM '' +
				IIF(COALESCE(@ServerName, '''') = '''', '''',
					IIF(COALESCE(@DatabaseInstanceName, '''') = '''', @ServerName + ''.'' , @ServerName + ''\'' + @DatabaseInstanceName + ''.'')
				) + 
				IIF(COALESCE(@DatabaseName, '''') = '''', '''', @DatabaseName + ''.'') +
				IIF(COALESCE(@SchemaName, '''') = '''', '''', @SchemaName + ''.'') +
				IIF(COALESCE(@EntityName, '''') = '''', '''', @EntityName)*/


	DECLARE @ReturnValue NVARCHAR(MAX)  = ''''

	;WITH cte_template (
		Template
	,	QuotedIdentifierId
	,	EntityType
	,	ServerName
	,	DatabaseInstanceName
	,	DatabaseName
	,	SchemaName
	,	EntityName
	,	EntityAlias
	,	FieldList
	,	LoadConfigID
	,	CreatedDateEntity
	,	CreatedDateColumn
	,	CreatedDateValue
	,	CreatedTimeColumn
	,	CreatedTimeValue
	,	UpdatedDateEntity
	,	UpdatedDateColumn
	,	UpdatedDateValue
	,	UpdatedTimeColumn
	,	UpdatedTimeValue
	) AS (

	--declare @SourceOrTarget varchar(20) = ''SOURCE''
		SELECT	
			Template						= lquo.QuotedIdentifier_Definition
		,	QuotedIdentifierId				= IIF(@SourceOrTarget = ''SOURCE''
														, lcon.SourceQuotedIdentifierID
														, lcon.TargetQuotedIdentifierID
											)
		,	EntityType						= IIF(@SourceOrTarget = ''SOURCE''
														, lcon.SourceEntityType
														, lcon.TargetEntityType
											)
		,	ServerName						= IIF(@SourceOrTarget = ''SOURCE''
													, NULL
													, lcon.TargetServerName
											) -- TO USE LATER (TODO1)
		,	DatabaseInstanceName			= IIF(@SourceOrTarget = ''SOURCE''
													, NULL
													, lcon.TargetDatabaseInstanceName
											) -- TO USE LATER (TODO1)
		,	DatabaseName					= IIF(@SourceOrTarget = ''SOURCE''
													, lcon.SourceDatabaseName
													, lcon.TargetDatabaseName
											)
		,	SchemaName						= IIF(@SourceOrTarget = ''SOURCE''
													, NULL
													, lcon.TargetSchemaName
											) -- TO USE LATER (TODO1)
		,	EntityName						= IIF(@SourceOrTarget = ''SOURCE''
													, lcon.SourceEntityName
													, lcon.TargetEntityName
											)
		,	EntityAlias						= IIF(@SourceOrTarget = ''SOURCE''
													, lcon.SourceEntityName
													, lcon.TargetEntityName
											)
		,	FieldList						= IIF(@SourceOrTarget = ''SOURCE''
													, IIF(COALESCE(lcon.FieldListForSelect, '''') = ''''
														, CONCAT(REPLACE(lquo.QuotedIdentifier_Definition
																			, ''@{{OBJECTNAME}}''
																			, [adf].[GetAliasForObject] (lcon.SourceEntityName, lcon.SourceEntityType)
														), ''.'', ''*'')
														, lcon.FieldListForSelect
													)
											  , ''*'')
		,	LoadConfigID					= lcon.LoadConfigID
		,	CreatedDateEntity				= IIF(@SourceOrTarget = ''SOURCE''
													, IIF(lcon.IsCdcCreatedExternal = 1															
																, lcon.ExCdcEntityName
																, lcon.SourceEntityName
														)
													, IIF(lcon.IsCdcCreatedExternal = 1
																, lcon.ExCdcEntityName
																, lcon.TargetEntityName
																
														)
											)
		,	CreatedDateColumn				= lcon.CdcCreatedDateColumn
		,	CreatedDateValue				= lcon.CdcCreatedDateValue_Last
		,	CreatedTimeColumn				= lcon.CdcCreatedTimeColumn
		,	CreatedTimeValue				= lcon.CdcCreatedTimeValue_Last
		,	UpdatedDateEntity				= IIF(@SourceOrTarget = ''SOURCE''
													, IIF(lcon.IsCdcUpdatedExternal = 1
																
																, lcon.ExCdcEntityName
																, lcon.SourceEntityName
														)
													, IIF(lcon.IsCdcUpdatedExternal = 1
																
																, lcon.ExCdcEntityName
																, lcon.TargetEntityName
														)
											)
		,	UpdatedDateColumn				= lcon.CdcUpdatedDateColumn
		,	UpdatedDateValue				= lcon.CdcUpdatedDateValue_Last
		,	UpdatedTimeColumn				= lcon.CdcUpdatedTimeColumn
		,	UpdatedTimeValue				= lcon.CdcUpdatedTimeValue_last
		FROM 
			adf.LoadConfig AS lcon
		INNER JOIN
			adf.LoadQuotedIdentifier AS lquo
			ON lquo.LoadQuotedIdentifierID = IIF(@SourceOrTarget = ''SOURCE'', lcon.SourceQuotedIdentifierID, lcon.TargetQuotedIdentifierID)
		WHERE
			lcon.LoadConfigID = @LoadConfigID
			
			

	), 
	
	cte_templatecdc (
		ExCdcTemplate
	,	ExCdcQuotedIdentifierId
	,	ExCdcEntityType
	,	ExCdcServerName
	,	ExCdcDatabaseInstanceName
	,	ExCdcDatabaseName
	,	ExCdcSchemaName
	,	ExCdcEntityName
	,	ExCdcEntityAlias
	,	ExCdcSFieldList
	,   JoinType
	,	LoadConfigID
	)  AS (
		
		SELECT	
			ExCdcTemplate					= lquo.QuotedIdentifier_Definition
		,	ExCdcQuotedIdentifierID			= lcon.ExCdcQuotedIdentifierID
		,	ExCdcEntityType					= lcon.ExCdcEntityType
		,	ExCdcServerName					= NULL -- TO USE LATER (TODO1)
		,	ExCdcDatabaseInstanceName		= NULL -- TO USE LATER (TODO1)
		,	ExCdcDatabaseName				= lcon.ExCdcDatabaseName
		,	ExCdcSchemaName					= NULL -- TO USE LATER (TODO1)
		,	ExCdcEntityName					= lcon.ExCdcEntityName
		,	ExCdcEntityAlias				= [adf].[GetAliasForObject] (lcon.ExCdcEntityName, lcon.ExCdcEntityType) 
		,	ExCdcFieldList					= ''*''
		,	JoinType						= lcon.ExCdcJoinType
		,	LoadConfigID					= lcon.LoadConfigID
		FROM 
			adf.LoadConfig AS lcon
		INNER JOIN
			adf.LoadQuotedIdentifier AS lquo
			ON lquo.LoadQuotedIdentifierID = lcon.ExCdcQuotedIdentifierId
		WHERE
			lcon.LoadConfigID = @LoadConfigID
	),

	cte_select AS (
		SELECT 
			FieldList = CONCAT_WS('' ''
									, ''SELECT'' 
									, [adf].[GetCRLF] (0) + cte_template.FieldList + '',''
									, [adf].[GetCRLF] (1) + ''GREATEST('' 
										+ [adf].[GetCRLF] (2) + ''COALESCE(''
										+ [adf].[GetCRLF] (3) + ''CONCAT(''
										+ [adf].[GetCRLF] (4) + ''COALESCE(''
										+ [adf].[GetQuotedObjectAlias](cte_template.CreatedDateEntity, cte_template.QuotedIdentifierId, cte_template.EntityType)
											+ ''.'' 
											+ [adf].[GetQuotedObjectAlias](cte_template.CreatedDateColumn, cte_template.QuotedIdentifierId, cte_template.EntityType)
										+ '', ''''19000101'''')''  
										+ [adf].[GetCRLF] (3) + '',   COALESCE('' 
										+ COALESCE([adf].[GetQuotedObjectAlias](cte_template.CreatedDateEntity, cte_template.QuotedIdentifierId, cte_template.EntityType) 
											+ ''.'' 
											+ cte_template.CreatedTimeColumn, ''NULL'') 
										+ '' ,''''000000'''')'' 
										+ [adf].[GetCRLF] (3) + '')'' 
										+ [adf].[GetCRLF] (2) +	'',   ''''19000101000000'''''' + 
										+ [adf].[GetCRLF] (2) + '')''  
										+ [adf].[GetCRLF] (1) +	'',   COALESCE('' 
											+ [adf].[GetQuotedObjectAlias](cte_template.UpdatedDateEntity, cte_templatecdc.ExCdcQuotedIdentifierId, ''VIEW'')  
											+ ''.'' 
											+ ''"LatestModifiedDateTime"''
											+ '', ''''19000101000000'''''' + 
											+ '')'' 
										+ [adf].[GetCRLF] (1) + '') AS "LatestModifiedDateTime"'' 
									, [adf].[GetCRLF] (0) + ''FROM''
			) + CHAR(13) + CHAR(10)
		FROM cte_template
		INNER JOIN cte_templatecdc
		ON cte_templatecdc.LoadConfigID = cte_template.LoadConfigID

	),
	
	cte_serverdatabaseinstance (ServerDatabaseInstanceName, LoadConfigID) AS (
		SELECT
			[adf].[GetCRLF] (1) + 
			IIF(COALESCE(cte_template.ServerName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, IIF(COALESCE(cte_template.DatabaseInstanceName, '''') = ''''
									, cte_template.ServerName
									, cte_template.ServerName + ''\'' + cte_template.DatabaseInstanceName
							)
				)
			) AS Servrname
		,	cte_template.LoadConfigID
		FROM cte_template
	), 
	
	cte_database (DatabaseName, LoadConfigID) AS (
		SELECT 
			IIF(COALESCE(cte_template.DatabaseName, '''') = ''''
				,  NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, cte_template.DatabaseName
				) 
			) AS DatabaseName,	cte_template.LoadConfigID
		FROM cte_template	
	
	), 
	
	cte_schema (SchemaName, LoadConfigID) AS (
		SELECT 
			IIF(COALESCE(cte_template.SchemaName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, cte_template.SchemaName
				)
			) AS SchemaName	,	cte_template.LoadConfigID
		FROM cte_template	
	), 
	
	cte_entity (EntityName, LoadConfigID) AS (
		SELECT 
			IIF(COALESCE(cte_template.EntityName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
					, ''@{{OBJECTNAME}}''
					, cte_template.EntityName
				)
			) AS EntityName	
		,	cte_template.LoadConfigID
		FROM cte_template	
	), 
	
	cte_excdc (LoadConfigID, InternalSideJoin, EqualityOperator, ExternalSideJoin, rn) AS (	
		SELECT 
			LoadConfigID		= lcon.LoadConfigID
		,	InternalSideJoin	= IIF(COALESCE(lcdc.[InternalColumnName], '''') = ''''
										,	'''''''' + lcdc.[InternalConstantValue] + ''''''''
										, REPLACE(cte_template.Template
													, ''@{{OBJECTNAME}}''
													, cte_template.EntityAlias
										) + ''.''
										+ REPLACE(cte_template.Template
													, ''@{{OBJECTNAME}}''
													, lcdc.[InternalColumnName]
										)
								) 
		,	EqualityOperator	= lcdc.EqualityOperator
		,	ExternalSideJoin	= IIF(COALESCE(lcdc.[ExternalColumnName], '''') = ''''
										,	'''''''' + lcdc.[ExternalConstantValue] + ''''''''
										, REPLACE(cte_templatecdc.ExCdcTemplate
													, ''@{{OBJECTNAME}}''
													, cte_templatecdc.ExCdcEntityAlias
										) + ''.''
										+ REPLACE(cte_templatecdc.ExCdcTemplate
													, ''@{{OBJECTNAME}}''
													, lcdc.[ExternalColumnName]
										)
								)
		,	ROW_NUMBER() OVER (ORDER BY lcon.LoadConfigID) AS rn
		FROM
			[adf].[LoadCdcJoin] AS lcdc
		INNER JOIN 
			[adf].[LoadConfig] AS lcon
			ON lcon.LoadConfigID = lcdc.LoadConfigID 
		INNER JOIN 
			cte_templatecdc
			ON cte_templatecdc.LoadConfigID = lcdc.LoadConfigID
		INNER JOIN 
			cte_template
			ON cte_template.LoadConfigID = lcdc.LoadConfigID
		WHERE
			lcdc.LoadConfigId = @LoadConfigID
	)
--	SELECT @ReturnValue += InternalSideJoin FROM cte_excdc
	
	
	
	, 
	
	cte_totaljoin (tr) AS (
		SELECT 
			MAX(cte_excdc.rn) AS tr

		FROM 
			cte_excdc
	), 
	
	cte_lastvalues AS (
		SELECT 
			LastestCreatedDateTimeValue			= cte_template.CreatedDateValue + ''000000'' /*cte_template.CreatedTimeValue*/  -- EF FOR NOW IMPORT ALL OF A DAY AGAIN
		,	LatestUpdatedDateTimeValue			= cte_template.UpdatedDateValue + ''000000'' /*cte_template.UpdatedTimeValue */ -- EF FOR NOW IMPORT ALL OF A DAY AGAIN
		,	WaterMarkCutOffTopRangeDtValue		= crs.WaterMarkCutOffTopRangeDtValue
		FROM 
			cte_template
		CROSS APPLY
			[adf].[CurrentRunStatus] AS crs
		WHERE
			crs.LoadConfigID = @LoadConfigID
		
	), 	cte_where AS (
		SELECT 			
			''WHERE'' + 
			+ [adf].[GetCRLF] (1) + ''"LatestModifiedDateTime" >= '' + adf.GetSmallest(cte_lastValues.LastestCreatedDateTimeValue, cte_lastValues.LatestUpdatedDateTimeValue)
			+ [adf].[GetCRLF] (0) + ''AND''
			+ [adf].[GetCRLF] (1) + ''"LatestModifiedDateTime" <= '' + '''' + WaterMarkCutOffTopRangeDtValue + '''' AS WhereDefinition
		FROM 
			cte_lastvalues

	)

	SELECT @ReturnValue += IIF(cte_excdc.rn = 1
								, cte_select.FieldList + '' '' 
									+ CHAR(9) 
									+ CONCAT_WS(''.''
													, cte_serverdatabaseinstance.ServerDatabaseInstanceName
													, cte_database.DatabaseName
													, cte_schema.SchemaName
													, cte_entity.EntityName		
													--, cte_lastvalues.LastestCreatedDateTimeValue
													--, cte_lastvalues.LatestUpdatedDateTimeValue
													--, cte_lastvalues.WaterMarkCutOffTopRangeDtValue
										)  
									+ '' AS '' + [adf].[GetAliasForObject] (cte_entity.EntityName, ''TABLE'')
									+ [adf].[GetCRLF] (0) + cte_templatecdc.JoinType + '' '' + [adf].[GetCRLF] (1)
									+ CONCAT_WS(''.''
													, [adf].[GetQuotedObject] (cte_templatecdc.ExCdcDatabaseName, cte_templatecdc.ExCdcQuotedIdentifierID)		
													, [adf].[GetQuotedObject] (cte_templatecdc.ExCdcEntityName	, cte_templatecdc.ExCdcQuotedIdentifierID)		
									  )  + '' AS '' + [adf].[GetQuotedObjectAlias] (cte_templatecdc.ExCdcEntityName, cte_templatecdc.ExCdcQuotedIdentifierID, ''VIEW'')		
									+ '' '' 
									+  [adf].[GetCRLF] (1) + '' ON ''
								, [adf].[GetCRLF] (1) + '' AND ''
							)
								+ cte_excdc.InternalSideJoin 
								+ '' '' 
								+ cte_excdc.EqualityOperator 
								+ '' ''
								+ cte_excdc.ExternalSideJoin
						+ IIF(cte_excdc.rn = cte_totaljoin.tr
									, [adf].[GetCRLF] (0) + cte_where.WhereDefinition + [adf].[GetCRLF] (0)
									, ''''
						)

	FROM
		cte_template
	CROSS APPLY
		cte_templatecdc
	CROSS APPLY
		cte_excdc
	CROSS APPLY
		cte_select
	CROSS APPLY
		cte_serverdatabaseinstance
	CROSS APPLY
		cte_database
	CROSS APPLY
		cte_schema
	CROSS APPLY
		cte_entity
	CROSS APPLY
		cte_lastvalues
	CROSS APPLY 
		cte_where
	CROSS APPLY
		cte_totaljoin
		
		
	RETURN @ReturnValue


END

' 
END
GO
