use master
GO
IF OBJECT_ID('[dbo].[sp_help_diskspace]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_diskspace] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
-- 2017-02-08 09:10:51.748 SFCCN\lizaguirre SFCCN\lizaguirre
-- Context: SUNPRDBI01 master
--#################################################################################################
CREATE PROCEDURE sp_help_diskspace
    AS
BEGIN
  SELECT 
    DISTINCT(volume_mount_point), 
    total_bytes/1048576 AS Size_in_MB, 
    (total_bytes/1048576) - (available_bytes/1048576) AS Used_in_MB,
    available_bytes/1048576 AS Free_in_MB,
        (total_bytes/1048576) / 1024 AS Size_in_GB, 
    (((total_bytes - available_bytes)/1048576) /1024) AS Used_in_GB,
    (available_bytes/1048576) / 1024 AS Free_in_GB
  FROM sys.master_files AS f 
  CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.FILE_ID)
  GROUP BY 
    volume_mount_point, 
    total_bytes,
    
    available_bytes 
  ORDER BY 1;
END;
GO