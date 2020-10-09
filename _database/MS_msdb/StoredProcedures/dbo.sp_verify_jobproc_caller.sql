SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_jobproc_caller
  @job_id       UNIQUEIDENTIFIER,
  @program_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @program_name = LTRIM(RTRIM(@program_name))

  IF (EXISTS (SELECT    *
              FROM      msdb.dbo.sysjobs_view
              WHERE     (job_id = @job_id)
              AND       (master_server = 1) )) -- master_server = 1 filters on MSX jobs in this TSX server
              AND       (PROGRAM_NAME() NOT LIKE @program_name)
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  RETURN(0)
END

GO
