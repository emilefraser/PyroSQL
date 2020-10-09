SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_start
    @plan_id        UNIQUEIDENTIFIER    = NULL,
    @subplan_id     UNIQUEIDENTIFIER    = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @jobid  UNIQUEIDENTIFIER
    DECLARE @retval INT
    SET @retval = 0

    -- A @plan_id or @subplan_id must be supplied
   IF (@plan_id IS NULL) AND (@subplan_id IS NULL)
   BEGIN
      RAISERROR(12982, -1, -1, '@plan_id', '@subplan_id')
      RETURN(1)
   END

    -- either @plan_id or @subplan_id must be exclusively set
   IF (@plan_id IS NOT NULL) AND (@subplan_id IS NOT NULL)
   BEGIN
      RAISERROR(12982, -1, -1, '@plan_id', '@subplan_id')
      RETURN(1)
   END

    IF (@subplan_id IS NOT NULL)
    BEGIN 
        -- subplan_id supplied so simply start the subplan's job

        SELECT @jobid = job_id 
        FROM msdb.dbo.sysmaintplan_subplans 
        WHERE subplan_id = @subplan_id 

        if(@jobid IS NOT NULL)
        BEGIN
            EXEC @retval = msdb.dbo.sp_start_job @job_id = @jobid
        END

    END
    ELSE
    BEGIN
        -- Loop through Subplans and fire off all associated jobs
       DECLARE spj CURSOR LOCAL FOR 
            SELECT job_id
            FROM msdb.dbo.sysmaintplan_subplans 
            WHERE plan_id = @plan_id FOR READ ONLY

       OPEN spj
       FETCH NEXT FROM spj INTO @jobid
       WHILE (@@FETCH_STATUS = 0)
       BEGIN 
           EXEC @retval = msdb.dbo.sp_start_job @job_id = @jobid
            IF(@retval <> 0)
                BREAK

           FETCH NEXT FROM spj INTO @jobid
       END

       CLOSE spj
       DEALLOCATE spj

    END

    RETURN (@retval)
END

GO
