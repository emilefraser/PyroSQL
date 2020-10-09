SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_replication_job_parameter
  @job_id        UNIQUEIDENTIFIER,
  @old_freq_type INT,
  @new_freq_type INT
AS
BEGIN
  DECLARE @category_id INT
  DECLARE @pattern     NVARCHAR(50)
  DECLARE @patternidx  INT
  DECLARE @cmdline     NVARCHAR(3200)
  DECLARE @step_id     INT

  SET NOCOUNT ON
  SELECT @pattern = N'%[-/][Cc][Oo][Nn][Tt][Ii][Nn][Uu][Oo][Uu][Ss]%'

  -- Make sure that we are dealing with relevant replication jobs
  SELECT @category_id = category_id
  FROM msdb.dbo.sysjobs
  WHERE (@job_id = job_id)

  -- @category_id = 10 (REPL-Distribution), 13 (REPL-LogReader), 14 (REPL-Merge),
  --  19 (REPL-QueueReader)
  IF @category_id IN (10, 13, 14, 19)
  BEGIN
    -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
    IF (SERVERPROPERTY('EngineEdition') = 8 AND @new_freq_type = 0x80)
    BEGIN
      RAISERROR(41914, -1, 18, 'Schedule job ONIDLE')
      RETURN(1) -- Failure
    END
    -- Adding the -Continuous parameter (non auto-start to auto-start)
    IF ((@old_freq_type <> 0x40) AND (@new_freq_type = 0x40))
    BEGIN
      -- Use a cursor to handle multiple replication agent job steps
      DECLARE step_cursor CURSOR LOCAL FOR
      SELECT command, step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (@job_id = job_id)
        AND (UPPER(subsystem collate SQL_Latin1_General_CP1_CS_AS) IN (N'MERGE', N'LOGREADER', N'DISTRIBUTION', N'QUEUEREADER'))
      OPEN step_cursor
      FETCH step_cursor INTO @cmdline, @step_id

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
        SELECT @patternidx = PATINDEX(@pattern, @cmdline)
        -- Make sure that the -Continuous parameter has not been specified already
        IF (@patternidx = 0)
        BEGIN
          SELECT @cmdline = @cmdline + N' -Continuous'
          UPDATE msdb.dbo.sysjobsteps
          SET command = @cmdline
          WHERE (@job_id = job_id)
            AND (@step_id = step_id)
        END -- IF (@patternidx = 0)
        FETCH NEXT FROM step_cursor into @cmdline, @step_id
      END -- WHILE (@@FETCH_STATUS <> -1)
      CLOSE step_cursor
      DEALLOCATE step_cursor
    END -- IF ((@old_freq_type...
    -- Removing the -Continuous parameter (auto-start to non auto-start)
    ELSE
    IF ((@old_freq_type = 0x40) AND (@new_freq_type <> 0x40))
    BEGIN
      DECLARE step_cursor CURSOR LOCAL FOR
      SELECT command, step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (@job_id = job_id)
        AND (UPPER(subsystem collate SQL_Latin1_General_CP1_CS_AS) IN (N'MERGE', N'LOGREADER', N'DISTRIBUTION', N'QUEUEREADER'))
      OPEN step_cursor
      FETCH step_cursor INTO @cmdline, @step_id

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
        SELECT @patternidx = PATINDEX(@pattern, @cmdline)
        IF (@patternidx <> 0)
        BEGIN
          -- Handle multiple instances of -Continuous in the commandline
          WHILE (@patternidx <> 0)
          BEGIN
            SELECT @cmdline = STUFF(@cmdline, @patternidx, 11, N'')
            IF (@patternidx > 1)
            BEGIN
              -- Remove the preceding space if -Continuous does not start at the beginning of the commandline
              SELECT @cmdline = stuff(@cmdline, @patternidx - 1, 1, N'')
            END
            SELECT @patternidx = PATINDEX(@pattern, @cmdline)
          END -- WHILE (@patternidx <> 0)
          UPDATE msdb.dbo.sysjobsteps
          SET command = @cmdline
          WHERE (@job_id = job_id)
            AND (@step_id = step_id)
        END -- IF (@patternidx <> -1)
        FETCH NEXT FROM step_cursor INTO @cmdline, @step_id
      END -- WHILE (@@FETCH_STATUS <> -1)
      CLOSE step_cursor
      DEALLOCATE step_cursor
    END -- ELSE IF ((@old_freq_type = 0x40)...
  END -- IF @category_id IN (10, 13, 14)

  RETURN 0
END

GO
