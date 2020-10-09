SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_delete_subplan
    @subplan_id       UNIQUEIDENTIFIER,
    @delete_jobs BIT                   = 1
AS
BEGIN

    DECLARE @retval     INT
    DECLARE @job        UNIQUEIDENTIFIER
    DECLARE @jobMsx     UNIQUEIDENTIFIER

    SET NOCOUNT ON
    SET @retval = 0

    -- Raise an error if the @subplan_id doesn't exist
    IF( NOT EXISTS(SELECT * FROM sysmaintplan_subplans WHERE subplan_id = @subplan_id))
    BEGIN
        DECLARE @subplan_id_as_char VARCHAR(36)
        SELECT @subplan_id_as_char = CONVERT(VARCHAR(36), @subplan_id)
        RAISERROR(14262, -1, -1, '@subplan_id', @subplan_id_as_char)
        RETURN(1)
    END


    BEGIN TRAN

    --Is there an Agent Job/Schedule associated with this subplan?
    SELECT @job = job_id, @jobMsx = msx_job_id
    FROM msdb.dbo.sysmaintplan_subplans 
    WHERE subplan_id = @subplan_id

    EXEC @retval = msdb.dbo.sp_maintplan_delete_log @subplan_id = @subplan_id
    IF (@retval <> 0)
    BEGIN
        ROLLBACK TRAN
        RETURN @retval
    END

    -- Delete the subplans table entry first since it has a foreign
    -- key constraint on its job_id existing in sysjobs.
    DELETE msdb.dbo.sysmaintplan_subplans 
    WHERE (subplan_id = @subplan_id)

    IF (@delete_jobs = 1)
    BEGIN
        --delete the local job associated with this subplan
        IF (@job IS NOT NULL)
        BEGIN
            EXEC @retval = msdb.dbo.sp_delete_job @job_id = @job, @delete_unused_schedule = 1
            IF (@retval <> 0)
            BEGIN
                ROLLBACK TRAN
                RETURN @retval
            END
        END

        --delete the multi-server job associated with this subplan.
        IF (@jobMsx IS NOT NULL)
        BEGIN 
            EXEC @retval = msdb.dbo.sp_delete_job @job_id = @jobMsx, @delete_unused_schedule = 1
            IF (@retval <> 0)
            BEGIN
                ROLLBACK TRAN
                RETURN @retval
            END
        END
    END

    COMMIT TRAN
    RETURN (0)
END

GO
