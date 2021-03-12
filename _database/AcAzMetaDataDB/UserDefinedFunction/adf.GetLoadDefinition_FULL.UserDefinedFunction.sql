SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetLoadDefinition_FULL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Gets the Load Definition for ADF Full load to extract data from source

	TODO:	Bring in Technology Spesifier so that we know what standard format is [db].[sch].[ent] or [db].[ent]

	Test1: SELECT [adf].[GetLoadDefinition_FULL](5, ''SOURCE'')
	Test2: SELECT [adf].[GetLoadDefinition_FULL](5, ''TARGET'')
	
*/
CREATE       FUNCTION [adf].[GetLoadDefinition_FULL] (
	@LoadConfigID			INT		
,	@SourceOrTarget			NVARCHAR(6)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ReturnValue NVARCHAR(MAX) 

	;WITH cte_template (Template, ServerName, DatabaseInstanceName, DatabaseName, SchemaName, EntityName, FieldList) AS (
		SELECT	
			Template						= lquo.QuotedIdentifier_Definition
		,	ServerName						= IIF(@SourceOrTarget = ''SOURCE'', NULL, lcon.TargetServerName) -- TO USE LATER (TODO1)
		,	DatabaseInstanceName			= IIF(@SourceOrTarget = ''SOURCE'', NULL, lcon.TargetDatabaseInstanceName) -- TO USE LATER (TODO1)
		,	DatabaseName					= IIF(@SourceOrTarget = ''SOURCE'', lcon.SourceDatabaseName, lcon.TargetDatabaseName)
		,	SchemaName						= IIF(@SourceOrTarget = ''SOURCE'', NULL, lcon.TargetSchemaName) -- TO USE LATER (TODO1)
		,	EntityName						= IIF(@SourceOrTarget = ''SOURCE'', lcon.SourceEntityName, lcon.TargetEntityName)
		,	FieldList						= IIF(@SourceOrTarget = ''SOURCE'', IIF(COALESCE(lcon.FieldListForSelect, '''') = '''', ''*'', lcon.FieldListForSelect), ''*'')
		FROM 
			adf.LoadConfig AS lcon
		INNER JOIN
			adf.LoadQuotedIdentifier AS lquo
			ON lquo.LoadQuotedIdentifierID = IIF(@SourceOrTarget = ''SOURCE'', lcon.SourceQuotedIdentifierID, lcon.TargetQuotedIdentifierID)
		WHERE
			lcon.LoadConfigID = @LoadConfigID
	), cte_select AS (
		SELECT 
			FieldList = CONCAT_WS('' ''
									, ''SELECT '' 
									, cte_template.FieldList
									, ''FROM''
			)
		FROM cte_template
	), cte_serverdatabaseinstance (ServerDatabaseInstanceName) AS (
		SELECT
			IIF(COALESCE(cte_template.ServerName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, IIF(COALESCE(cte_template.DatabaseInstanceName, '''') = ''''
									, cte_template.ServerName
									, cte_template.ServerName + ''\'' + cte_template.DatabaseInstanceName
							)
				)
			)
		FROM cte_template
	), cte_database (DatabaseName) AS (
		SELECT 
			IIF(COALESCE(cte_template.DatabaseName, '''') = ''''
				,  NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, cte_template.DatabaseName
				) 
			)
		FROM cte_template	
	), cte_schema (SchemaName) AS (
		SELECT 
			IIF(COALESCE(cte_template.SchemaName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
							, ''@{{OBJECTNAME}}''
							, cte_template.SchemaName
				)
			)
		FROM cte_template	
	), cte_entity (EntityName) AS (
		SELECT 
			IIF(COALESCE(cte_template.EntityName, '''') = ''''
				, NULL
				, REPLACE(cte_template.Template
					, ''@{{OBJECTNAME}}''
					, cte_template.EntityName
				)
			)
		FROM cte_template	
	)
	SELECT @ReturnValue = cte_select.FieldList + '' '' + CONCAT_WS(''.''
															, cte_serverdatabaseinstance.ServerDatabaseInstanceName
															, cte_database.DatabaseName
															, cte_schema.SchemaName
															, cte_entity.EntityName
												)
	FROM
		cte_select
	CROSS APPLY
		cte_serverdatabaseinstance
	CROSS APPLY
		cte_database
	CROSS APPLY
		cte_schema
	CROSS APPLY
		cte_entity

	RETURN @ReturnValue

END


' 
END
GO
