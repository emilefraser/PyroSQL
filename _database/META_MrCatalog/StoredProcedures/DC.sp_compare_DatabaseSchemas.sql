SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Francois Senekal
-- Create date: 2019/07/30
-- Description:	Stored Proc that outputs the schema differences between two databases
-- =============================================
CREATE PROCEDURE [DC].[sp_compare_DatabaseSchemas] 
	-- Add the parameters for the stored procedure here
	@SourceDatabaseID int,
	@TargetDatabaseID int,
-- @ReturnType =(1 Schema , 2 DataEntity , 3 Field, 4 FieldExtras (Max,Scale,Precision,DataType))
	@ReturnType int
AS
-- =============================================
-- Test Variables (Uncomment the following to test the proc)
-- =============================================
--DECLARE	@SourceDatabaseID int = 2
--DECLARE	@TargetDatabaseID int = 10
---- @ReturnType =(1 Schema , 2 DataEntity , 3 Field , 4 FieldExtras (Max,Scale,Precision,DataType))
--DECLARE	@ReturnType int = 3



DROP TABLE IF EXISTS #SourceF
CREATE TABLE #SourceF
(DatabaseName varchar(100),SchemaID int,SchemaName varchar(100), DataEntityID int,DataEntityName varchar(100), FieldID int,FieldName varchar(100),DataType varchar(30),MaxLenth int, Precision int , Scale int)
insert into #SourceF
select distinct fd.DatabaseName,fd.schemaid,fd.schemaname , fd.DataEntityID,fd.DataEntityName,fd.FieldID,fd.FieldName,fd.DataType,fd.MaxLength,fd.Precision,fd.Scale
from DC.vw_rpt_DatabaseFieldDetail fd
where fd.DatabaseID = @SourceDatabaseID

DROP TABLE IF EXISTS #TargetF
CREATE TABLE #TargetF
(DatabaseName varchar(100),SchemaID int,SchemaName varchar(100), DataEntityID int,DataEntityName varchar(100), FieldID int,FieldName varchar(100),DataType varchar(30),MaxLenth int, Precision int , Scale int)
insert into #TargetF
select distinct fd1.DatabaseName,fd1.schemaid,fd1.schemaname , fd1.DataEntityID,fd1.DataEntityName,fd1.FieldID,fd1.FieldName,fd1.DataType,fd1.MaxLength,fd1.Precision,fd1.Scale
from DC.vw_rpt_DatabaseFieldDetail fd1 where DatabaseID = @TargetDatabaseID

IF @ReturnType = 1
BEGIN

SELECT DISTINCT S.DatabaseName AS SourceDatabaseName,s.SchemaName AS SourceDBSchemaName ,T.DatabaseName AS TargetDatabaseName,T.SchemaName AS TargetDBSchemaName FROM #SourceF S
FULL OUTER JOIN #TargetF T ON
T.SchemaName = S.SchemaName
END

IF @ReturnType = 2

BEGIN

SELECT DISTINCT S.DatabaseName AS SourceDatabaseName,S.SchemaName AS SourceSchemaName,s.DataEntityName AS SourceDBDataEntityName,T.DatabaseName AS TargetDatabaseName,t.SchemaName AS TargetSchemaName,T.DataEntityName AS TargetDBEntityName FROM #SourceF S
FULL OUTER JOIN #TargetF T ON
T.DataEntityName = S.DataEntityName
WHERE (S.DataEntityName IS NOT NULL 
	OR T.DataEntityName IS NOT NULL)
END

IF @ReturnType = 3 
BEGIN

SELECT DISTINCT S.DatabaseName AS SourceDatabaseName,s.SchemaName AS SourceDBSchemaName ,s.DataEntityName AS SourceDataEntityName,s.FieldName AS SourceFieldName,T.DatabaseName AS TargetDatabaseName,T.SchemaName AS TargetDBSchemaName,t.DataEntityName AS TargetDataEntityName ,T.FieldName AS TargetFieldName FROM #SourceF S
FULL OUTER JOIN #TargetF T ON
T.FieldName = S.FieldName
AND T.SchemaName = S.SchemaName
AND T.DataEntityName = S.DataEntityName
WHERE (S.FieldName IS NOT NULL 
	OR T.FieldName IS NOT NULL)

END

IF @ReturnType =  4
BEGIN

SELECT DISTINCT s.DataEntityName AS SourceDataEntityName
			   ,s.FieldName AS SourceFieldName
			   ,S.DataType AS SourceDataType
			   ,S.MaxLenth
			   ,S.Precision
			   ,S.Scale
			   ,t.DataEntityName AS TargetDataEntityName 
			   ,T.FieldName AS TargetFieldName 
			   ,t.DataType AS SourceDataType
			   ,t.MaxLenth
			   ,t.Precision
			   ,t.Scale

FROM #SourceF S
FULL OUTER JOIN #TargetF T ON
	T.FieldName = S.FieldName
		AND T.SchemaName = S.SchemaName
			AND T.DataEntityName = S.DataEntityName
				AND s.DataType = T.DataType
					AND S.MaxLenth = T.MaxLenth
						AND S.Precision = T.Precision
							AND S.Scale = T.Scale
WHERE (S.FieldName IS NOT NULL 
	OR T.FieldName IS NOT NULL)

END


---- =============================================
---- Create the temp table to store the Schema Compare 
---- =============================================
----DROP TABLE IF EXISTS #CompareTable
----CREATE TABLE #CompareTable
----			(SourceDatabaseID int,
----			 SourceDatabaseName varchar(50),
----			 TargetDatabaseID int,
----			 TargetDatabaseName varchar(50),
----			 SourceSchemaName Varchar(50),
----			 TargetSchemaName Varchar(50),
----			 SourceDataEntityName Varchar(100),
----			 TargetDataEntityName Varchar(100)
----			)
----INSERT INTO #CompareTable

