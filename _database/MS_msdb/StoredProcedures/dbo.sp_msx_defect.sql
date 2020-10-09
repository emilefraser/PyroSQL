SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_msx_defect
  @forced_defection BIT = 0
AS
BEGIN
  DECLARE @current_msx_server sysname
  DECLARE @retval             INT
  DECLARE @jobs_deleted       INT
  DECLARE @polling_interval   INT
  DECLARE @nt_user            NVARCHAR(100)

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  SELECT @retval = 0
  SELECT @jobs_deleted = 0

  -- Get the current MSX server name from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @current_msx_server OUTPUT,
                                         N'no_output'

  SELECT @current_msx_server = UPPER(LTRIM(RTRIM(@current_msx_server)))
  IF ((@current_msx_server IS NULL) OR (@current_msx_server = N''))
  BEGIN
    RAISERROR(14298, -1, -1)
    RETURN(1) -- Failure
  END

  SELECT @nt_user = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))

  EXECUTE @retval = master.dbo.xp_msx_enlist 1, @current_msx_server, @nt_user

  IF (@retval <> 0) AND (@forced_defection = 0)
    RETURN(1) -- Failure

  -- Clear the MSXServerName registry entry
  EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                          N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                          N'MSXServerName',
                                          N'REG_SZ',
                                          N''

  -- Delete the MSXPollingInterval registry entry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXPollInterval',
                                         @polling_interval OUTPUT,
                                         N'no_output'
  IF (@polling_interval IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                  N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                  N'MSXPollInterval'

  -- Remove the entry from sqlagent_info
  DELETE FROM msdb.dbo.sqlagent_info
  WHERE (attribute = N'DateEnlisted')

  -- Delete all the jobs that originated from the MSX
  -- NOTE: We can't use sp_delete_job here since sp_delete_job checks if the caller is
  --       SQLServerAgent (only SQLServerAgent can delete non-local jobs).
  EXECUTE msdb.dbo.sp_delete_all_msx_jobs @current_msx_server, @jobs_deleted OUTPUT
  RAISERROR(14227, 0, 1, @current_msx_server, @jobs_deleted)

  -- Now delete the old msx server record
  DELETE msdb.dbo.sysoriginatingservers
  WHERE (originating_server = @current_msx_server)
    AND (master_server = 1)

  -- If a forced defection was performed, attempt to notify the MSXOperator
  IF (@forced_defection = 1)
  BEGIN
    DECLARE @network_address    NVARCHAR(100)
    DECLARE @command            NVARCHAR(512)
    DECLARE @local_machine_name sysname
    DECLARE @res_warning        NVARCHAR(300)

    SELECT @network_address = netsend_address
    FROM msdb.dbo.sysoperators
    WHERE (name = N'MSXOperator')

    IF (@network_address IS NOT NULL)
    BEGIN
      EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
      IF (@retval <> 0)
        RETURN(1) -- Failure
      SELECT @res_warning = FORMATMESSAGE(14217)
      SELECT @command = N'NET SEND ' + @network_address + N' ' + @res_warning
      SELECT @command = STUFF(@command, PATINDEX(N'%[%%]s%', @command), 2, NT_CLIENT())
      SELECT @command = STUFF(@command, PATINDEX(N'%[%%]s%', @command), 2, @local_machine_name)
      EXECUTE master.dbo.xp_cmdshell @command, no_output
    END
  END

  -- Delete the 'MSXOperator' (must do this last)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysoperators
              WHERE (name = N'MSXOperator')))
    EXECUTE msdb.dbo.sp_delete_operator @name = N'MSXOperator'

  RETURN(0) -- 0 means success
END

GO
