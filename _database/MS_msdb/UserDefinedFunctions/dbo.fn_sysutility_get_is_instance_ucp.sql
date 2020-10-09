SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[fn_sysutility_get_is_instance_ucp]()
RETURNS BIT 
AS
BEGIN
   RETURN (
      SELECT 
         CASE 
            WHEN ISNULL ((SELECT CAST (current_value as sysname) FROM msdb.dbo.sysutility_ucp_configuration_internal WHERE name = 'UtilityName'), '') = ''
            THEN 0
            ELSE 1
         END)
END;

GO
