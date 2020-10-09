SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DC].[vw_mat_Field] AS
SELECT 
db.DatabaseID AS [Database ID],
db.DatabaseName AS [Database Name],
db.IsActive AS IsActive_DB,
serv.ServerName AS [Server Name], 
dbinst.DatabaseInstanceID AS [Database Instance ID],
CASE WHEN dbinst.IsDefaultInstance = 1 
			THEN 'Default' 
			ELSE dbinst.DatabaseInstanceName 
		  END AS [Database Instance Name]
		, [system].SystemID AS [System ID]
		, [system].SystemAbbreviation AS [System Abbreviation]
		, [system].SystemName AS [System Name]
		, [schema].SchemaID AS [Schema ID]
		, [schema].SchemaName AS [Schema Name]
		, [schema].DBSchemaID AS [DB Schema ID]
		, de.DataEntityID AS [Data Entity ID]
		, de.DataEntityName AS [Data Entity Name]
		, de.DBObjectID AS [DB Object ID]
		, de.IsActive AS IsActive_DE
		, de.CreatedDT AS DataEntity_CreatedDT,
f.FieldID AS [Field ID],
f.FieldName AS [Field Name],
f.DataType AS [Data Type],
f.[MaxLength] AS [Max Length],
f.[Precision] AS [Precision],
f.[Scale] AS [Scale],
f.StringLength AS [String Length],
f.[Description] AS [Description],
f.IsPrimaryKey AS [Is Primary Key],
f.IsForeignKey AS [Is Foreign Key],
f.DefaultValue AS [Default Value],
f.SystemGenerated AS [System Generated],
f.DataQualityScore AS [Data Quality Score],
f.dpNullCount AS [dp Null Count],
f.dpNullCountPerc AS [dp Null Count Perc],
f.dpDistinctCount AS [dp Distinct Count],
f.dpDuplicateCount AS [dp Duplicate Count],
f.dpDuplicatCountPerc AS [dp Duplicate Count Perc],
f.dpOrphanedChildrenCount AS [dp Orphaned Children Count],
f.dpOrphanedChildrenCountPerc AS [dp Orphaned Children Count Perc],
f.dpMinimum AS [dp Minimum],
f.dpMaximum AS [dp Maximum],
f.[dpAverage] AS [dp Average],
f.[dpMedian] AS [dp Median],
f.[dpStandardDeviation] AS [dp Standard Deviation],
f.[DataEntityID] AS [DataEntity ID],
f.[SystemEntityID] AS [SystemEntity ID],
f.[IsSystemEntityDefinedAtRecordLevel] AS [Is System Entity Defined At Record Level],
f.[DQScore] AS [DQ Score],
f.[DBColumnID] AS [Database Column ID],
f.[CreatedDT] AS [Created Date],
f.UpdatedDT AS [Updated Date],
f.[DataEntitySize] AS [Data Entity Size],
f.[DatabaseSize] AS [Database Size],
f.[IsActive] AS [Is Active],
f.[FieldSortOrder] AS [Field Sort Order],
f.[FriendlyName] AS [Friendly Name],
f.[LastSeenDT] AS [Last Seen Date Time]
		
FROM	DC.[Database] AS db 
	LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	LEFT OUTER JOIN DC.[Schema] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	LEFT OUTER JOIN DC.DataEntity AS de ON de.SchemaID = [schema].SchemaID 
	LEFT OUTER JOIN DC.Field AS f ON f.DataEntityID = de.DataEntityID

GO
