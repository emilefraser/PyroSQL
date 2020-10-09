SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Essich Wassenaar
-- Create Date: 2019-09-11
-- Description: Load VitualDC and DC tables to compare the field modelling relation
-- Tables:		[DMOD].[Field_VirtualDC]
--				[DMOD].[Database_VirtualDC]
--				[DMOD].[DataEntity_VirtualDC]
--				[DMOD].[FieldRelation_VirtualDC]
--				[DMOD].[Schema_VirtualDC]
--				[DC].[Schema]
--				[DC].[Field]
--				[DC].[FieldRelation]
--				[DC].[DataEntity]
--				[DC].[Database]
-- =============================================

CREATE PROCEDURE [DMOD].[sp_virtualDC_FieldRelation_Validation]
	@DB_Environment varchar(10),
	@DB_PurposeA varchar(10),
	@DB_PurposeB varchar(10)
AS
BEGIN
	
	SELECT
		 'Error: Relation not in Virtual DC' AS ErrorMessage
		,'DC' As Origin
		,DC_Field.FieldID AS FieldID
		,DC_Field.FieldName AS FieldName
		,DC_Table.DataEntityName AS DataEntityName
		,DC_Schema.SchemaName AS SchemaName
		,DC_DB.DatabaseName AS DatabaseName
		,DC_Field_target.FieldID AS FieldIDtarget
		,DC_Field_target.FieldName AS FieldNametarget
		,DC_Table_target.DataEntityName AS DataEntityNametarget
		,DC_Schema_target.SchemaName AS SchemaNametarget
		,DC_DB_target.DatabaseName AS DatabaseNametarget

	INTO #DC
	FROM
	(
		DC.FieldRelation DC_Relation

		right join DC.[Field] DC_Field
				ON DC_Relation.SourceFieldID = DC_Field.FieldID

		right join DC.[DataEntity] DC_Table
				ON DC_Field.DataEntityID = DC_Table.DataEntityID

		right join DC.[Schema] DC_Schema
				ON DC_Table.SchemaID = DC_Schema.SchemaID

		right join DC.[Database] DC_DB
				ON DC_Schema.DatabaseID = DC_DB.DatabaseID

		right join DC.[Field] DC_Field_target
				ON DC_Relation.TargetFieldID = DC_Field_target.FieldID

		right join DC.[DataEntity] DC_Table_target
				ON DC_Field_target.DataEntityID = DC_Table_target.DataEntityID

		right join DC.[Schema] DC_Schema_target
				ON DC_Table_target.SchemaID = DC_Schema_target.SchemaID

		right join DC.[Database] DC_DB_target
				ON DC_Schema_target.DatabaseID = DC_DB_target.DatabaseID
		
	)

	WHERE DC_DB.DatabaseEnvironmentTypeID = @DB_Environment AND (DC_DB.DatabasePurposeID = @DB_PurposeA OR DC_DB.DatabasePurposeID = @DB_PurposeB) AND DC_Field.FieldID is not null



	-- Virtual DC Field collection starts
	SELECT
		 'Error: Relation not in DC' AS ErrorMessage
		,'vDC' As Origin
		,vDC_Field.FieldID AS FieldID
		,vDC_Field.FieldName AS FieldName
		,vDC_Table.DataEntityName AS DataEntityName
		,vDC_Schema.SchemaName AS SchemaName
		,vDC_DB.DatabaseName AS DatabaseName
		,vDC_Field_target.FieldID AS FieldIDtarget
		,vDC_Field_target.FieldName AS FieldNametarget
		,vDC_Table_target.DataEntityName AS DataEntityNametarget
		,vDC_Schema_target.SchemaName AS SchemaNametarget
		,vDC_DB_target.DatabaseName AS DatabaseNametarget

	INTO #vDC
	FROM
	(
		DMOD.FieldRelation_VirtualDC vDC_Relation

		right join DMOD.[Field_VirtualDC] vDC_Field
				ON vDC_Relation.SourceFieldID = vDC_Field.FieldID

		right join DMOD.[DataEntity_VirtualDC] vDC_Table
				ON vDC_Field.DataEntityID = vDC_Table.DataEntityID

		right join DMOD.[Schema_VirtualDC] vDC_Schema
				ON vDC_Table.SchemaID = vDC_Schema.SchemaID

		right join DMOD.[Database_VirtualDC] vDC_DB
				ON vDC_Schema.DatabaseID = vDC_DB.DatabaseID

		right join DMOD.[Field_VirtualDC] vDC_Field_target
				ON vDC_Relation.TargetFieldID = vDC_Field_target.FieldID

		right join DMOD.[DataEntity_VirtualDC] vDC_Table_target
				ON vDC_Field_target.DataEntityID = vDC_Table_target.DataEntityID

		right join DMOD.[Schema_VirtualDC] vDC_Schema_target
				ON vDC_Table_target.SchemaID = vDC_Schema_target.SchemaID

		right join DMOD.[Database_VirtualDC] vDC_DB_target
				ON vDC_Schema_target.DatabaseID = vDC_DB_target.DatabaseID
		
	)

	where vDC_Field.FieldID is not null


	-- Comparitor starts
	SELECT
	ISNULL(#DC.ErrorMessage, #vDC.ErrorMessage) AS Error
	,CONCAT(#DC.Origin, #vDC.Origin) AS Origin
	,'' AS x
	,ISNULL(#DC.FieldName, #vDC.FieldName) AS SourceField
	,ISNULL(#DC.DataEntityName, #vDC.DataEntityName) AS SourceDataEntity
	,'vs' AS VS
	,ISNULL(#DC.FieldNametarget, #vDC.FieldNametarget) AS TargetField
	,ISNULL(#DC.DataEntityNametarget, #vDC.DataEntityNametarget) AS TargetDataEntity
	,'' AS x

	,ISNULL(#DC.DatabaseName, #vDC.DatabaseName) AS DatabaseName
	,ISNULL(#DC.SchemaName, #vDC.SchemaName) AS SchemaName
	,ISNULL(#DC.DataEntityName, #vDC.DataEntityName) AS DataEntityName
	,ISNULL(#DC.FieldName, #vDC.FieldName) AS FieldName
	,ISNULL(#DC.FieldID, #vDC.FieldID) AS FieldID
	,'' AS x
	,ISNULL(#DC.DatabaseNametarget, #vDC.DatabaseNametarget) AS DatabaseNameTarget
	,ISNULL(#DC.SchemaNametarget, #vDC.SchemaNametarget) AS SchemaNameTarget
	,ISNULL(#DC.DataEntityNametarget, #vDC.DataEntityNametarget) AS DataEntityNameTarget
	,ISNULL(#DC.FieldNametarget, #vDC.FieldNametarget) AS FieldNameTarget
	,ISNULL(#DC.FieldIDtarget, #vDC.FieldIDtarget) AS FieldIDTarget
	
	FROM #DC full outer join #vDC ON (REPLACE(#DC.DatabaseName, 'DEV_', '') = REPLACE(#vDC.DatabaseName, '_VirtualDC', '')
									  AND #DC.SchemaName = #vDC.SchemaName
									  AND #DC.DataEntityName = #vDC.DataEntityName
									  AND #DC.FieldName = #vDC.FieldName
									  AND REPLACE(#DC.DatabaseNametarget, 'DEV_', '') = REPLACE(#vDC.DatabaseNametarget, '_VirtualDC', '')
									  AND #DC.SchemaNametarget = #vDC.SchemaNametarget
									  AND #DC.DataEntityNametarget = #vDC.DataEntityNametarget
									  AND #DC.FieldNametarget = #vDC.FieldNametarget)

	
	WHERE	(#DC.DatabaseName is null
			OR #vDC.DatabaseName is null
			OR #DC.SchemaName is null
			OR #vDC.SchemaName is null
			OR #DC.DataEntityName is null
			OR #vDC.DataEntityName is null
			OR #DC.FieldName is null
			OR #vDC.FieldName is null
			OR #DC.DatabaseNametarget is null
			OR #vDC.DatabaseNametarget is null
			OR #DC.SchemaNametarget is null
			OR #vDC.SchemaNametarget is null
			OR #DC.DataEntityNametarget is null
			OR #vDC.DataEntityNametarget is null
			OR #DC.FieldNametarget is null
			OR #vDC.FieldNametarget is null)
			AND NOT
			(#DC.DatabaseName is null
			AND #vDC.DatabaseName is null
			AND #DC.SchemaName is null
			AND #vDC.SchemaName is null
			AND #DC.DataEntityName is null
			AND #vDC.DataEntityName is null
			AND #DC.FieldName is null
			AND #vDC.FieldName is null
			AND #DC.DatabaseNametarget is null
			AND #vDC.DatabaseNametarget is null
			AND #DC.SchemaNametarget is null
			AND #vDC.SchemaNametarget is null
			AND #DC.DataEntityNametarget is null
			AND #vDC.DataEntityNametarget is null
			AND #DC.FieldNametarget is null
			AND #vDC.FieldNametarget is null)
			
END

GO
