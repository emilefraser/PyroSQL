/*
███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

 ██████╗██████╗ ███████╗ █████╗ ████████╗███████╗    ████████╗███████╗███████╗████████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
██║     ██████╔╝█████╗  ███████║   ██║   █████╗         ██║   █████╗  ███████╗   ██║   
██║     ██╔══██╗██╔══╝  ██╔══██║   ██║   ██╔══╝         ██║   ██╔══╝  ╚════██║   ██║   
╚██████╗██║  ██║███████╗██║  ██║   ██║   ███████╗       ██║   ███████╗███████║   ██║   
 ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   
                                                                                       
        ██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗              
        ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝              
        ██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗                
        ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝                
        ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗              
        ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝              

███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
*/
--===== Environmental Presets
    SET NOCOUNT ON
;
--===== Make sure that we're not using in the database we want to drop
    USE master
;
--===== Check to see if the test database already exists.
     -- If it does, issue a warning, wait for 20 seconds to give the
     -- operator a chance to stop the run, and then drop the database
     -- if the operator doesn't stop the run.
     IF DB_ID('SomeTestDB') IS NOT NULL --select DB_ID('SomeTestDB')
  BEGIN
--===== Issue the warning on both possible displays.
     -- This message will appear in the GRID if its enabled and on the
     -- messages tab, if not.
--====================================================================
 SELECT [***** WARNING! ***** WARNING! ***** WARNING! *****] =
        '***** WARNING! ***** WARNING! ***** WARNING! *****'
  UNION ALL
 SELECT '  THIS CODE WILL DROP THE [SomeTestDB] DATABASE!'    
  UNION ALL
 SELECT '      YOU HAVE 20 SECONDS TO STOP THIS CODE'        
  UNION ALL
 SELECT '         BEFORE THE DATABASE IS DROPPED!!'
  UNION ALL
 SELECT '***** WARNING! ***** WARNING! ***** WARNING! *****'
;
--===== Force materialization/display of the warning message.
RAISERROR('',0,0) WITH NOWAIT
;
--===== Wait for 20 seconds to give the operator a chance to
     --  canceldropping the database.
WAITFOR DELAY '00:00:20'
;
--===== At this point, the operator has not stopped the run.
     -- Drop the database;
   EXEC msdb.dbo.sp_delete_database_backuphistory 
        @database_name = N'SomeTestDB'
;
  ALTER DATABASE SomeTestDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE
;
   DROP DATABASE SomeTestDB
;
    END
;
GO
--====================================================================
--      Create the test database
--      Remember that such a simple creation will create the database
--      in whatever directories are the default directories for MDF
--      and LDF storage.  Change the code below if the files for
--      this database need to be stored somewhere else.
--====================================================================
--===== Create the database.
 CREATE DATABASE SomeTestDB
;
--===== Set the database to FULL Recovery Model.
  ALTER DATABASE SomeTestDB SET RECOVERY FULL WITH NO_WAIT
;
--===== Take a backup (to the BitBucket) to ensure the test database
     -- is in the FULL Recovery Model.
 BACKUP DATABASE SomeTestDB TO DISK = 'NUL'
;
GO
/*
███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

 ██████╗██████╗ ███████╗ █████╗ ████████╗███████╗    ████████╗███████╗███████╗████████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
██║     ██████╔╝█████╗  ███████║   ██║   █████╗         ██║   █████╗  ███████╗   ██║   
██║     ██╔══██╗██╔══╝  ██╔══██║   ██║   ██╔══╝         ██║   ██╔══╝  ╚════██║   ██║   
╚██████╗██║  ██║███████╗██║  ██║   ██║   ███████╗       ██║   ███████╗███████║   ██║   
 ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   
                                                                                       
                    ████████╗ █████╗ ██████╗ ██╗     ███████╗                          
                    ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝                          
                       ██║   ███████║██████╔╝██║     █████╗                            
                       ██║   ██╔══██║██╔══██╗██║     ██╔══╝                            
                       ██║   ██║  ██║██████╔╝███████╗███████╗                          
                       ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝                          

███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
*/
--===== Use the new test database for the following code.
    USE SomeTestDB
GO
--====================================================================
--      If the test table already exists, drop it.
--====================================================================
     IF OBJECT_ID('dbo.SomeTestTable','U') IS NOT NULL 
        DROP TABLE dbo.SomeTestTable; 
GO
--====================================================================
--      Create the test table with a Fill Factor of 70 on the CI.
--====================================================================
 CREATE TABLE dbo.SomeTestTable 
        (
         RowNum     INT IDENTITY(1,1)
        ,SomeDT     DATETIME
        ,SomeINT    INT
        CONSTRAINT PK_SomeTestTable
            PRIMARY KEY CLUSTERED (RowNum) 
            WITH (FILLFACTOR = 70)
        )
;
GO
/*
███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

███╗   ██╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ██╗         ████████╗███████╗███████╗████████╗
████╗  ██║██╔═══██╗██╔══██╗████╗ ████║██╔══██╗██║         ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
██╔██╗ ██║██║   ██║██████╔╝██╔████╔██║███████║██║            ██║   █████╗  ███████╗   ██║   
██║╚██╗██║██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║            ██║   ██╔══╝  ╚════██║   ██║   
██║ ╚████║╚██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║███████╗       ██║   ███████╗███████║   ██║   
╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   

███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
*/
--===== Use the new test database for the following code.
    USE SomeTestDB
