SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE view [DC].[vw_DCDataLineage] as 

SELECT  
	  
      fr.[SourceFieldID]
	  ,f.FieldName as SourceFieldName
	  ,de.DataEntityname + '.' + s.SchemaName + '.' + f.FieldName AS SourceFieldNameDetail
      ,f.DataEntityID as SourceDataEntityID
	  ,de.DataEntityname as SourceDataEntityname
	  ,de.DataEntityTypeID AS SourceDataEntityTypeID
	  ,srcDEType.DataEntityTypeCode AS SourceDataEntityTypeCode
	  ,s.Schemaid as SourceSchemaid
	  ,s.SchemaName as SourceSchemaName
	  ,db.DatabaseID as SourceDatabaseID
	  ,db.DatabaseName as SourceDatabaseName
      ,fr.[TargetFieldID]
	  ,f1.FieldName as TargetFieldName
	  ,de1.DataEntityName + '.' + s1.SchemaName + '.' + f1.FieldName AS TargetFieldNameDetail
	  ,f1.DataEntityID as TargetDataEntityID
	  ,de1.DataEntityName as TargetDataEntityname
	  ,de.DataEntityTypeID AS TargetDataEntityTypeID
	  ,trgDEType.DataEntityTypeCode AS TargetDataEntityTypeCode
	  ,s1.Schemaid as TargetSchemaid
	  ,s1.SchemaName as TargetSchemaName
	  ,db1.DatabaseName as TargetDatabaseName
      ,fr.[IsActive]
  FROM [DC].[FieldRelation] fr
	  join dc.Field f on f.FieldID = fr.SourceFieldID
	  join dc.Field f1 on f1.FieldID = fr.TargetFieldID 
	  join dc.DataEntity de on de.DataEntityID = f.DataEntityID
	  join dc.DataEntity de1 on de1.DataEntityID = f1.DataEntityID
	  join dc.[schema] s on de.SchemaID = s.SchemaID
	  join dc.[Schema] s1 on s1.schemaid = de1.schemaid
	  join dc.[Database] db on db.DatabaseID = s.DatabaseID
	  join dc.[Database] db1 on db1.databaseid = s1.databaseid
	  JOIN DC.DataEntityType srcDEType 
		ON srcDEType.DataEntityTypeID = de.DataEntityTypeID	
	  join DC.DataEntityType trgDEType 
		ON trgDEType.DataEntityTypeID = de1.DataEntityTypeID
  

  where 1=1
	and FieldRelationTypeID = 2

GO
