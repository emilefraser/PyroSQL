SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_file_space_utilization_history]( 
   @object_type TINYINT, 
   @virtual_server_name SYSNAME, 
   @volume_device_id SYSNAME, 
   @server_instance_name SYSNAME, 
   @database_name SYSNAME, 
   @filegroup_name SYSNAME, 
   @database_file_name SYSNAME,
   @start_time DATETIMEOFFSET(7),
   @end_time DATETIMEOFFSET(7),
   @aggregation_interval TINYINT
   )
RETURNS TABLE AS RETURN (
    SELECT	CASE WHEN ISNULL(total_space_bytes, 0) = 0 THEN 0 ELSE (used_space_bytes * 100)/total_space_bytes END AS storage_utilization_percent,
		    CONVERT(BIGINT, used_space_bytes) AS storage_utilization_in_bytes, 
		    CONVERT(BIGINT, ISNULL(total_space_bytes, 0)) AS storage_capacity_in_bytes, 
		    processing_time as sample_time
    FROM dbo.syn_sysutility_ucp_space_utilization 
    WHERE @object_type = object_type AND
          @aggregation_interval = aggregation_type AND
          (processing_time BETWEEN @start_time AND @end_time) AND
          ISNULL(@virtual_server_name, '') = virtual_server_name AND
          ISNULL(@volume_device_id, '') = volume_device_id AND
          ISNULL(@server_instance_name, '') = server_instance_name AND
          ISNULL(@database_name, '') = database_name AND
          ISNULL(@filegroup_name, '') = [filegroup_name] AND
          ISNULL(@database_file_name, '') = [dbfile_name] 
    )       

GO
