SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/**********************************************************************************************************************
Stored Procedure purpose: Creating a table from DC into the ODS format
Author: Francois Senekal
Date : 2019/01/07
TFS Job: 315
**********************************************************************************************************************/

/**********************************************************************************************************************
--Input parms: Source DataEntityID, Target DatabaseID
--declare params
**********************************************************************************************************************/
CREATE procedure [INTEGRATION].[sp_ods_CreateTableFromDC]
as
declare @SourceDataEntityID int
declare @TargetDatabaseID int
declare @TargetSchemaID int
declare @TargetDataEntityID int

set @SourceDataEntityID = 68
set @TargetDatabaseID = 47


declare @SourceSchemaName varchar(max) = 
	(
		select	s.schemaname 
		from	dc.dataentity de
			join dc.[schema] s
				on s.schemaid = de.schemaid
			join dc.[database] db
				on db.databaseid = s.databaseid
		where de.dataentityid =  @SourceDataEntityID
			--and db.databaseid = @TargetDatabaseID
	)

select	TOP 1 @TargetSchemaID = sc.SchemaID
from	DC.[Schema] sc
where	DatabaseID = @TargetDatabaseID
	and SchemaName = @SourceSchemaName

if @TargetSchemaID IS NULL 
INSERT INTO DC.[Schema] (
	SchemaName,
	DatabaseID,
	DBSchemaID,
	CreatedDT
)

(select s.schemaname 
,@TargetDatabaseID
,NULL
,getdate()
from dc.[schema] s
join dc.dataentity de
	on de.schemaid = s.schemaid
where de.dataentityid = @SourceDataEntityID)

if @TargetSchemaID IS NULL
set @TargetSchemaID = @@IDENTITY;

/**********************************************************************************************************************
--Create table if not exists (copy from source table)
--do an if not exists in target db from DC
**********************************************************************************************************************/
declare @DataEntityName varchar(max) = (
select de.dataentityname
from dc.dataentity de
	join dc.[schema] s
		on s.schemaid = de.schemaid
where s.schemaid = @TargetSchemaID
and de.dataentityname =  (select top 1 dataentityname from dc.dataentity where Dataentityid = @SourceDataEntityID ))


if @DataEntityName IS NULL
INSERT INTO [DC].[DataEntity]
           ([DataEntityName]
           ,[SchemaID]
		   ,CreatedDT)

(SELECT DISTINCT de.DataEntityName,
	   @TargetSchemaID as TargetSchemaID ,			
	   GETDATE() as CreatedDT
FROM DC.DataEntity de
	INNER JOIN DC.[Schema] s ON
		s.SchemaID = de.SchemaID
	INNER JOIN DC.[Database] db ON
		db.DatabaseID = s.DatabaseID
	WHERE de.dataentityid = @SourceDataEntityID
	)
if @DataEntityName IS NULL
set @TargetDataEntityID = @@IDENTITY
else 
set @TargetDataEntityID =  (select top 1 de.DataEntityID 
							from dc.[schema] s 
								join dc.dataentity de ON
									s.schemaid = de.schemaid
							where s.schemaid = @TargetSchemaID
							and de.dataentityname = @DataEntityName
							)
/**********************************************************************************************************************
--Create fields if not exists (copy from source table's fields) - must be a "clean" table (no PK, no FK, etc.)
--do an if not exists in target db from DC, already clean table? , no need to use is primary key etc
**********************************************************************************************************************/

select f.FieldName into #TempFieldList1
from dc.field f
	join dc.dataentity de
		on de.dataentityid = f.dataentityid
	join dc.[schema] s
		on s.schemaid = de.schemaid
where de.dataentityid = @TargetDataEntityID
and s.schemaid = @TargetSchemaID

declare @Count int = (
select count(f.fieldname)
from dc.field f
	join dc.dataentity de
		on de.dataentityid = f.dataentityid
	join dc.[schema] s
		on s.schemaid = de.schemaid
	left join #TempFieldList1 tfl ON
	f.FieldName = tfl.FieldName 
where de.dataentityid = @SourceDataEntityID
and tfl.FieldName is Null
)
if @Count != 0
INSERT INTO [DC].[Field]
           ([FieldName]
           ,[DataType]
           ,[DataEntityID]
           ,[DBColumnID]
		   ,CreatedDT
		   ,DataEntitySize
		   ,DatabaseSize)
(SELECT f.FieldName,
	   f.DataType,
	   @TargetDataEntityID as TargetDataEntityID,
	   null,
	   GETDATE(),
	   null, 
	   null 
FROM DC.Field f
	INNER JOIN dc.dataentity de ON
		de.dataentityid = f.dataentityid
	INNER JOIN dc.[schema] s ON
		s.schemaid = de.schemaid
	LEFT JOIN #TempFieldList1 tfl ON
		f.Fieldname = tfl.Fieldname
WHERE tfl.FieldName is Null
AND de.dataentityid = @SourceDataEntityID
)


--Insert the entries into the DC.FieldRelation table (type = 2)
INSERT INTO [DC].[FieldRelation]
		([SourceFieldID],
		 [TargetFieldID],
		 [FieldRelationTypeID],
		 [CreatedDT]
		 )
SELECT s.fieldid, t.fieldid, 2, GETDATE()
FROM DC.Field s, DC.Field t
WHERE s.DataEntityID = @SourceDataEntityID
  AND t.DataEntityID = @TargetDataEntityID
  AND s.FieldName = t.FieldName

GO
