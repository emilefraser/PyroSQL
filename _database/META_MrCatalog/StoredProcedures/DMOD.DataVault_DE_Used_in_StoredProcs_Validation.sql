SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE PROCEDURE [DMOD].[DataVault_DE_Used_in_StoredProcs_Validation]
AS

DROP table if exists #TempGhost2
create table #TempGhost2
(
   ObjectID int
)


DROP table if exists #TempGhost3
create table #TempGhost3
(
   Objecttemp VARCHAR(500)
)



Declare @StoredProc VARCHAR(500);
Declare @StoredProc2 VARCHAR(500);


Declare @hold varchar(500);
--OUTER CUROSR
DECLARE ddl_cursor CURSOR FOR --queary

   select  'N''raw.'+name+'''' as nametowork from sys.procedures

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @StoredProc;

   WHILE @@FETCH_STATUS = 0 
    BEGIN

 	declare @sqlCommand varchar(max)

   set @sqlCommand = 
     
	' SELECT '+  
    '''raw.''+referenced_entity_name+'''''+' as intop '+
   ' FROM sys.sql_expression_dependencies AS sed  
   INNER JOIN sys.objects AS o ON sed.referencing_id = o.object_id  
   WHERE referencing_id = OBJECT_ID('+@StoredProc+');'

insert into #TempGhost3
exec(@sqlCommand)

--INNER CURSOR
   DECLARE ddl_cursor2 CURSOR FOR 
   
   select * from #TempGhost3

   OPEN ddl_cursor2
   FETCH NEXT FROM ddl_cursor2 INTO @StoredProc2;

   WHILE @@FETCH_STATUS = 0 
   BEGIN

  set @hold = @StoredProc2
  insert into #TempGhost2
  EXEC('SELECT OBJECT_ID (N'+''''  +@hold+  ''')')

   FETCH NEXT FROM ddl_cursor2 INTO @StoredProc2;
   END
   CLOSE ddl_cursor2 
   DEALLOCATE ddl_cursor2

   truncate table #TempGhost3
--INNER CURSOR 

FETCH NEXT FROM ddl_cursor INTO @StoredProc;
END
CLOSE ddl_cursor 
DEALLOCATE ddl_cursor
--OUTER CURSOR


	DELETE FROM #TempGhost2
	WHERE ObjectID IS NULL



Truncate table [DataManager].[DMOD].[DataVault_DE_Used_in_StoredProc_Validation]

INSERT INTO [DataManager].[DMOD].[DataVault_DE_Used_in_StoredProc_Validation]

SELECT distinct de.DataEntityName as LoadConfig_TargetDE,k.* FROM [DataManager].DMOD.LOADCONFIG LC
LEFT JOIN [DataManager].DC.DataEntity DE
ON DE.DataEntityID = LC.TargetDataEntityID
LEFT JOIN [DataManager].DC.[Schema] s
ON DE.SchemaID = s.SchemaID
LEFT JOIN [DataManager].DC.[Database] DB
ON Db.databaseid = s.DatabaseID
left join (
SELECT TBL.object_id as DE_object_id_In_StoredProc, TBL.name AS DataEntity_In_StoredProc, SUM(PART.rows) AS Rows_In_Table
FROM sys.tables TBL
INNER JOIN sys.partitions PART ON TBL.object_id = PART.object_id
INNER JOIN sys.indexes IDX ON PART.object_id = IDX.object_id
AND PART.index_id = IDX.index_id
WHERE IDX.index_id < 2 
and tbl.object_id in 
(
SELECT * FROM #TempGhost2  
)

GROUP BY TBL.object_id, TBL.name

) k 
on k.DataEntity_In_StoredProc = de.DataEntityName

where db.DatabaseName like '%vault%'



GO
