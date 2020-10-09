SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_apply_job_to_targets
  @job_id               UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name             sysname          = NULL,   -- Must provide either this or job_id
  @target_server_groups NVARCHAR(2048)   = NULL,   -- A comma-separated list of target server groups
  @target_servers       NVARCHAR(2048)   = NULL,   -- An comma-separated list of target servers
  @operation            VARCHAR(7)       = 'APPLY' -- Or 'REMOVE'
AS
BEGIN
  DECLARE @retval        INT
  DECLARE @rows_affected INT
  DECLARE @server_name   sysname
  DECLARE @groups        NVARCHAR(2048)
  DECLARE @group         sysname
  DECLARE @servers       NVARCHAR(2048)
  DECLARE @server        sysname
  DECLARE @pos_of_comma  INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @target_server_groups = LTRIM(RTRIM(@target_server_groups))
  SELECT @target_servers       = UPPER(LTRIM(RTRIM(@target_servers)))
  SELECT @operation            = LTRIM(RTRIM(@operation))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@target_server_groups = NULL) SELECT @target_server_groups = NULL
  IF (@target_servers       = NULL) SELECT @target_servers = NULL
  IF (@operation            = NULL) SELECT @operation = NULL

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operation type
  IF ((@operation <> 'APPLY') AND (@operation <> 'REMOVE'))
  BEGIN
    RAISERROR(14266, -1, -1, '@operation', 'APPLY, REMOVE')
    RETURN(1) -- Failure
  END

  -- Check that we have a target server group list and/or a target server list
  IF ((@target_server_groups IS NULL) AND (@target_servers IS NULL))
  BEGIN
    RAISERROR(14283, -1, -1)
    RETURN(1) -- Failure
  END

  DECLARE @temp_groups TABLE (group_name sysname COLLATE database_default NOT NULL)
  DECLARE @temp_server_name TABLE (server_name sysname COLLATE database_default NOT NULL)

  -- Parse the Target Server comma-separated list (if supplied)
  IF (@target_servers IS NOT NULL)
  BEGIN
    SELECT @servers = @target_servers
    SELECT @pos_of_comma = CHARINDEX(N',', @servers)
    WHILE (@pos_of_comma <> 0)
    BEGIN
      SELECT @server = SUBSTRING(@servers, 1, @pos_of_comma - 1)
      INSERT INTO @temp_server_name (server_name) VALUES (LTRIM(RTRIM(@server)))
      SELECT @servers = RIGHT(@servers, (DATALENGTH(@servers) / 2) - @pos_of_comma)
      SELECT @pos_of_comma = CHARINDEX(N',', @servers)
    END
    INSERT INTO @temp_server_name (server_name) VALUES (LTRIM(RTRIM(@servers)))
  END

  -- Parse the Target Server Groups comma-separated list
  IF (@target_server_groups IS NOT NULL)
  BEGIN
    SELECT @groups = @target_server_groups
    SELECT @pos_of_comma = CHARINDEX(N',', @groups)
    WHILE (@pos_of_comma <> 0)
    BEGIN
      SELECT @group = SUBSTRING(@groups, 1, @pos_of_comma - 1)
      INSERT INTO @temp_groups (group_name) VALUES (LTRIM(RTRIM(@group)))
      SELECT @groups = RIGHT(@groups, (DATALENGTH(@groups) / 2) - @pos_of_comma)
      SELECT @pos_of_comma = CHARINDEX(N',', @groups)
    END
    INSERT INTO @temp_groups (group_name) VALUES (LTRIM(RTRIM(@groups)))
  END

  -- Check server groups
  SET ROWCOUNT 1 -- We do this so that we catch the FIRST invalid group
  SELECT @group = NULL
  SELECT @group = group_name
  FROM @temp_groups
  WHERE group_name NOT IN (SELECT name
                           FROM msdb.dbo.systargetservergroups)
  IF (@group IS NOT NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@target_server_groups', @group)
    RETURN(1) -- Failure
  END
  SET ROWCOUNT 0

  -- Find the distinct list of servers being targeted
  INSERT INTO @temp_server_name (server_name)
  SELECT DISTINCT sts.server_name
  FROM msdb.dbo.systargetservergroups       stsg,
       msdb.dbo.systargetservergroupmembers stsgm,
       msdb.dbo.systargetservers            sts
  WHERE (stsg.name IN (SELECT group_name FROM @temp_groups))
    AND (stsg.servergroup_id = stsgm.servergroup_id)
    AND (stsgm.server_id = sts.server_id)
    AND (UPPER(sts.server_name) NOT IN (SELECT server_name
                                        FROM @temp_server_name))

  IF (@operation = 'APPLY')
  BEGIN
    -- Remove those servers to which the job has already been applied
    DELETE FROM @temp_server_name
    WHERE server_name IN (SELECT sts.server_name
                          FROM msdb.dbo.sysjobservers    sjs,
                               msdb.dbo.systargetservers sts
                          WHERE (sjs.job_id = @job_id)
                            AND (sjs.server_id = sts.server_id))
  END

  IF (@operation = 'REMOVE')
  BEGIN
    -- Remove those servers to which the job is not currently applied
    DELETE FROM @temp_server_name
    WHERE server_name NOT IN (SELECT sts.server_name
                              FROM msdb.dbo.sysjobservers    sjs,
                                   msdb.dbo.systargetservers sts
                              WHERE (sjs.job_id = @job_id)
                                AND (sjs.server_id = sts.server_id))
  END

  SELECT @rows_affected = COUNT(*)
  FROM @temp_server_name

  SET ROWCOUNT 1
  WHILE (EXISTS (SELECT *
                 FROM @temp_server_name))
  BEGIN
    SELECT @server_name = server_name
    FROM @temp_server_name
    IF (@operation = 'APPLY')
      EXECUTE sp_add_jobserver @job_id = @job_id, @server_name = @server_name
    ELSE
    IF (@operation = 'REMOVE')
      EXECUTE sp_delete_jobserver @job_id = @job_id, @server_name = @server_name
    DELETE FROM @temp_server_name
    WHERE (server_name = @server_name)
  END
  SET ROWCOUNT 0

  IF (@operation = 'APPLY')
    RAISERROR(14240, 0, 1, @rows_affected)
  IF (@operation = 'REMOVE')
    RAISERROR(14241, 0, 1, @rows_affected)

  RETURN(0) -- Success
END

GO
