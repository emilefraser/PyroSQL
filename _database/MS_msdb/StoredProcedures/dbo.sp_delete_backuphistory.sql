SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE sp_delete_backuphistory
  @oldest_date datetime
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @backup_set_id TABLE      (backup_set_id INT)
  DECLARE @media_set_id TABLE       (media_set_id INT)
  DECLARE @restore_history_id TABLE (restore_history_id INT)

  INSERT INTO @backup_set_id (backup_set_id)
  SELECT DISTINCT backup_set_id
  FROM msdb.dbo.backupset
  WHERE backup_finish_date < @oldest_date

  INSERT INTO @media_set_id (media_set_id)
  SELECT DISTINCT media_set_id
  FROM msdb.dbo.backupset
  WHERE backup_finish_date < @oldest_date

  INSERT INTO @restore_history_id (restore_history_id)
  SELECT DISTINCT restore_history_id
  FROM msdb.dbo.restorehistory
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)

  BEGIN TRANSACTION

  DELETE FROM msdb.dbo.backupfile
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.backupfilegroup
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorefile
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorefilegroup
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorehistory
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.backupset
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE msdb.dbo.backupmediafamily
  FROM msdb.dbo.backupmediafamily bmf
  WHERE bmf.media_set_id IN (SELECT media_set_id
                             FROM @media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bmf.media_set_id) = 0)
  IF (@@error > 0)
    GOTO Quit

  DELETE msdb.dbo.backupmediaset
  FROM msdb.dbo.backupmediaset bms
  WHERE bms.media_set_id IN (SELECT media_set_id
                             FROM @media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bms.media_set_id) = 0)
  IF (@@error > 0)
    GOTO Quit

  COMMIT TRANSACTION
  RETURN

Quit:
  ROLLBACK TRANSACTION

END

GO
