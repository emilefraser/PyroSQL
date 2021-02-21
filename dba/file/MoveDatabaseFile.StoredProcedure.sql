-- SELECT THE OLD PATH 
SELECT name, physical_name AS NewLocation, state_desc AS OnlineStatus
FROM sys.master_files  
WHERE database_id = DB_ID(N'AcAzMetadataDB')  
GO

ALTER DATABASE AcAzMetadataDB SET OFFLINE;  
GO

-- File name: AcAzMetadataDB
-- New location: D:\Database\localdb\Meta



ALTER DATABASE AcAzMetadataDB   
    MODIFY FILE ( NAME = AcAzMetadataDB,   
                  FILENAME = 'D:\Database\localdb\Meta\AcAzMetadataDB.mdf');  
GO
 
ALTER DATABASE AcAzMetadataDB   
    MODIFY FILE ( NAME = AcAzMetadataDB_Log,   
                  FILENAME = 'D:\Database\localdb\Meta\AcAzMetadataDB_Log.ldf');  
GO


ALTER DATABASE AdventureWorks2014 SET ONLINE;  
GO

SELECT name, physical_name AS NewLocation, state_desc AS OnlineStatus
FROM sys.master_files  
WHERE database_id = DB_ID(N'AcAzMetadataDB')  
GO