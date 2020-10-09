SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [DMOD].[vw_DCDataLineage_VirtualDC]
as 
SELECT  
	  
      fr.[SourceFieldID]
	  ,f.FieldName as SourceFieldName
	  ,de.DataEntityname + '.' + s.SchemaName + '.' + f.FieldName AS SourceFieldNameDetail
      ,f.DataEntityID as SourceDataEntityID
	  ,de.DataEntityname as SourceDataEntityname
	  ,s.Schemaid as SourceSchemaid
	  ,s.SchemaName as SourceSchemaName
	  ,db.DatabaseID as SourceDatabaseID
	  ,db.DatabaseName as SourceDatabaseName
      ,fr.[TargetFieldID]
	  ,f1.FieldName as TargetFieldName
	  ,de1.DataEntityName + '.' + s1.SchemaName + '.' + f1.FieldName AS TargetFieldNameDetail
	  ,f1.DataEntityID as TargetDataEntityID
	  ,de1.DataEntityName as TargetDataEntityname
	  ,s1.Schemaid as TargetSchemaid
	  ,s1.SchemaName as TargetSchemaName
	  ,db1.DatabaseName as TargetDatabaseName
      ,fr.[IsActive]
  FROM [DMOD].[FieldRelation_VirtualDC] fr
  join dc.Field f on f.FieldID = fr.SourceFieldID
  join DMOD.Field_VirtualDC f1 on f1.FieldID = fr.TargetFieldID 
  join dc.DataEntity de on de.DataEntityID = f.DataEntityID
  join DMOD.DataEntity_VirtualDC de1 on de1.DataEntityID = f1.DataEntityID
  join dc.[schema] s on de.SchemaID = s.SchemaID
  join DMOD.[Schema_VirtualDC] s1 on s1.schemaid = de1.schemaid
  join dc.[Database] db on db.DatabaseID = s.DatabaseID
  join DMOD.[Database_VirtualDC] db1 on db1.databaseid = s1.databaseid
  WHERE db1.DatabaseName like '%STAGE%'

  AND FieldRelationTypeID = 2

GO
