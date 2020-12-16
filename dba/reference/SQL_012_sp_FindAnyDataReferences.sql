--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: find table/view columns containing search phrase, but in all databases 
--#################################################################################################
--EXEC sp_FindAnyDataReferences 'TBBreakfast',' WHERE MailCourse = ''cereal'' '
IF OBJECT_ID('[dbo].[sp_FindAnyDataReferences]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_FindAnyDataReferences] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE sp_FindAnyDataReferences
  (@ParentTbName sysname,
   @Criteria  VARCHAR(2000) 
   )
AS
BEGIN --PROC 
--if any error occurs, rollback the whole DELETE stack
SET XACT_ABORT ON  
SET NOCOUNT ON 
--we assume this is something dynamic but including the WHERE like 'WHERE SOMEKEY = 1 AND STATUS = 'Locked'
create table #tmpFKeys 
(PKTABLE_QUALIFIER sysname not null, 
PKTABLE_OWNER sysname not null, 
PKTABLE_NAME sysname not null, 
PKCOLUMN_NAME sysname not null, 
FKTABLE_QUALIFIER sysname not null, 
FKTABLE_OWNER sysname not null,
FKTABLE_NAME sysname not null,
FKCOLUMN_NAME sysname not null,
KEY_SEQ smallint not null,
UPDATE_RULE smallint not null,
DELETE_RULE smallint not null,
FK_NAME sysname not null,
PK_NAME sysname not null,
DEFERRABILITY int not null)

Create index #tmpFKeys on #tmpFKeys (FK_NAME, KEY_SEQ)


-- Get FK-info (all dependant objects)
insert into #tmpFKeys
exec sp_fkeys  @pktable_name = @ParentTbName
 
-- select * from #tmpFKeys
BEGIN TRAN
declare
  @isql      varchar(2000),
  @chldTbl   varchar(128),
  @ChildCol  varchar(128),
  @ParentCol varchar(128)

 CREATE TABLE #Results (ResultsId INT identity(1,1) not null primary key, ResultsTest varchar(max) )     
 
 --now the master table itself
  --select @isql = ' SELECT * FROM ' + @ParentTbName + ' FROM ' + @ParentTbName + ' ' + @Criteria
  select @isql =' execute sp_export_data @table_name = '''+ @ParentTbName + ''', @from=" FROM ' + @ParentTbName + ' ' + @Criteria + '";'
  print @isql

  exec(@isql) --commented out for now


  declare c1 cursor for select FKTABLE_NAME,FKCOLUMN_NAME,PKCOLUMN_NAME  from #tmpFKeys
  open c1
  fetch next from c1 into @chldTbl,@ChildCol,@ParentCol
  While @@fetch_status <> -1
    begin
    --select @isql = ' SELECT * FROM ' + @chldTbl + ' WHERE ' + @ChildCol + ' IN (SELECT ' + @ParentCol + ' FROM ' + @ParentTbName + ' ' + @Criteria + ')'
    select @isql =' execute sp_export_data @table_name = ''' + @chldTbl + ''', @from="FROM ' + @chldTbl + ' WHERE ' + @ChildCol + ' IN (SELECT ' + @ParentCol + ' FROM ' + @ParentTbName + ' ' + @Criteria + ')";'
    print @isql

    exec(@isql) --commented out for now
      
    fetch next from c1 into @chldTbl,@ChildCol,@ParentCol
    end
  close c1
  deallocate c1


  select * from #Results order by ResultsId 
COMMIT TRAN
END --PROC