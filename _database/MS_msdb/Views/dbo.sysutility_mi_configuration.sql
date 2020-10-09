SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[sysutility_mi_configuration]
AS
    SELECT config.ucp_instance_name, config.mdw_database_name, t.upload_schema_version
    FROM 
    -- The upload_schema_version represents the contract between the UCP and MI for data upload
    -- Change this value when a breaking change with a (downlevel) UCP may be introduced in the MI
    -- upload code.
    (SELECT 100 AS upload_schema_version) t
    LEFT OUTER JOIN
    [dbo].[sysutility_mi_configuration_internal] config
    ON 1=1

GO