----SELECT db.DatabaseID AS SourceDatabaseID
----	  ,db.DatabaseName AS SourceDatabaseName
----	  ,(SELECT DatabaseID FROM DC.[Database] WHERE DatabaseID = @TargetDatabaseID) AS TargetDatabaseID
----	  ,(SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @TargetDatabaseID) AS TargetDatabaseName
----	  ,s.SchemaName
----	  ,TargetSchema.SchemaName
----	  ,de.DataEntityName
----	  ,TargetDataEntity.DataEntityName 
----FROM DC.[Database] db
----	INNER JOIN DC.[Schema] s ON
----		s.DatabaseID = db.DatabaseID
----	FULL OUTER JOIN ( SELECT  s1.SchemaName 
----				FROM DC.[Database] db1 
----					INNER JOIN DC.[Schema] s1 ON
----						s1.DatabaseID = db1.DatabaseID
----				WHERE db1.DatabaseID = @TargetDatabaseID) 
----				AS TargetSchema
----					ON TargetSchema.SchemaName = s.SchemaName	
----	INNER JOIN DC.DataEntity de ON
----		de.SchemaID = s.SchemaID
----	FULL OUTER JOIN ( SELECT  de2.DataEntityName						   
----				FROM DC.[Database] db2
----					INNER JOIN DC.[Schema] s2 ON
----						s2.DatabaseID = db2.DatabaseID
----					INNER JOIN DC.[DataEntity] de2 ON
----						de2.SchemaID = s2.SchemaID 
----				WHERE db2.DatabaseID = @TargetDatabaseID) 
----				AS TargetDataEntity
----					ON TargetDataEntity.DataEntityName = de.DataEntityName				
----WHERE db.DatabaseID = @SourceDatabaseID


------ =============================================
------ Compares the schemas in the databases
------ =============================================
----SELECT DISTINCT    SourceDatabaseID
----				  ,SourceDatabaseName
----				  ,TargetDatabaseID
----				  ,TargetDatabaseName
----				  ,SourceSchemaName
----				  ,TargetSchemaName
----FROM #CompareTable


------ =============================================
------ Compares the dataentities in the databases
------ =============================================
----SELECT DISTINCT SourceDatabaseID
----			   ,SourceDatabaseName
----			   ,TargetDatabaseID
----			   ,TargetDatabaseName
----			   ,SourceDataEntityName
----			   ,TargetDataEntityName
----FROM #CompareTable
----END
----GO




----select distinct fd.DataEntityName , fd1.DataEntityName
----from DC.vw_rpt_DatabaseFieldDetail fd
----full outer join 
----(select distinct fd1.DataEntityName
----from DC.vw_rpt_DatabaseFieldDetail fd1 where DatabaseID = 4
----) fd1 ON fd1.DataEntityName = fd.DataEntityName
----where fd.DatabaseID = 2

-- =============================================
-- Return the Schema compare
-- =============================================

--IF @ReturnType = 1  
--BEGIN

--DROP TABLE IF EXISTS #SourceSchema
--CREATE TABLE #SourceSchema
--(SchemaID int,SchemaName varchar(100))
--insert into #SourceSchema
--select distinct fd.schemaid,fd.schemaname 
--from DC.vw_rpt_DatabaseFieldDetail fd
--where fd.DatabaseID = @SourceDatabaseID

--DROP TABLE IF EXISTS #TargetSchema
--CREATE TABLE #TargetSchema
--(SchemaID int,SchemaName varchar(100))
--insert into #TargetSchema
--select distinct fd1.schemaid,fd1.schemaname 
--from DC.vw_rpt_DatabaseFieldDetail fd1 where DatabaseID = @TargetDatabaseID

--SELECT DISTINCT s.SchemaName AS SourceDBSchemaName ,T.SchemaName AS TargetDBSchemaName FROM #SourceSchema S
--FULL OUTER JOIN #TargetSchema T ON
--T.SchemaName = S.SchemaName
--END


---- =============================================
---- Return the DataEntity compare
---- =============================================
--IF @ReturnType = 2 
--BEGIN

--DROP TABLE IF EXISTS #SourceDE
--CREATE TABLE #SourceDE
--(SchemaID int,SchemaName varchar(100), DataEntityID int,DataEntityName varchar(100))
--insert into #SourceDE
--select distinct fd.schemaid,fd.schemaname , fd.DataEntityID,fd.DataEntityName
--from DC.vw_rpt_DatabaseFieldDetail fd
--where fd.DatabaseID = @SourceDatabaseID

--DROP TABLE IF EXISTS #TargetDE
--CREATE TABLE #TargetDE
--(SchemaID int,SchemaName varchar(100), DataEntityID int,DataEntityName varchar(100))
--insert into #TargetDE
--select distinct fd1.schemaid,fd1.schemaname , fd1.DataEntityID,fd1.DataEntityName
--from DC.vw_rpt_DatabaseFieldDetail fd1 where DatabaseID = @TargetDatabaseID

--SELECT DISTINCT S.SchemaName AS SourceSchemaName,s.DataEntityName AS SourceDBDataEntityName,t.SchemaName AS TargetSchemaName,T.DataEntityName AS TargetDBEntityName FROM #SourceDE S
--FULL OUTER JOIN #TargetDE T ON
--T.DataEntityName = S.DataEntityName
--WHERE (S.DataEntityName IS NOT NULL 
--	OR T.DataEntityName IS NOT NULL)
--END
---- =============================================
---- Return the Field compare
---- =============================================
--IF @ReturnType = 3 
--BEGIN

GO
