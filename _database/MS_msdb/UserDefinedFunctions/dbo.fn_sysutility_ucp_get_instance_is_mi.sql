SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_instance_is_mi]()
RETURNS BIT
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @status BIT = (SELECT 
                            CASE  
                            WHEN ((ucp_instance_name IS NOT NULL) AND (mdw_database_name IS NOT NULL)) THEN CAST(1 AS BIT)
                            ELSE CAST(0 AS BIT)
                            END
                           FROM sysutility_mi_configuration_internal config)
    RETURN ISNULL(@status,0)
END	

GO
