SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_help_jobs_in_schedule
  @schedule_name       sysname  = NULL, -- Specify if @schedule_id is null
  @schedule_id         INT      = NULL  -- Specify if @schedule_name is null
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @retval   INT

  -- Check that we can uniquely identify the schedule. This only returns a schedule that is visible to this user
  EXECUTE @retval = msdb.dbo.sp_verify_schedule_identifiers @name_of_name_parameter = '@schedule_name',
                                                            @name_of_id_parameter   = '@schedule_id',
                                                            @schedule_name          = @schedule_name    OUTPUT,
                                                            @schedule_id            = @schedule_id      OUTPUT,
                                                            @owner_sid              = NULL,
                                                            @orig_server_id         = NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  EXECUTE @retval = msdb.dbo.sp_get_composite_job_info @schedule_id = @schedule_id
  IF (@retval <> 0)
    RETURN(1) -- Failure


  RETURN (0) -- 0 means success
END

GO
