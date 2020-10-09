SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_targetserver
  @server_name sysname = NULL
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = UPPER(LTRIM(RTRIM(@server_name)))

  IF (@server_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers
                    WHERE (UPPER(server_name) = @server_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END

  DECLARE @unread_instructions TABLE
  (
  target_server       sysname COLLATE database_default,
  unread_instructions INT
  )

  INSERT INTO @unread_instructions
  SELECT target_server, COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (status = 0)
  GROUP BY target_server

  SELECT sts.server_id,
         sts.server_name,
         sts.location,
         sts.time_zone_adjustment,
         sts.enlist_date,
         sts.last_poll_date,
        'status' = sts.status |
                   CASE WHEN DATEDIFF(ss, sts.last_poll_date, GETDATE()) > (3 * sts.poll_interval) THEN 0x2 ELSE 0 END |
                   CASE WHEN ((SELECT COUNT(*)
                               FROM msdb.dbo.sysdownloadlist sdl
                               WHERE (sdl.target_server = sts.server_name)
                                 AND (sdl.error_message IS NOT NULL)) > 0) THEN 0x4 ELSE 0 END,
        'unread_instructions' = ISNULL(ui.unread_instructions, 0),
        'local_time' = DATEADD(SS, DATEDIFF(SS, sts.last_poll_date, GETDATE()), sts.local_time_at_last_poll),
        sts.enlisted_by_nt_user,
        sts.poll_interval
  FROM msdb.dbo.systargetservers sts LEFT OUTER JOIN
       @unread_instructions      ui  ON (sts.server_name = ui.target_server)
  WHERE ((@server_name IS NULL) OR (UPPER(sts.server_name) = @server_name))
  ORDER BY server_name

  RETURN(@@error) -- 0 means success
END

GO
