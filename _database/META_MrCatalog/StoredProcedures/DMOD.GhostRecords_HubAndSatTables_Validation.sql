SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE PROCEDURE [DMOD].[GhostRecords_HubAndSatTables_Validation] 

AS

BEGIN
drop table if exists #TempGhost2
create table #TempGhost2
(
  
    KeysTable Varchar(100), 
	[HK_ Field] Varchar(100),
    AllRecords int,
	GhostRecords int,
	[GhostPercent%] float
)


--use DataManager
  
 DECLARE 
    @Dataentityname VARCHAR(100);
DECLARE
	@fieldname varchar(100);

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
where db.DatabaseID = 8
and f.fieldname like 'HK_%'
AND (DE.DataEntityName LIKE 'HUB%'
OR DE.DataEntityName LIKE 'SAT%')
AND DE.DataEntityName NOT LIKE '%SalesOrderLine%'

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;

   WHILE @@FETCH_STATUS = 0 
    BEGIN



-- use [DEV_DATAVAULT].
 	declare @sqlCommand varchar(max)

   print @Dataentityname
   print @FieldName


   set @sqlCommand =  'select '''+@Dataentityname+''','''+@fieldname+''' ,(select count(1) from [DEV_DATAVAULT].'+@Dataentityname+' ),(select count(1) from [DEV_DATAVAULT].'+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'),
   CASE
   WHEN (select count(1) from [DEV_DATAVAULT].'+@Dataentityname+' ) = 0 THEN 0
   ELSE
   (Cast(((select count(1) from [DEV_DATAVAULT].'+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'))as FLOAT)/cast(((select count(1) from [DEV_DATAVAULT].'+@Dataentityname+' )) as FLOAT))*100
   END AS Ghostpercent'
   
   insert into #TempGhost2
   exec (@sqlCommand)
   
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor


	
END
Truncate table  [DMOD].[GhostRecord_HubAndSatTables_Validation]
insert into [DMOD].[GhostRecord_HubAndSatTables_Validation]
select * from #TempGhost2




GO
