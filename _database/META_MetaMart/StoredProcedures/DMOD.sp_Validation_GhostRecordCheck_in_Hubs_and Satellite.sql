SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


--Wium Swart
--10 September


--exec [DMOD].[sp_Validation_GhostRecordCheck_in_Hubs_and Satellite]


CREATE PROCEDURE [DMOD].[sp_Validation_GhostRecordCheck_in_Hubs_and Satellite]

AS

drop table if exists #TempGhost2
create table #TempGhost2
(
  
    KeysTable Varchar(50), 
	[HK_ Field] Varchar(50),
    AllRecords int,
	GhostRecords int,
	[GhostPercent%] float
)


  declare @sqlCommand2 varchar(max)

  set @sqlCommand2 = 'use Datamanager' 
  exec(@sqlCommand2)
 
  
 DECLARE 
    @Dataentityname VARCHAR(30);
DECLARE
	@fieldname varchar(30);

 declare @sqlCommand1 varchar(max)
   set @sqlCommand1 = 'USE DEV_DATAVAULT' 

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

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;

   exec(@sqlCommand1)

--USE DEV_DataVault

   WHILE @@FETCH_STATUS = 0 
    BEGIN

  




 	declare @sqlCommand varchar(max)

   set @sqlCommand =  'select '''+@Dataentityname+''','''+@fieldname+''' ,(select count(1) from '+@Dataentityname+' ),(select count(1) from '+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'),
   CASE
   WHEN (select count(1) from '+@Dataentityname+' ) = 0 THEN 0
   ELSE
   (Cast(((select count(1) from '+@Dataentityname+' Where '+@fieldname+' = '+'''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''+'))as FLOAT)/cast(((select count(1) from '+@Dataentityname+' )) as FLOAT))*100
   END AS Ghostpercent'
   
   insert into #TempGhost2
   exec (@sqlCommand)
   
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @Dataentityname, @fieldname;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor

select * from #TempGhost2
WHERE GhostRecords = 1

select * from #TempGhost2
WHERE GhostRecords = 0


GO
