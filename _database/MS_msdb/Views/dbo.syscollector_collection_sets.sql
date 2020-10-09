SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syscollector_collection_sets]
AS
    SELECT 
        s.collection_set_id,
        s.collection_set_uid,
        CASE 
            WHEN s.name_id IS NULL THEN s.name 
            ELSE FORMATMESSAGE(s.name_id)
        END AS name,        
        s.target,
        s.is_system,
        s.is_running,
        s.collection_mode,
        s.proxy_id,
        s.schedule_uid,
        s.collection_job_id,
        s.upload_job_id,
        s.logging_level,
        s.days_until_expiration,
        CASE 
            WHEN s.description_id IS NULL THEN s.description
            ELSE FORMATMESSAGE(s.description_id)
        END AS description,
        s.dump_on_any_error,
        s.dump_on_codes
    FROM 
        [dbo].[syscollector_collection_sets_internal] AS s

GO
