SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_remove_job_from_targets
  @job_id               UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name             sysname          = NULL,   -- Must provide either this or job_id
  @target_server_groups NVARCHAR(1024)   = NULL,   -- A comma-separated list of target server groups
  @target_servers       NVARCHAR(1024)   = NULL    -- A comma-separated list of target servers
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  EXECUTE @retval = sp_apply_job_to_targets @job_id,
                                            @job_name,
                                            @target_server_groups,
                                            @target_servers,
                                           'REMOVE'
  RETURN(@retval) -- 0 means success
END

GO
