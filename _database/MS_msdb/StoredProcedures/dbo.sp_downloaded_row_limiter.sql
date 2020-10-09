SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_downloaded_row_limiter
  @server_name sysname -- Target server name
AS
BEGIN
  -- This trigger controls how many downloaded (status = 1) sysdownloadlist rows exist
  -- for any given server.  It does NOT control the absolute number of rows in the table.

  DECLARE @current_rows_per_server INT
  DECLARE @max_rows_per_server     INT -- This value comes from the resgistry (DownloadedMaxRows)
  DECLARE @rows_to_delete          INT
  DECLARE @quoted_server_name      NVARCHAR(514) -- enough room to accomodate the quoted name
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  -- Check the server name (if it's bad we fail silently)
  IF (@server_name IS NULL) OR
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysdownloadlist
                  WHERE (target_server = @server_name)))
    RETURN(1) -- Failure

  SELECT @max_rows_per_server = 0

  -- Get the max-rows-per-server from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'DownloadedMaxRows',
                                         @max_rows_per_server OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysdownloadlist rows
  IF (ISNULL(@max_rows_per_server, -1) = -1)
    RETURN

  -- Check that max_rows_per_server is >= 0
  IF (@max_rows_per_server < -1)
  BEGIN
    -- It isn't, so default to 100 rows
    SELECT @max_rows_per_server = 100
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'DownloadedMaxRows',
                                            N'REG_DWORD',
                                            @max_rows_per_server
  END

  -- Get the number of downloaded rows in sysdownloadlist for the target server in question
  -- NOTE: Determining this [quickly] requires a [non-clustered] index on target_server
  SELECT @current_rows_per_server = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (status = 1)

  -- Delete the oldest downloaded row(s) for the target server in question if the new row has
  -- pushed us over the per-server row limit
  SELECT @rows_to_delete = @current_rows_per_server - @max_rows_per_server
  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysdownloadlist
      WHERE (target_server = @server_name)
        AND (status = 1)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END
END

GO