GO
--====================================================================
--      Populate the test table in 2 batches of 100,000 each.
--      Report the page density after each batch.
--      The code for each insert is absolutely identical.
--====================================================================
--===== First batch of INSERTs 
 INSERT INTO dbo.SomeTestTable 
        (SomeDT,SomeINT)
 SELECT TOP (100000)
         SomeDate = RAND(CHECKSUM(NEWID()))
                  * DATEDIFF(dd,'2000','2020')
                  + DATEADD(dd,0,'2000')
        ,SomeInt  = ABS(CHECKSUM(NEWID())%100)+1
   FROM      sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
;
 SELECT PageDensity = avg_page_space_used_in_percent
        ,RowCnt     = record_count
   FROM sys.dm_db_index_physical_stats
        (DB_ID(),OBJECT_ID('dbo.SomeTestTable','U'),1,NULL,'SAMPLED')
;
----------------------------------------------------------------------
--===== Second batch of INSERTs 
 INSERT INTO dbo.SomeTestTable 
        (SomeDT,SomeINT)
 SELECT TOP (100000)
         SomeDate = RAND(CHECKSUM(NEWID()))
                  * DATEDIFF(dd,'2000','2020')
                  + DATEADD(dd,0,'2000')
        ,SomeInt  = ABS(CHECKSUM(NEWID())%100)+1
   FROM      sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
;
 SELECT PageDensity = avg_page_space_used_in_percent
        ,RowCnt     = record_count
   FROM sys.dm_db_index_physical_stats
        (DB_ID(),OBJECT_ID('dbo.SomeTestTable','U'),1,NULL,'SAMPLED')
;
GO
/*
███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

███████╗██████╗ ███████╗ ██████╗██╗ █████╗ ██╗         ████████╗███████╗███████╗████████╗
██╔════╝██╔══██╗██╔════╝██╔════╝██║██╔══██╗██║         ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
███████╗██████╔╝█████╗  ██║     ██║███████║██║            ██║   █████╗  ███████╗   ██║   
╚════██║██╔═══╝ ██╔══╝  ██║     ██║██╔══██║██║            ██║   ██╔══╝  ╚════██║   ██║   
███████║██║     ███████╗╚██████╗██║██║  ██║███████╗       ██║   ███████╗███████║   ██║   
╚══════╝╚═╝     ╚══════╝ ╚═════╝╚═╝╚═╝  ╚═╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   

███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
*/
RAISERROR ('
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    NOTICE! BEFORE RUNNING THIS TEST, RUN THE "CREATE TEST DATABASE" 
             AND THE "CREATE TEST TABLE" SECTIONS AGAIN!
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
',0,0) WITH NOWAIT
;
--===== Use the new test database for the following code.
    USE SomeTestDB
GO
--====================================================================
--      Populate the test table in 2 batches of 100,000 each.
--      Report the page density after each batch.
--      The code for each insert is nearly identical to the previous
--      test code but WITH(TABLOCK) has been added to each INSERT.
--====================================================================
--===== First batch of INSERTs 
 INSERT INTO dbo.SomeTestTable WITH(TABLOCK)
        (SomeDT,SomeINT)
 SELECT TOP (100000)
         SomeDate = RAND(CHECKSUM(NEWID()))
                  * DATEDIFF(dd,'2000','2020')
                  + DATEADD(dd,0,'2000')
        ,SomeInt  = ABS(CHECKSUM(NEWID())%100)+1
   FROM      sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
;
 SELECT PageDensity = avg_page_space_used_in_percent
        ,RowCnt     = record_count
   FROM sys.dm_db_index_physical_stats
        (DB_ID(),OBJECT_ID('dbo.SomeTestTable','U'),1,NULL,'SAMPLED')
;
----------------------------------------------------------------------
--===== Second batch of INSERTs 
 INSERT INTO dbo.SomeTestTable WITH(TABLOCK)
        (SomeDT,SomeINT)
 SELECT TOP (100000)
         SomeDate = RAND(CHECKSUM(NEWID()))
                  * DATEDIFF(dd,'2000','2020')
                  + DATEADD(dd,0,'2000')
        ,SomeInt  = ABS(CHECKSUM(NEWID())%100)+1
   FROM      sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
;
 SELECT PageDensity = avg_page_space_used_in_percent
        ,RowCnt     = record_count
   FROM sys.dm_db_index_physical_stats
        (DB_ID(),OBJECT_ID('dbo.SomeTestTable','U'),1,NULL,'SAMPLED')
;
GO
/*
███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

 █████╗ ███╗   ██╗ █████╗ ██╗  ██╗   ██╗███████╗██╗███████╗     ██████╗ ██████╗ ██████╗ ███████╗
██╔══██╗████╗  ██║██╔══██╗██║  ╚██╗ ██╔╝██╔════╝██║██╔════╝    ██╔════╝██╔═══██╗██╔══██╗██╔════╝
███████║██╔██╗ ██║███████║██║   ╚████╔╝ ███████╗██║███████╗    ██║     ██║   ██║██║  ██║█████╗  
██╔══██║██║╚██╗██║██╔══██║██║    ╚██╔╝  ╚════██║██║╚════██║    ██║     ██║   ██║██║  ██║██╔══╝  
██║  ██║██║ ╚████║██║  ██║███████╗██║   ███████║██║███████║    ╚██████╗╚██████╔╝██████╔╝███████╗
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝   ╚══════╝╚═╝╚══════╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
*/
--===== Code to find an index rebuild in the transaction log
     -- and when it occurred in relationship to the INSERTs.
 SELECT  [Current LSN]
        ,[Transaction Name]
   FROM sys.fn_dblog(NULL,NULL) 
  WHERE [Transaction Name] LIKE '%index%'
     OR [Transaction Name] LIKE '%INSERT%'
  ORDER BY [Current LSN]
;
