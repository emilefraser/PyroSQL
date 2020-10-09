SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE PROCEDURE [DMOD].[Source_Views_Validation] 
  @DatabaseEnvironmentTypeID INT	
AS

drop table if exists #TempGhost1
create table #TempGhost1
(
	[Database] Varchar(50),
	[Schema] Varchar(50),
	SourceView Varchar(50),
    RecordCount int
)


 --use DataManager
 DECLARE 
    @Databasename VARCHAR(50);
 DECLARE 
    @Dataentityname VARCHAR(50);
 DECLARE 
    @Schemaname VARCHAR(50);


DECLARE ddl_cursor CURSOR FOR --queary

SELECT DB.DatabaseName, S.SchemaName, DE.DataEntityName FROM DC.DataEntity de
LEFT JOIN DC.[Schema] S
on s.SchemaID = de.schemaid
left join DC.[Database] db
on db.DatabaseID =S.DatabaseID
WHERE DE.DataEntityName LIKE 'VW%'
AND db.DatabaseEnvironmentTypeID = @DatabaseEnvironmentTypeID
--and db.DatabaseName like '%d365%'

   OPEN ddl_cursor
    FETCH NEXT FROM ddl_cursor INTO @Databasename, @Schemaname, @Dataentityname;

   WHILE @@FETCH_STATUS = 0 
    BEGIN

	select ''+@Databasename+'.'+@Schemaname+'.'+@Dataentityname+''

 --use [DEV_StageArea].
 	declare @sqlCommand varchar(max)
	

   set @sqlCommand =  'select '''+@Databasename+''','''+@Schemaname+''','''+@Dataentityname+''' 
   ,(select count(1) from '+@Databasename+'.'+@Schemaname+'.'+@Dataentityname+' )
'
    BEGIN TRY;


   insert into #TempGhost1
   exec (@sqlCommand)

    END TRY

    BEGIN CATCH;
   SELECT 'eRroR'
    END CATCH;
 
    --PRINT @DDLScript
   FETCH NEXT FROM ddl_cursor INTO @Databasename, @Schemaname, @Dataentityname;
    END
    CLOSE ddl_cursor 
    DEALLOCATE ddl_cursor


TRUNCATE TABLE [DMOD].[Source_View_Validation]
INSERT INTO [DMOD].[Source_View_Validation]
select * from #TempGhost1




GO
