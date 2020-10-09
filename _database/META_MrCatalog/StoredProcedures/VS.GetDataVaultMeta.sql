SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE VS.GetDataVaultMeta
AS
DECLARE @SourceVersion INT = 26
, @DataVaultVersion INT = 21

SELECT
	@SourceVersion AS SourceVersion
,	@DataVaultVersion AS DataVaultVersion
,	obj.[Type_Desc] AS ObjectType
,	SUBSTRING(obj.name, 1, CHARINDEX('_', obj.name) - 1) AS VaultEntityType
,	QUOTENAME(sch.[name]) AS SchemaName
,   QUOTENAME(obj.name) AS ObjectName
,	NULL AS ParentObject
,	Ensamble				= CASE WHEN SUBSTRING(obj.name, 1, CHARINDEX('_', obj.name) - 1)  = 'HUB' THEN REPLACE(obj.name, 'HUB_', '')
								 WHEN SUBSTRING(obj.name, 1, CHARINDEX('_', obj.name) - 1) = 'LINKSAT' THEN SUBSTRING(REPLACE(REPLACE(obj.name, 'SAP_S4HANA_',''), 'LINKSAT_', ''), 1,  CHARINDEX('_', REPLACE(REPLACE(obj.name, 'SAP_S4HANA_',''), 'LINKSAT_', '')) -1)
								  WHEN SUBSTRING(obj.name, 1, CHARINDEX('_', obj.name) - 1)  = 'SAT' THEN REPLACE(obj.name, 'SAT_', '')
								  WHEN SUBSTRING(obj.name, 1, CHARINDEX('_', obj.name) - 1)  = 'LINK' THEN SUBSTRING(REPLACE(obj.name, 'LINK_', ''), 1, CHARINDEX('_', REPLACE(obj.name, 'LINK_', '')) - 1)
								  ELSE obj.name END
FROM 
	sys.objects AS obj
INNER JOIN 
	sys.schemas AS sch
	ON sch.schema_id = obj.schema_id
WHERE
	obj.is_ms_shipped = 0
AND	
	sch.name = 'raw'
AND
	obj.[Type] = 'U'

UNION ALL 

SELECT 	
	SourceVersion		 = @SourceVersion
,	DataVaultVersion	 = @DataVaultVersion
,	ObjectType			= 'COLUMN' 
,	VaultEntityType		= 'BK'
,	SchemaName			= QUOTENAME(sch.name)
,	ObjectName			= QUOTENAME(col.name)
,	ParentObject		= QUOTENAME(tab.name)
,	Ensamble				=CASE WHEN SUBSTRING(tab.name, 1, CHARINDEX('_', tab.name) - 1)  = 'HUB' THEN REPLACE(tab.name, 'HUB_', '')
								 WHEN SUBSTRING(tab.name, 1, CHARINDEX('_', tab.name) - 1) = 'LINKSAT' THEN SUBSTRING(REPLACE(REPLACE(tab.name, 'SAP_S4HANA_',''), 'LINKSAT_', ''), 1,  CHARINDEX('_', REPLACE(REPLACE(tab.name, 'SAP_S4HANA_',''), 'LINKSAT_', '')) -1)
								  WHEN SUBSTRING(tab.name, 1, CHARINDEX('_', tab.name) - 1)  = 'SAT' THEN REPLACE(tab.name, 'SAT_', '')
								  WHEN SUBSTRING(tab.name, 1, CHARINDEX('_', tab.name) - 1)  = 'LINK' THEN SUBSTRING(REPLACE(tab.name, 'LINK_', ''), 1, CHARINDEX('_', REPLACE(tab.name, 'LINK_', '')) - 1)
								  ELSE tab.name END
FROM sys.tables as tab
INNER JOIN sys.schemas AS sch
ON sch.Schema_ID = tab.Schema_ID
INNER JOIN sys.columns as col
ON tab.object_id = col.object_id
    left join sys.types as t
    on col.user_type_id = t.user_type_id
where sch.name = 'raw'
AND col.name like 'BK_%'
and  SUBSTRING(tab.name,1, 3) = 'HUB'

GO
