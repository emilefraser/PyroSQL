SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_close_logentry
    @task_detail_id     UNIQUEIDENTIFIER,
    @end_time          DATETIME            = NULL,
    @succeeded         TINYINT
AS
BEGIN

   --Set defaults
   IF (@end_time IS NULL)
   BEGIN
      SELECT @end_time = GETDATE()
   END

    -- Raise an error if the @task_detail_id doesn't exist
    IF( NOT EXISTS(SELECT * FROM sysmaintplan_log WHERE (task_detail_id = @task_detail_id)))
   BEGIN
        DECLARE @task_detail_id_as_char VARCHAR(36)
        SELECT @task_detail_id_as_char = CONVERT(VARCHAR(36), @task_detail_id)
        RAISERROR(14262, -1, -1, '@task_detail_id', @task_detail_id_as_char)
      RETURN(1)
   END

   UPDATE msdb.dbo.sysmaintplan_log 
    SET end_time = @end_time, succeeded = @succeeded 
    WHERE (task_detail_id = @task_detail_id)

    RETURN (@@ERROR)
END

GO
