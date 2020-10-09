SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_mi_get_data_collector_status]()
   RETURNS BIT
AS
BEGIN
   RETURN 
   (
    SELECT CAST (ISNULL (parameter_value, 0) AS bit) 
       FROM [msdb].[dbo].[syscollector_config_store_internal]
       WHERE parameter_name = 'CollectorEnabled'
   );
END

GO
