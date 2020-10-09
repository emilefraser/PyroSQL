SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_cpu_utilization_history]( 
   @object_type TINYINT, 
   @physical_server_name SYSNAME, 
   @server_instance_name SYSNAME, 
   @dac_name SYSNAME,
   @start_time DATETIMEOFFSET(7),
   @end_time DATETIMEOFFSET(7),
   @aggregation_interval TINYINT
   )
RETURNS TABLE 
AS
RETURN (	
    SELECT percent_total_cpu_utilization AS processor_utilization_percent, 
           processing_time AS sample_time
    FROM dbo.syn_sysutility_ucp_cpu_utilization 
    WHERE @object_type = object_type AND
          @aggregation_interval = aggregation_type AND
          (processing_time BETWEEN @start_time AND @end_time) AND
          ISNULL(@physical_server_name, '') = physical_server_name AND
          ISNULL(@server_instance_name, '') = server_instance_name AND
          ISNULL(@dac_name, '') = database_name
    )

GO
