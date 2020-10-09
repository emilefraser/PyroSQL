SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[sysdac_instances]
AS
    SELECT
        -- this must be locked down because we use instance_id visability as a security gate
        case 
            when (dbo.fn_sysdac_is_currentuser_sa() = 1) then dac_instances.instance_id
            when sd.owner_sid = SUSER_SID() then dac_instances.instance_id
            else NULL
        end as instance_id,
        dac_instances.instance_name,
        dac_instances.type_name,
        dac_instances.type_version,
        dac_instances.description,
        case 
            when (dbo.fn_sysdac_is_currentuser_sa() = 1) then dac_instances.type_stream
            when sd.owner_sid = SUSER_SID() then dac_instances.type_stream
            else NULL
        end as type_stream,
        dac_instances.date_created,
        dac_instances.created_by,
        dac_instances.instance_name as database_name
    FROM sysdac_instances_internal dac_instances
    LEFT JOIN sys.databases sd
		ON dac_instances.instance_name = sd.name

GO
