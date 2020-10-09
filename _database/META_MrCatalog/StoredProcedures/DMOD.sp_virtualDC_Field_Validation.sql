SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Essich Wassenaar
-- Create Date: 2019-09-11
-- Description: Load VitualDC and DC tables to compare Field
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

CREATE PROCEDURE [DMOD].[sp_virtualDC_Field_Validation]
	@DB_Environment varchar(10),
	@DB_PurposeA varchar(10),
	@DB_PurposeB varchar(10)
AS
BEGIN
	
	-- DC Field collection starts
	SELECT
		 'Error: Field not in Virtual DC' AS ErrorMessage
		,'DC' As Origin
		,DC_Field_Exp.FieldID AS FieldID
		,DC_Field_Exp.FieldName AS FieldName
		,DC_Table_Exp.DataEntityName AS DataEntityName
		,DC_Schema.SchemaName AS SchemaName
		,DC_DB.DatabaseName AS DatabaseName
		,DC_DB.DatabaseEnvironmentTypeID AS Environment
		,DC_DB.DatabasePurposeID AS Purpose

	INTO #DC
	FROM
	(
		DC.[Field] DC_Field_Exp

		right join DC.[DataEntity] DC_Table_Exp
				ON DC_Field_Exp.DataEntityID = DC_Table_Exp.DataEntityID

		right join DC.[Schema] DC_Schema
				ON DC_Table_Exp.SchemaID = DC_Schema.SchemaID

		right join DC.[Database] DC_DB
				ON DC_Schema.DatabaseID = DC_DB.DatabaseID

				--right join TYPE.Generic_Detail Environment on DC_DB.DatabaseEnvironmentTypeID = Environment.DetailID
				
	)

	--WHERE Environment.DetailTypeCode = 'DEV' AND (DatabasePurposeID = 3 OR DatabasePurposeID = 4) AND DC_Table_Exp.DataEntityName not like '%_Hist'
	WHERE DatabaseEnvironmentTypeID = @DB_Environment AND (DatabasePurposeID = @DB_PurposeA OR DatabasePurposeID = @DB_PurposeB) AND DC_Table_Exp.DataEntityName not like '%_Hist'



	-- Virtual DC Field collection starts
	SELECT
		'Error: Field not in DC' AS ErrorMessage
		,'vDC' As Origin
		,vDC_Field_Exp.FieldID AS FieldID
		,vDC_Field_Exp.FieldName AS FieldName
		,vDC_Table_Exp.DataEntityName AS DataEntityName
		,vDC_Schema.SchemaName AS SchemaName
		,vDC_DB.DatabaseName AS DatabaseName
		,vDC_DB.DatabaseEnvironmentTypeID AS Environment

	INTO #vDC
	FROM
	(
		DMOD.[Field_VirtualDC] vDC_Field_Exp

		right join DMOD.[DataEntity_VirtualDC] vDC_Table_Exp
				ON vDC_Field_Exp.DataEntityID = vDC_Table_Exp.DataEntityID

		right join DMOD.[Schema_VirtualDC] vDC_Schema
				ON vDC_Table_Exp.SchemaID = vDC_Schema.SchemaID

		right join DMOD.[Database_VirtualDC] vDC_DB
				ON vDC_Schema.DatabaseID = vDC_DB.DatabaseID
	)

	WHERE vDC_Table_Exp.DataEntityName not like '%_Hist'


	-- Comparitor starts
	SELECT
	ISNULL(#DC.ErrorMessage, #vDC.ErrorMessage) AS Error
	,CONCAT(#DC.Origin, #vDC.Origin) AS Origin
	,ISNULL(#DC.DatabaseName, #vDC.DatabaseName) AS DatabaseName
	,ISNULL(#DC.SchemaName, #vDC.SchemaName) AS SchemaName
	,ISNULL(#DC.DataEntityName, #vDC.DataEntityName) AS DataEntityName
	,ISNULL(#DC.FieldName, #vDC.FieldName) AS FieldName
	,ISNULL(#DC.FieldID, #vDC.FieldID) AS FieldID
	
	FROM #DC full outer join #vDC ON (REPLACE(#DC.DatabaseName, 'DEV_', '') = REPLACE(#vDC.DatabaseName, '_VirtualDC', '')
									  AND #DC.SchemaName = #vDC.SchemaName
									  AND #DC.DataEntityName = #vDC.DataEntityName
									  AND #DC.FieldName = #vDC.FieldName)

	
	WHERE	(#DC.DatabaseName is null
			OR #vDC.DatabaseName is null
			OR #DC.SchemaName is null
			OR #vDC.SchemaName is null
			OR #DC.DataEntityName is null
			OR #vDC.DataEntityName is null
			OR #DC.FieldName is null
			OR #vDC.FieldName is null)
			AND NOT
			(#DC.DatabaseName is null
			AND #vDC.DatabaseName is null
			AND #DC.SchemaName is null
			AND #vDC.SchemaName is null
			AND #DC.DataEntityName is null
			AND #vDC.DataEntityName is null
			AND #DC.FieldName is null
			AND #vDC.FieldName is null)

END

GO
