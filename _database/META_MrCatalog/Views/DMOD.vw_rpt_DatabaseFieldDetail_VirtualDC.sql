SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON








/*ORDER BY
	   serv.ServerName,
	   db.DatabaseName,
	   s.SchemaName,
	   de.DataEntityName,
	   f.DBColumnID
*/

CREATE VIEW [DMOD].[vw_rpt_DatabaseFieldDetail_VirtualDC] AS

SELECT	db.DatabaseID
		, db.DatabaseName
		, db.IsActive AS IsActive_DB
		, serv.ServerName
		, serv.ServerLocation
		, dbinst.DatabaseInstanceID
		, CASE WHEN dbinst.IsDefaultInstance = 1 
			THEN 'Default' 
			ELSE dbinst.DatabaseInstanceName 
		  END AS DatabaseInstanceName
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''
			THEN [system].SystemID
			ELSE SchemaSystem.SystemID
		  END AS [SystemID]
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''
			THEN [system].SystemAbbreviation
			ELSE SchemaSystem.SystemAbbreviation
		  END AS SystemAbbreviation
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''
			THEN [system].SystemName
			ELSE SchemaSystem.SystemName
		  END AS SystemName
		, [schema].SchemaID
		, [schema].SchemaName
		, [schema].DBSchemaID 
		, de.DataEntityID
		, de.DataEntityName
		, de.DBObjectID
		, de.IsActive AS IsActive_DE
		, de.CreatedDT AS DataEntity_CreatedDT
		, f.FieldID
		, f.FieldName
		, f.DBColumnID
		, f.DataType
		, f.MaxLength
		, f.Precision
		, f.Scale
		, f.IsPrimaryKey 
		, f.IsForeignKey
		, f.FriendlyName
		, f.FieldSortOrder
FROM	DMOD.[Database_VirtualDC] AS db 
	LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	LEFT OUTER JOIN DMOD.[Schema_VirtualDC] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	LEFT OUTER JOIN DC.[System] AS [SchemaSystem] ON SchemaSystem.SystemID = [Schema].SystemID
	LEFT OUTER JOIN DMOD.DataEntity_VirtualDC AS de ON de.SchemaID = [schema].SchemaID 
	LEFT OUTER JOIN DMOD.Field_VirtualDC AS f ON f.DataEntityID = de.DataEntityID

GO
