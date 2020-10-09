SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON








/*ORDER BY
	   serv.ServerName,
	   db.DatabaseName,
	   s.SchemaName,
	   de.DataEntityName,
	   f.DBColumnID
*/

CREATE VIEW [DC].[vw_rpt_DatabaseFieldDetail] AS

SELECT	db.DatabaseID
		, db.DatabaseName
		, db.IsActive AS IsActive_DB
		--, dp.DatabasePurposeCode				-- PH Added 20190915
		--, dp.DatabasePurposeDescription			-- PH Added 20190915
		--, ed.DatabaseEnvironmentTypeCode		-- PH Added 20190915
		--, ed.DatabaseEnvironmentTypeName		-- PH Added 20190915
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
FROM	DC.[Database] AS db 
	LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	LEFT OUTER JOIN DC.[Schema] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	LEFT OUTER JOIN DC.[System] AS [SchemaSystem] ON SchemaSystem.SystemID = [Schema].SystemID
	LEFT OUTER JOIN DC.DataEntity AS de ON de.SchemaID = [schema].SchemaID 
	LEFT OUTER JOIN DC.Field AS f ON f.DataEntityID = de.DataEntityID
	--LEFT OUTER JOIN DC.DatabasePurpose dp	ON dp.DatabasePurposeID = db.DatabasePurposeID				-- PH Added 20190915
	--LEFT OUTER JOIN	(																					-- PH Added 20190915
	--				SELECT																				-- PH Added 20190915
	--					  gd.DetailID AS DatabaseEnvironmentTypeID										-- PH Added 20190915
	--					, gd.DetailTypeCode AS DatabaseEnvironmentTypeCode								-- PH Added 20190915
	--					, gd.DetailTypeDescription AS DatabaseEnvironmentTypeName						-- PH Added 20190915
	--				FROM																				-- PH Added 20190915
	--					[TYPE].Generic_Header gh														-- PH Added 20190915
	--					inner join [TYPE].Generic_Detail gd ON gd.HeaderID = gh.HeaderID				-- PH Added 20190915
	--				WHERE																				-- PH Added 20190915
	--					gh.HeaderCode = 'DB_ENV'														-- PH Added 20190915
	--				) ed	ON ed.DatabaseEnvironmentTypeID = db.DatabaseEnvironmentTypeID				-- PH Added 20190915
	

GO
