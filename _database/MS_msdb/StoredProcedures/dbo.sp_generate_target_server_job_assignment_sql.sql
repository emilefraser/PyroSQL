SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_generate_target_server_job_assignment_sql
  @server_name     sysname = NULL,
  @new_server_name sysname = NULL  -- Use this if the target server computer has been renamed
AS
BEGIN
  SET NOCOUNT ON

  -- Change server name to always reflect real servername or servername\instancename
  IF (@server_name IS NULL) OR (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server_name = CONVERT(sysname, SERVERPROPERTY('ServerName'))

  IF (@server_name IS NOT NULL)
    SELECT @server_name = UPPER(@server_name)

  -- Verify the server name
  IF (@server_name <> UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))) AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers
                  WHERE (UPPER(server_name) = @server_name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers    sjs,
                   msdb.dbo.systargetservers sts
              WHERE (sjs.server_id = sts.server_id)
                AND (UPPER(sts.server_name) = @server_name)))
  BEGIN
    -- Generate the SQL
    SELECT 'Execute this SQL to re-assign jobs to the target server' =
           'EXECUTE msdb.dbo.sp_add_jobserver @job_id = ''' + CONVERT(VARCHAR(36), sjs.job_id) +
           ''', @server_name = ''' +  ISNULL(@new_server_name, sts.server_name) + ''''
    FROM msdb.dbo.sysjobservers    sjs,
         msdb.dbo.systargetservers sts
    WHERE (sjs.server_id = sts.server_id)
      AND (UPPER(sts.server_name) = @server_name)
  END
  ELSE
    RAISERROR(14548, 10, 1, @server_name)

  RETURN(0) -- Success
END

GO
