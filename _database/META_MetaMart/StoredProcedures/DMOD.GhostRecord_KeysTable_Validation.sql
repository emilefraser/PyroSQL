SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [DMOD].[GhostRecord_KeysTable_Validation] 

AS

drop table if exists #TempGhost1
create table #TempGhost1
(
  
    KeysTable Varchar(50), 
	[HK_ Field] Varchar(50),
    AllRecords int,
	GhostRecords int,
	[GhostPercent%] float
)


 --use DataManager

 DECLARE 
    @Dataentityname VARCHAR(50);
DECLARE
	@fieldname varchar(50);

DECLARE ddl_cursor CURSOR FOR --queary

--use DataManager
select s.SchemaName+'.'+de.DataEntityName, f.fieldname 
FROM [DataManager].DC.Field f
Left join [DataManager].dc.DataEntity de 
on de.dataentityid = f.dataentityid
left join [DataManager].dc.[Schema] s
on s.SchemaID = de.SchemaID
left join [DataManager].dc.[Database] db
on db.DatabaseID = s.DatabaseID
where db.DatabaseID = 3
and f.fieldname like 'HK_%'
and de.DataEntityName NOT LIKE '%_Hist'
and de.DataEntityName NOT LIKE '%dbo_SalesInvoiceLine_EMS_KEYS%'

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;

   WHILE @@FETCH_STATUS = 0 
    BEGIN

	

 --use [DEV_Stage].
 	declare @sqlCommand varchar(max)

   print @Dataentityname
   print @FieldName

   set @sqlCommand =  'select '''+@Dataentityname+''','''+@fieldname+''' ,(select count(1) from [DEV_Stage].'+@Dataentityname+' ),(select count(1) from [DEV_Stage].'+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'),
   CASE
   WHEN (select count(1) from [DEV_Stage].'+@Dataentityname+' ) = 0 THEN 0
   ELSE
   (Cast(((select count(1) from [DEV_Stage].'+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'))as FLOAT)/cast(((select count(1) from [DEV_Stage].'+@Dataentityname+' )) as FLOAT))*100
   END AS Ghostpercent'
   
   insert into #TempGhost1
   exec (@sqlCommand)
   
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor

truncate table [Datamanager].[DMOD].[GhostRecords_KeysTables_Validation]
Insert into [Datamanager].[DMOD].[GhostRecords_KeysTables_Validation]
select * from #TempGhost1




GO
