SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_mi_get_batch_manifest]()
RETURNS TABLE
AS
RETURN
(
    -- DAC execution statistics row count
    SELECT N'dac_packages_row_count' AS parameter_name
    , CONVERT(SQL_VARIANT, COUNT(*)) AS parameter_value
    FROM [msdb].[dbo].[sysutility_mi_dac_execution_statistics_internal] 

    UNION ALL
    
    -- MI CPU and memory configurations row count
    SELECT N'cpu_memory_configurations_row_count' AS parameter_name
    , CONVERT(SQL_VARIANT, COUNT(*)) AS parameter_value
    FROM [msdb].[dbo].[sysutility_mi_cpu_stage_internal]

    UNION ALL

    -- MI volumes row count
    SELECT N'volumes_row_count' AS parameter_name
    , CONVERT(SQL_VARIANT, COUNT(*)) AS parameter_value 
    FROM [msdb].[dbo].[sysutility_mi_volumes_stage_internal]

    UNION ALL
    
    -- SMO properties row count
    SELECT N'smo_properties_row_count' AS parameter_name
    , CONVERT(SQL_VARIANT, COUNT(*)) AS parameter_value 
    FROM [msdb].[dbo].[sysutility_mi_smo_stage_internal]
)

GO
