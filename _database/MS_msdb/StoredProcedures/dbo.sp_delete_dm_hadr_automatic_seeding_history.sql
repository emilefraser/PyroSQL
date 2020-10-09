SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE sp_delete_dm_hadr_automatic_seeding_history
  @oldest_date datetime
AS
BEGIN
  SET NOCOUNT ON

  DELETE FROM [msdb].[dbo].[dm_hadr_automatic_seeding_history]
  WHERE completion_time < @oldest_date
END

GO
