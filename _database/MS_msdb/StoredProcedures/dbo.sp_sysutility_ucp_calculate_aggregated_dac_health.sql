SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_aggregated_dac_health 
   @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN
       
    -- DacCount
    DECLARE @dac_count INT = 0
    SELECT @dac_count = COUNT(*) 
    FROM msdb.dbo.sysutility_ucp_dac_health_internal hs
    WHERE hs.set_number = @new_set_number

    -- DacOverUtilizeCount
    DECLARE @dac_over_utilize_count INT = 0
    SELECT @dac_over_utilize_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_dac_health_internal hs
    WHERE hs.set_number = @new_set_number AND
          (0 != hs.is_dac_processor_over_utilized OR
           0 != hs.is_computer_processor_over_utilized OR
           0 != hs.is_file_space_over_utilized OR
           0 != hs.is_volume_space_over_utilized)

    -- DacUnderUtilizeCount
    DECLARE @dac_under_utilize_count INT = 0
    SELECT @dac_under_utilize_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_dac_health_internal hs
    WHERE hs.set_number = @new_set_number AND
          (0 != hs.is_dac_processor_under_utilized OR
           0 != hs.is_computer_processor_under_utilized OR
           0 != hs.is_file_space_under_utilized OR
           0 != hs.is_volume_space_under_utilized)
           AND 0 = hs.is_dac_processor_over_utilized 
           AND 0 = hs.is_computer_processor_over_utilized 
           AND 0 = hs.is_file_space_over_utilized 
           AND 0 = hs.is_volume_space_over_utilized
    	   
    -- DacUnhealthyCount
    DECLARE @dac_unhealthy_count INT = 0
    SELECT @dac_unhealthy_count = @dac_over_utilize_count + @dac_under_utilize_count;

    -- DacHealthyCount
    DECLARE @dac_healthy_count INT = 0
    SELECT @dac_healthy_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_dac_health_internal hs
    WHERE hs.set_number = @new_set_number 
    AND 0 = hs.is_dac_processor_under_utilized 
    AND 0 = hs.is_computer_processor_under_utilized 
    AND 0 = hs.is_file_space_under_utilized 
    AND 0 = hs.is_volume_space_under_utilized
    AND 0 = hs.is_dac_processor_over_utilized 
    AND 0 = hs.is_computer_processor_over_utilized 
    AND 0 = hs.is_file_space_over_utilized 
    AND 0 = hs.is_volume_space_over_utilized        

    -- Insert new record
    INSERT INTO msdb.dbo.sysutility_ucp_aggregated_dac_health_internal(set_number
            , dac_count
            , dac_healthy_count
            , dac_unhealthy_count
            , dac_over_utilize_count
            , dac_under_utilize_count
            , dac_on_over_utilized_computer_count
            , dac_on_under_utilized_computer_count
            , dac_with_files_on_over_utilized_volume_count
            , dac_with_files_on_under_utilized_volume_count
            , dac_with_over_utilized_file_count
            , dac_with_under_utilized_file_count
            , dac_with_over_utilized_processor_count
            , dac_with_under_utilized_processor_count)
    SELECT @new_set_number
            , @dac_count 
            , @dac_healthy_count 
            , @dac_unhealthy_count 
            , @dac_over_utilize_count 
            , @dac_under_utilize_count 
            , ISNULL(SUM(CASE WHEN 0 < hs.is_computer_processor_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_computer_processor_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_volume_space_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_volume_space_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_file_space_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_file_space_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_dac_processor_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_dac_processor_under_utilized THEN 1 ELSE 0 END), 0)
    FROM msdb.dbo.sysutility_ucp_dac_health_internal hs   
    WHERE hs.set_number = @new_set_number       

END

GO
