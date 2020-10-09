SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DC].[vw_DCDataLineageRelationships]
AS
SELECT  fr.[SourceFieldID]
	   ,f.FieldName as SourceFieldName
       ,f.DataEntityID as SourceDataEntityID
	   ,de.DataEntityname as SourceDataEntityname
	   ,s.Schemaid as SourceSchemaid
	   ,s.SchemaName as SourceSchemaName
	   ,db.DatabaseID as SourceDatabaseID
	   ,db.DatabaseName as SourceDatabaseName
       ,fr.[TargetFieldID]
	   ,f1.FieldName as TargetFieldName
	   ,f1.DataEntityID as TargetDataEntityID
	   ,de1.DataEntityName as TargetDataEntityname
	   ,s1.Schemaid as TargetSchemaid
	   ,s1.SchemaName as TargetSchemaName
	   ,db1.DatabaseName as TargetDatabaseName
       ,fr.[IsActive]
FROM [DC].[FieldRelation] fr
INNER JOIN dc.Field f on f.FieldID = fr.SourceFieldID
INNER JOIN dc.Field f1 on f1.FieldID = fr.TargetFieldID 
INNER JOIN dc.DataEntity de on de.DataEntityID = f.DataEntityID
INNER JOIN dc.DataEntity de1 on de1.DataEntityID = f1.DataEntityID
INNER JOIN dc.[schema] s on de.SchemaID = s.SchemaID
INNER JOIN dc.[Schema] s1 on s1.schemaid = de1.schemaid
INNER JOIN dc.[Database] db on db.DatabaseID = s.DatabaseID
INNER JOIN dc.[Database] db1 on db1.databaseid = s1.databaseid
  
WHERE FieldRelationTypeID = 2

GO
