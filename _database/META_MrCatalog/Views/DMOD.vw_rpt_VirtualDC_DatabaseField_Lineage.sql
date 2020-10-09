SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_VirtualDC_DatabaseField_Lineage] AS
SELECT DISTINCT
	  'Virtual' AS ViewSource
	, ods_f.FieldID AS ODSFieldID
	, ods_f.DatabaseName AS ODSDatabase
	, ods_f.SchemaName AS ODSSchema
	, ods_f.DataEntityName AS ODSDataEntity
	, ods_f.FieldName AS ODSFieldName
	, ods_f.DataType AS ODSDataType
	, ods_f.[MaxLength] AS ODSMaxLength
	, ods_f.[Precision] AS ODSPrecision
	, ods_f.Scale AS ODSScale
	, stg_db.DatabaseName AS StageDatabase
	, stg_s.SchemaName AS StageSchema
	, stg_de.DataEntityName AS StageDataEntity
	, stg_f.FieldName AS StageFieldName
	, stg_f.DataType AS StageDataType
	, stg_f.[MaxLength] AS StageMaxLength
	, stg_f.[Precision] AS StagePrecision
	, stg_f.Scale AS StageScale
	, v_db.DatabaseName As VaultDatabase
	, v_s.SchemaName AS VaultSchema
	, v_de.DataEntityName AS VaultDataEntity
	, v_f.FieldName AS VaultFieldName
	, v_f.DataType AS VaultDataType
	, v_f.[MaxLength] AS VaultMaxLength
	, v_f.[Precision] AS VaultPrecision
	, v_f.Scale AS VaultScale
FROM
	(
	SELECT
		dc_de.DataEntityID
	FROM
		DMOD.FieldRelation_VirtualDC AS v_fr
			INNER JOIN DC.[Field] AS dc_f		ON v_fr.SourceFieldID = dc_f.FieldID
			INNER JOIN DC.DataEntity As dc_de	ON dc_f.DataEntityID = dc_de.DataEntityID
			INNER JOIN DMOD.Field_VirtualDC v_f	ON v_fr.TargetFieldID = v_f.FieldID
			INNER JOIN DMOD.DataEntity_VirtualDC v_de	ON v_f.DataEntityID = v_de.DataEntityID
			INNER JOIN DMOD.Schema_VirtualDC v_s		ON v_de.SchemaID = v_s.SchemaID 
			INNER JOIN DMOD.Database_VirtualDC v_db		ON v_s.DatabaseID = v_db.DatabaseID
			INNER JOIN DC.DatabasePurpose dc_dp			ON v_db.DatabasePurposeID = dc_dp.DatabasePurposeID 
	WHERE
		dc_dp.DatabasePurposeCode = 'StageArea'
	) AS se --Source Data Entities
		INNER JOIN		DC.vw_rpt_DatabaseFieldDetail AS ods_f		ON se.DataEntityID = ods_f.DataEntityID 
		LEFT OUTER JOIN	DMOD.FieldRelation_VirtualDC AS fr_ods_stg	ON ods_f.FieldID = fr_ods_stg.SourceFieldID 
		LEFT OUTER JOIN DMOD.Field_VirtualDC AS stg_f				ON fr_ods_stg.TargetFieldID = stg_f.FieldID
		LEFT OUTER JOIN DMOD.DataEntity_VirtualDC AS stg_de			ON stg_f.DataEntityID = stg_de.DataEntityID
		LEFT OUTER JOIN	DMOD.Schema_VirtualDC AS stg_s				ON stg_de.SchemaID = stg_s.SchemaID 
		LEFT OUTER JOIN DMOD.Database_VirtualDC AS stg_db			ON stg_s.DatabaseID = stg_db.DatabaseID 
		LEFT OUTER JOIN DMOD.FieldRelation_VirtualDC AS fr_stg_v	ON stg_f.FieldID = fr_stg_v.SourceFieldID
		LEFT OUTER JOIN DMOD.Field_VirtualDC AS v_f					ON fr_stg_v.TargetFieldID = v_f.FieldID
		LEFT OUTER JOIN DMOD.DataEntity_VirtualDC AS v_de			ON v_f.DataEntityID = v_de.DataEntityID
		LEFT OUTER JOIN	DMOD.Schema_VirtualDC AS v_s				ON v_de.SchemaID = v_s.SchemaID 
		LEFT OUTER JOIN DMOD.Database_VirtualDC AS v_db				ON v_s.DatabaseID = v_db.DatabaseID 


GO
