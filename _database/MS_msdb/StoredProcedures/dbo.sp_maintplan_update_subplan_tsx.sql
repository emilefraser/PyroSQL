SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- This procedure is called when a maintenance plan subplan record
-- needs to be created or updated to match a multi-server Agent job
-- that has arrived from the master server.
CREATE PROCEDURE sp_maintplan_update_subplan_tsx
    @subplan_id    UNIQUEIDENTIFIER,
    @plan_id       UNIQUEIDENTIFIER,
    @name          sysname,
    @description   NVARCHAR(512),
    @job_id        UNIQUEIDENTIFIER
AS
BEGIN
    -- Find out what schedule, if any, is associated with the job.
    declare @schedule_id int
    select @schedule_id = (SELECT TOP(1) schedule_id
                           FROM msdb.dbo.sysjobschedules
                           WHERE (job_id = @job_id) )

    exec sp_maintplan_update_subplan @subplan_id, @plan_id, @name, @description, @job_id, @schedule_id, @allow_create=1

    -- Be sure to mark this subplan as coming from the master, not locally.
    update sysmaintplan_subplans
    set msx_plan = 1
    where subplan_id = @subplan_id
    
END

GO
