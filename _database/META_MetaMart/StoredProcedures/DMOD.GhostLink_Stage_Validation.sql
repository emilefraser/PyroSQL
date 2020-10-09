SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE PROCEDURE [DMOD].[GhostLink_Stage_Validation] 

AS
--***stage area join check

DROP table if exists #TempGhost2
create table #TempGhost2
(
  
    ForeignDataEntity Varchar(100), 
	ForeignField Varchar(100),
	PrimaryDataEntity Varchar(100),
    TotalJoins int
)


-- use DataManager
Declare @Database VARCHAR(100);
Declare @Schema VARCHAR(100);
Declare @Foreignde VARCHAR(100);
DECLARE @Foreignf VARCHAR(100);
DECLARE @Primary  varchar(100);


DECLARE ddl_cursor CURSOR FOR --queary

SELECT DISTINCT * FROM (
  SELECT DB.DatabaseName, s.SchemaName,  DE.DataEntityName as foreignDE,F.FieldName AS ForeignF,J.DataEntityName as PrimaryDE--,'BKHash' as PrimaryF--,J.FieldName as PrimaryF
  FROM [Datamanager].dc.Field F --base
  Left join [Datamanager].dc.DataEntity de
  on de.DataEntityID = f.DataEntityID
  Left join [Datamanager].dc.[Schema] S
  on s.SchemaID = de.SchemaID
  Left join [Datamanager].dc.[Database] db
  on db.DatabaseID = S.DatabaseID
  Left join 
  (
  SELECT /*f.FieldName,*/de.DataEntityName FROM [Datamanager].dc.Field F
  Left join [Datamanager].dc.DataEntity de
  on de.DataEntityID = f.DataEntityID
  Left join [Datamanager].dc.[Schema] S
  on s.SchemaID = de.SchemaID
  Left join [Datamanager].dc.[Database] db
  on db.DatabaseID = S.DatabaseID
  where DB.DatabaseID = 3
  AND DE.DataEntityName LIKE '%KEYS%'
  AND de.DataEntityName NOT LIKE '%Hist%'
  ) j
  on  J.DataEntityName  LIKE  '%' + '\_'+ replace(F.FieldName,'HK_','') + '\_'+ '%' ESCAPE '\'
  AND J.DataEntityName LIKE  '%' +  S.SchemaName + '%'
  WHERE F.FieldName LIKE 'HK_%'
  AND DB.DatabaseID = 3
  AND DE.DataEntityName LIKE '%KEYS%'
  AND de.DataEntityName NOT LIKE '%Hist%'
  ) X

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @Database,@Schema,@Foreignde,@Foreignf, @Primary;

   WHILE @@FETCH_STATUS = 0 
    BEGIN

   PRINT @Foreignde
   PRINT @Foreignf
   PRINT @Primary

 	declare @sqlCommand varchar(max)

   set @sqlCommand =  
   

'SELECT 
'''+@Database+'''+''.''+'''+@Schema+'''+''.''+'''+@Foreignde+'''  AS ForeignDataEntity
,'''+@Foreignf+''' AS ForeignField
,'''+@Database+'''+''.''+'''+@Schema+'''+''.''+'''+@Primary+'''  AS PrimaryDataEntity
,(SELECT count(1) FROM
['+@Database+'].['+@Schema+'].['+@Primary+'] Prime
 LEFT JOIN ['+@Database+'].['+@Schema+'].['+@Foreignde+'] Fore
 ON Prime.BkHash = Fore.['+@Foreignf+']
 WHERE Fore.['+@Foreignf+'] is not null) AS JoinCount'
   
   insert into #TempGhost2
   exec (@sqlCommand)
   
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @Database,@Schema,@Foreignde,@Foreignf, @Primary;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor

/*
select * from #TempGhost2
where TotalJoins = 0
order by ForeignField asc
*/



--****************************************************** Primary Key check part   ****************************************************


drop table if exists #TempGhost3
create table #TempGhost3
(
  
    HubName Varchar(100), 
	SourceTable Varchar(100),
	DistinctRecords int
)


 --use DataManager
Declare @HUBName VARCHAR(100);
Declare @DatabaseName VARCHAR(100);
Declare @SchemaName VARCHAR(100);
DECLARE @Dataentityname VARCHAR(100);
DECLARE @fieldname varchar(100);

DECLARE ddl_cursor CURSOR FOR --queary

--use DataManager
  select h.HubName,/*hbkf.FieldID,*/db.DatabaseName, s.SchemaName,de.DataEntityName,f.FieldName from [Datamanager].dmod.Hub h
  left join [Datamanager].[DMOD].[HubBusinessKey] hbk
  on hbk.HubID = h.HubID
  left join [Datamanager].[DMOD].[HubBusinessKeyField] hbkf
  on hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
  left join [Datamanager].dc.Field f
  on f.FieldID = hbkf.FieldID
  Left join [Datamanager].dc.DataEntity de
  on de.DataEntityID = f.DataEntityID
  Left join [Datamanager].dc.[Schema] S
  on s.SchemaID = de.SchemaID
  Left join [Datamanager].dc.[Database] db
  on db.DatabaseID = S.DatabaseID
  INNER JOIN (
  select DISTINCT replace(ForeignField,'HK','HUB') AS NOMATCH from #TempGhost2
  WHERE TotalJoins = 0
  ) J ON J.NOMATCH = H.HubName
  WHERE (db.DatabaseID = 4 OR db.DatabaseID = 2)

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @HUBName,@DatabaseName,@SchemaName,@Dataentityname, @fieldname;

   WHILE @@FETCH_STATUS = 0 
    BEGIN

 	declare @sqlCommand2 varchar(max)

   set @sqlCommand2 =  
   
    'SELECT '''+@HUBName+''','''+'['+@DatabaseName+'].['+@SchemaName+'].['+@Dataentityname+']'+''',(select distinct Count('+@fieldname+')
    from ['+@DatabaseName+'].['+@SchemaName+'].['+@Dataentityname+'])'
   
   insert into #TempGhost3
   exec (@sqlCommand2)
   
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @HUBName,@DatabaseName,@SchemaName,@Dataentityname, @fieldname;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor

--Table contains the distinct amount of primary key records (where there where 100% failed joins)
--select distinct * from #TempGhost3
--WHERE DistinctRecords >0

--Hubs where primary tables joins represent the problem *Potentially*
--select distinct HubName from #TempGhost3
--WHERE DistinctRecords >0 





--This table represents all the joins where there are 100% ghost joins and the source dataentity does have records in its primary key column
truncate table  [DMOD].[GhostLink_StageTable_Validation] 
insert into [DMOD].[GhostLink_StageTable_Validation] 
 select DISTINCT TG2.* from #TempGhost2 TG2
 INNER JOIN
 (
 SELECT Distinct HUBNAME FROM #TempGhost3 TG3
 WHERE DistinctRecords >0
 ) l
 ON REPLACE(TG2.ForeignField,'HK_','') = REPLACE(l.HubName,'HUB_','')
where TotalJoins = 0
order by ForeignField asc







GO
