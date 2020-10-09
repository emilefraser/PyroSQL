SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_Validate_PKFKLink_DataTypes_MaxSizes]
AS
SELECT 
CASE 
		WHEN fpkfkf_pk_p.DataType <> fpkfkf_fk_p.DataType THEN 'Possible DataType Mismatch'
		WHEN fpkfkf_pk_p.[MaxLength] <>  fpkfkf_fk_p.[MaxLength] THEN 'Possbile Truncation Issue'
		ELSE 'All Good here'
		END AS DataTypeAndSizeCheck,
	h.HubID, h.HubName, pkfk_p.PKFKLinkID, pkfk_p.LinkName, 
	pkfk_p.ParentHubID, pkfk_p.ChildHubID
	, fpkfkf_pk_p.FieldID AS FieldID_PK,fpkfkf_pk_p.FieldName AS FieldName_PK, fpkfkf_pk_p.DataType AS DataType_PK, fpkfkf_pk_p.[MaxLength] AS MaxLength_PK
	, depk_p.DataEntityID AS DataEntityID_PK, depk_p.DataEntityName AS DataEntityName_PK
	, spk_p.SchemaID AS SchemaID_PK, spk_p.SchemaName AS SchemaName_PK
	, dpk_p.DatabaseID AS DatabaseID_PK, dfk_p.DatabaseName AS DatabaseName_PK
	, fpkfkf_fk_p.FieldID AS FieldID_FK,fpkfkf_fk_p.FieldName AS FieldName_FK, fpkfkf_fk_p.DataType AS DataType_FK, fpkfkf_fk_p.[MaxLength] AS MaxLength_FK
	, defk_p.DataEntityID AS DataEntityID_FK, defk_p.DataEntityName AS DataEntityName_FK
	, sfk_p.SchemaID AS SchemaID_FK, sfk_p.SchemaName AS SchemaName_FK
	, dfk_p.DatabaseID AS DatabaseID_FK, dfk_p.DatabaseName AS DatabaseName_FK
FROM 
			DMOD.Hub AS h
		INNER JOIN 
			DMOD.PKFKLink AS pkfk_p
			ON pkfk_p.ParentHubID = h.HubID
		INNER JOIN 
			DMOD.PKFKLinkField AS pkfkf_p
			ON pkfkf_p.PKFKLinkID = pkfk_p.PKFKLinkID
		INNER JOIN 
			DC.[Field] AS fpkfkf_pk_p
			ON fpkfkf_pk_p.FieldID = pkfkf_p.PrimaryKeyFieldID
		INNER JOIN 
			DC.DataEntity AS depk_p
			ON depk_p.DataEntityID = fpkfkf_pk_p.DataEntityID
		INNER JOIN 
			DC.[Schema] AS spk_p
			ON spk_p.SchemaID = depk_p.SchemaID
		INNER JOIN 
			DC.[Database] AS dpk_p
			ON dpk_p.DatabaseID = spk_p.DatabaseID
		INNER JOIN 
			DC.[Field] AS fpkfkf_fk_p
			ON fpkfkf_fk_p.FieldID = pkfkf_p.ForeignKeyFieldID
		INNER JOIN 
			DC.DataEntity AS defk_p
			ON defk_p.DataEntityID = fpkfkf_fk_p.DataEntityID
		INNER JOIN 
			DC.[Schema] AS sfk_p
			ON sfk_p.SchemaID = defk_p.SchemaID
		INNER JOIN 
			DC.[Database] AS dfk_p
			ON dfk_p.DatabaseID = sfk_p.DatabaseID
		WHERE 
			h.IsActive = 1
		AND
			pkfk_p.IsActive = 1
		AND
			pkfkf_p.IsActive = 1
		AND
		(
			fpkfkf_pk_p.DataType <> fpkfkf_fk_p.DataType
				OR
			fpkfkf_pk_p.[MaxLength] <>  fpkfkf_fk_p.[MaxLength] 
		)

GO
