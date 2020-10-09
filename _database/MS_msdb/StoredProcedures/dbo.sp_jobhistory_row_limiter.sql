SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT

  SET NOCOUNT ON

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory with (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      WHERE (job_id = @job_id)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END

GO
