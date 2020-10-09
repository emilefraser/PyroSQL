SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_set_local_time
  @server_name           sysname = NULL,
  @adjustment_in_minutes INT          = 0 -- Only needed for Win9x
AS
BEGIN
  DECLARE @ret              INT
  DECLARE @local_time       INT
  DECLARE @local_date       INT
  DECLARE @current_datetime DATETIME
  DECLARE @local_time_sz    VARCHAR(30)
  DECLARE @cmd              NVARCHAR(200)
  DECLARE @date_format      NVARCHAR(64)
  DECLARE @year_sz          NVARCHAR(16)
  DECLARE @month_sz         NVARCHAR(16)
  DECLARE @day_sz           NVARCHAR(16)

  -- Synchronize the clock with the remote server (if supplied)
  -- NOTE: NT takes timezones into account, whereas Win9x does not
  IF (@server_name IS NOT NULL)
  BEGIN
    -- Sanitize the input string so it is ready to be passed to the shell
    -- Same logic as in sys.fn_escapecmdshellsymbolsremovequotes in REPL.
    DECLARE @escaped_command_string NVARCHAR(4000), @curr_char NVARCHAR(1), @curr_char_index INT
    SELECT @escaped_command_string = N'', @curr_char = N'', @curr_char_index = 1
    WHILE @curr_char_index <= len(@server_name)
    BEGIN
      SELECT @curr_char = substring(@server_name, @curr_char_index, 1)
      IF @curr_char in (N'%', N'<', N'>', N'|', N'&', N'^')
      BEGIN
        SELECT @escaped_command_string = @escaped_command_string + N'^'
      END

      IF @curr_char <> '"'
      BEGIN
        SELECT @escaped_command_string = @escaped_command_string + @curr_char
      END
      SELECT @curr_char_index = @curr_char_index + 1
    END

    SELECT @cmd = N'net time "\\' + @escaped_command_string collate database_default + N'" /set /y'
    EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
    IF (@ret <> 0)
      RETURN(1) -- Failure
  END

  -- Since NET TIME on Win9x does not take time zones into account we need to manually adjust
  -- for this using @adjustment_in_minutes which will be the difference between the MSX GMT
  -- offset and the target server GMT offset
  IF ((PLATFORM() & 0x2) = 0x2) -- Win9x
  BEGIN
    -- Get the date format from the registry (so that we can construct our DATE command-line command)
    EXECUTE master.dbo.xp_regread N'HKEY_CURRENT_USER',
                                  N'Control Panel\International',
                                  N'sShortDate',
                                  @date_format OUTPUT,
                                  N'no_output'
    SELECT @date_format = LOWER(@date_format)

    IF (@adjustment_in_minutes <> 0)
    BEGIN
      -- Wait for SQLServer to re-cache the OS time
      WAITFOR DELAY '00:01:00'

      SELECT @current_datetime = DATEADD(mi, @adjustment_in_minutes, GETDATE())
      SELECT @local_time_sz = SUBSTRING(CONVERT(VARCHAR, @current_datetime, 8), 1, 5)
      SELECT @local_time = CONVERT(INT, LTRIM(SUBSTRING(@local_time_sz, 1, PATINDEX('%:%', @local_time_sz) - 1)  + SUBSTRING(@local_time_sz, PATINDEX('%:%', @local_time_sz) + 1, 2)))
      SELECT @local_date = CONVERT(INT, CONVERT(VARCHAR, @current_datetime, 112))

      -- Set the date
      SELECT @year_sz = CONVERT(NVARCHAR, @local_date / 10000)
      SELECT @month_sz = CONVERT(NVARCHAR, (@local_date % 10000) / 100)
      SELECT @day_sz = CONVERT(NVARCHAR, @local_date % 100)

      IF (@date_format LIKE N'y%m%d')
        SELECT @cmd = N'DATE ' + @year_sz + N'-' + @month_sz + N'-' + @day_sz
      IF (@date_format LIKE N'y%d%m')
        SELECT @cmd = N'DATE ' + @year_sz + N'-' + @day_sz + N'-' + @month_sz
      IF (@date_format LIKE N'm%d%y')
        SELECT @cmd = N'DATE ' + @month_sz + N'-' + @day_sz + N'-' + @year_sz
      IF (@date_format LIKE N'd%m%y')
        SELECT @cmd = N'DATE ' + @day_sz + N'-' + @month_sz + N'-' + @year_sz

      EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
      IF (@ret <> 0)
        RETURN 1 -- Failure

      -- Set the time (NOTE: We can't set the millisecond part of the time, so we may be up to .999 sec off)
      SELECT @cmd = N'TIME ' + CONVERT(NVARCHAR, @local_time / 100) + N':' + CONVERT(NVARCHAR, @local_time % 100) + ':' + CONVERT(NVARCHAR(2), DATEPART(SS, GETDATE()))
      EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
      IF (@ret <> 0)
        RETURN 1 -- Failure
    END

  END

  RETURN(0) -- Success
END

GO
