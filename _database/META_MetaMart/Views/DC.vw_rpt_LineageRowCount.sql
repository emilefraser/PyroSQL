SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_rpt_LineageRowCount] AS

select 1 test --delete
/*
SELECT DISTINCT
	vdb.DatabaseName AS VaultDatabaseName
	, vsc.SchemaName AS VaultSchemaName
	, vde.DataEntityName AS VaultTableName
	, vde.DataEntityID AS VaultTableEntityID
	, vrc.TBLRowCount AS VaultRowCount
	, sdb.DatabaseName AS StageDatabaseName
	, ssc.SchemaName AS StageSchemaName
	, sde.DataEntityName AS StageTableName
	, src.TBLRowCount AS StageRowCount
	, odsdb.DatabaseName AS ODSDatabaseName
	, odssc.SchemaName AS ODSSchemaName
	, odsde.DataEntityName AS ODSTableName
	, CASE 
	     WHEN odsrc.TBLRowCount IS NULL THEN SVV.RecordCount 
		 ELSE odsrc.TBLRowCount
		 END AS ODSRowCount
FROM
	[DC].[Database] vdb
		INNER JOIN [DC].[Schema] vsc				ON vdb.DatabaseID = vsc.DatabaseID
		INNER JOIN [DC].[DataEntity] vde			ON vsc.SchemaID  = vde.SchemaID
		LEFT OUTER JOIN [DC].vw_rpt_TableRowcounts vrc	ON vdb.DatabaseName = vrc.DatabaseName AND vsc.SchemaName = vrc.SchemaName AND vde.DataEntityName = vrc.[name]
		INNER JOIN [DC].[Field] vf					ON vde.DataEntityID = vf.DataEntityID 
		INNER JOIN [DC].[FieldRelation] vfr			ON vf.FieldID = vfr.TargetFieldID
		INNER JOIN [DC].[Field] sf					ON vfr.SourceFieldID = sf.FieldID
		INNER JOIN [DC].[DataEntity] sde			ON sf.DataEntityID = sde.DataEntityID
		INNER JOIN [DC].[Schema] ssc				ON sde.SchemaID = ssc.SchemaID
		INNER JOIN [DC].[Database] sdb				ON ssc.DatabaseID = sdb.DatabaseID 
		LEFT OUTER JOIN [DC].vw_rpt_TableRowcounts src	ON sdb.DatabaseName = src.DatabaseName AND ssc.SchemaName = src.SchemaName AND sde.DataEntityName = src.[name]
		INNER JOIN [DC].[FieldRelation] sfr			ON sf.FieldID = sfr.TargetFieldID
		INNER JOIN [DC].[Field] odsf				ON sfr.SourceFieldID = odsf.FieldID
		INNER JOIN [DC].[DataEntity] odsde			ON odsf.DataEntityID = odsde.DataEntityID
		INNER JOIN [DC].[Schema] odssc				ON odsde.SchemaID = odssc.SchemaID
		INNER JOIN [DC].[Database] odsdb			ON odssc.DatabaseID = odsdb.DatabaseID 
		LEFT OUTER JOIN [DC].vw_rpt_TableRowcounts odsrc	ON odsdb.DatabaseName = odsrc.DatabaseName AND odssc.SchemaName = odsrc.SchemaName AND odsde.DataEntityName = odsrc.[name]
		LEFT JOIN [DMOD].[Source_View_Validation] SVV ON SVV.[Database] = odsdb.DatabaseName and SVV.[Schema] = odssc.SchemaName and SVV.SourceView =odsde.DataEntityName
--WHERE
--	vdb.DatabaseID = 12
--	AND vsc.SchemaName = 'raw'
--	AND vde.DataEntityName = 'HUB_Customer'

*/

GO
