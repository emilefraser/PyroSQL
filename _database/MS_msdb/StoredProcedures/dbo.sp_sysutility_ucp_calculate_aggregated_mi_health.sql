SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_aggregated_mi_health 
   @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN
       
    -- ManagedInstanceCount
    DECLARE @mi_count INT = 0
    SELECT @mi_count = COUNT(*) 
    FROM msdb.dbo.sysutility_ucp_mi_health_internal hs
    WHERE hs.set_number = @new_set_number

    -- ManagedInstanceOverUtilizeCount
    DECLARE @mi_over_utilize_count INT = 0
    SELECT @mi_over_utilize_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_mi_health_internal hs
    WHERE hs.set_number = @new_set_number AND
          (0 != hs.is_volume_space_over_utilized OR
           0 != hs.is_computer_processor_over_utilized OR
           0 != hs.is_file_space_over_utilized OR
           0 != hs.is_mi_processor_over_utilized)
           
    -- ManagedInstanceUnderUtilizeCount
    DECLARE @mi_under_utilize_count INT = 0
    SELECT @mi_under_utilize_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_mi_health_internal hs
    WHERE hs.set_number = @new_set_number AND
          (0 != hs.is_volume_space_under_utilized OR
           0 != hs.is_computer_processor_under_utilized OR
           0 != hs.is_file_space_under_utilized OR
           0 != hs.is_mi_processor_under_utilized)
           AND 0 = hs.is_volume_space_over_utilized
           AND 0 = hs.is_computer_processor_over_utilized
           AND 0 = hs.is_file_space_over_utilized
           AND 0 = hs.is_mi_processor_over_utilized	           
    	   
    -- ManagedInstanceUnhealthyCount
    DECLARE @mi_unhealthy_count INT = 0
    SELECT @mi_unhealthy_count = @mi_over_utilize_count + @mi_under_utilize_count

    -- ManagedInstanceHealthyCount
    DECLARE @mi_healthy_count INT = 0
    SELECT @mi_healthy_count = COUNT(*)
    FROM msdb.dbo.sysutility_ucp_mi_health_internal hs
    WHERE hs.set_number = @new_set_number
    AND 0 = hs.is_volume_space_under_utilized
    AND 0 = hs.is_computer_processor_under_utilized
    AND 0 = hs.is_file_space_under_utilized
    AND 0 = hs.is_mi_processor_under_utilized
    AND 0 = hs.is_volume_space_over_utilized
    AND 0 = hs.is_computer_processor_over_utilized
    AND 0 = hs.is_file_space_over_utilized
    AND 0 = hs.is_mi_processor_over_utilized

    -- Insert new record
    INSERT INTO msdb.dbo.sysutility_ucp_aggregated_mi_health_internal(set_number
           , mi_count
           , mi_healthy_count
           , mi_unhealthy_count
           , mi_over_utilize_count
           , mi_under_utilize_count
           , mi_on_over_utilized_computer_count
           , mi_on_under_utilized_computer_count
           , mi_with_files_on_over_utilized_volume_count
           , mi_with_files_on_under_utilized_volume_count
           , mi_with_over_utilized_file_count
           , mi_with_under_utilized_file_count
           , mi_with_over_utilized_processor_count
           , mi_with_under_utilized_processor_count)
    SELECT @new_set_number
            , @mi_count 
            , @mi_healthy_count 
            , @mi_unhealthy_count 
            , @mi_over_utilize_count 
            , @mi_under_utilize_count 
            , ISNULL(SUM(CASE WHEN 0 < hs.is_computer_processor_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_computer_processor_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_volume_space_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_volume_space_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_file_space_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_file_space_under_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_mi_processor_over_utilized THEN 1 ELSE 0 END), 0)
            , ISNULL(SUM(CASE WHEN 0 < hs.is_mi_processor_under_utilized THEN 1 ELSE 0 END), 0)
    FROM msdb.dbo.sysutility_ucp_mi_health_internal hs 
    WHERE hs.set_number = @new_set_number
END

GO
