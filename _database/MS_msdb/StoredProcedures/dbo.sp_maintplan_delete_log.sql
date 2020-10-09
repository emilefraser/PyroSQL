SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_delete_log
    @plan_id        UNIQUEIDENTIFIER    = NULL,
    @subplan_id     UNIQUEIDENTIFIER    = NULL,
    @oldest_time    DATETIME            = NULL
AS
BEGIN
    -- @plan_id and @subplan_id must be both NULL or only one exclusively set
   IF (@plan_id IS NOT NULL) AND (@subplan_id IS NOT NULL)
   BEGIN
      RAISERROR(12980, -1, -1, '@plan_id', '@subplan_id')
      RETURN(1)
   END

   --Scenario 1: User wants to delete all logs
   --Scenario 2: User wants to delete all logs older than X date
   --Scenario 3: User wants to delete all logs for a given plan
   --Scenario 4: User wants to delete all logs for a specific subplan
   --Scenario 5: User wants to delete all logs for a given plan older than X date
   --Scenario 6: User wants to delete all logs for a specific subplan older than X date

   -- Special case 1: Delete all logs
   IF (@plan_id IS NULL) AND (@subplan_id IS NULL) AND (@oldest_time IS NULL)
   BEGIN
      DELETE msdb.dbo.sysmaintplan_logdetail
      DELETE msdb.dbo.sysmaintplan_log
      RETURN (0)
   END

   DELETE msdb.dbo.sysmaintplan_log 
    WHERE ( task_detail_id in 
            (SELECT task_detail_id 
             FROM msdb.dbo.sysmaintplan_log 
             WHERE ((@plan_id IS NULL)     OR (plan_id = @plan_id)) AND 
                   ((@subplan_id IS NULL)  OR (subplan_id = @subplan_id)) AND 
                   ((@oldest_time IS NULL) OR (start_time < @oldest_time))) )

    RETURN (0)
END

GO
