IF OBJECT_ID('[dbo].[sp_help_diskspeed]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_diskspeed] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility procedure added by Lowell, used in SQL Server Management Studio 
--Purpose: find slow reads and writes on a per db/disk according to virtual stats
--exec sp_count
--#################################################################################################
CREATE PROCEDURE sp_help_diskspeed
AS
  BEGIN
      SELECT ( fs.io_stall_read_ms / ( 1.0 + fs.num_of_reads ) ) AS AverageReadsOver100ms,
             Db_name(fs.database_id) AS dbname,
             mf.NAME,
             fs.file_id,
             db_file_type = CASE
                              WHEN fs.file_id = 2 THEN 'Log'
                              ELSE 'Data'
                            END,
             Upper(Substring(mf.physical_name, 1, 2)) AS disk_location
      FROM   sys.dm_io_virtual_file_stats (NULL, NULL) fs
             JOIN sys.master_files mf
               ON fs.file_id = mf.file_id
                  AND fs.database_id = mf.database_id
      WHERE  ( fs.io_stall_read_ms / ( 1.0 + fs.num_of_reads ) ) > 100

      SELECT ( fs.io_stall_write_ms / ( 1.0 + fs.num_of_writes ) ) AS AverageWritesOver20ms,
             Db_name(fs.database_id) AS dbname,
             mf.NAME,
             fs.file_id,
             db_file_type = CASE
                              WHEN fs.file_id = 2 THEN 'Log'
                              ELSE 'Data'
                            END,
             Upper(Substring(mf.physical_name, 1, 2)) AS disk_location
      FROM   sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
             INNER JOIN sys.master_files AS mf
                     ON fs.database_id = mf.database_id
                        AND fs.[file_id] = mf.[file_id]
      WHERE  ( fs.io_stall_write_ms / ( 1.0 + fs.num_of_writes ) ) > 20;
  END --PROC

