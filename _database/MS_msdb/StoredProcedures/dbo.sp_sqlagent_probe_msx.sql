SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_probe_msx
  @server_name          sysname,  -- The name of the target server probing the MSX
  @local_time           NVARCHAR(100), -- The local time at the target server in the format YYYY/MM/DD HH:MM:SS
  @poll_interval        INT,           -- The frequency (in seconds) with which the target polls the MSX
  @time_zone_adjustment INT = NULL     -- The offset from GMT in minutes (may be NULL if unknown)
AS
BEGIN
  DECLARE @bad_enlistment        BIT
  DECLARE @blocking_instructions INT
  DECLARE @pending_instructions  INT

  SET NOCOUNT ON

  SELECT @server_name = UPPER(@server_name)
  SELECT @bad_enlistment = 0, @blocking_instructions = 0, @pending_instructions = 0

  UPDATE msdb.dbo.systargetservers
  SET last_poll_date = GETDATE(),
      local_time_at_last_poll = CONVERT(DATETIME, @local_time, 111),
      poll_interval = @poll_interval,
      time_zone_adjustment = ISNULL(@time_zone_adjustment, time_zone_adjustment)
  WHERE (UPPER(server_name) = @server_name)

  -- If the systargetservers entry is missing (and no DEFECT instruction has been posted)
  -- then the enlistment is bad
  IF (NOT EXISTS (SELECT 1
                  FROM msdb.dbo.systargetservers
                  WHERE (UPPER(server_name) = @server_name))) AND
     (NOT EXISTS (SELECT 1
                  FROM msdb.dbo.sysdownloadlist
                  WHERE (target_server = @server_name)
                    AND (operation_code = 7)
                    AND (object_type = 2)))
    SELECT @bad_enlistment = 1

  SELECT @blocking_instructions = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (error_message IS NOT NULL)

  SELECT @pending_instructions = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (error_message IS NULL)
    AND (status = 0)

  SELECT @bad_enlistment, @blocking_instructions, @pending_instructions
END

GO
