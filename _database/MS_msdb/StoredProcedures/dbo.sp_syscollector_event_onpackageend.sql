SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_onpackageend]
    @log_id bigint
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    -- Check the log_id
    DECLARE @retVal INT
    EXEC @retVal = dbo.sp_syscollector_verify_event_log_id @log_id
    IF (@retVal <> 0)
        RETURN (@retVal)

    -- Mark the log as finished
    UPDATE dbo.syscollector_execution_log_internal SET
        finish_time = GETDATE(),
        [status] = CASE
            WHEN [status] = 0 THEN 1 -- Mark complete if it was running
            ELSE [status]            -- Leave the error status unchanged
        END
    WHERE log_id = @log_id

    DECLARE @runtime_execution_mode smallint
    DECLARE @status smallint
    SELECT @status = [status], @runtime_execution_mode = runtime_execution_mode
    FROM dbo.syscollector_execution_log_internal
    WHERE log_id = @log_id

    -- status was successful and this is logged by an upload package
    IF @status = 1 AND @runtime_execution_mode = 1
    BEGIN
        -- if the package ended succesfully, update the top most log to warning if it had failure
        -- this is because if there were a previous upload failure but the latest upload were successful, 
        -- we want indicated a warning rather than a failure throughout the lifetime of this collection set
        DECLARE @parent_log_id BIGINT
        SELECT @parent_log_id = parent_log_id FROM dbo.syscollector_execution_log_internal WHERE log_id = @log_id;
        WHILE @parent_log_id IS NOT NULL
        BEGIN
            -- get the next parent
            SET @log_id = @parent_log_id
            SELECT @parent_log_id = parent_log_id FROM dbo.syscollector_execution_log_internal WHERE log_id = @log_id;
        END

        UPDATE dbo.syscollector_execution_log_internal SET
            [status] = CASE
                WHEN [status] = 2 THEN 3 -- Mark warning if it indicated a failure
                ELSE [status]            -- Leave the original status unchanged
            END
        WHERE
            log_id = @log_id
    END

    RETURN (0)
END

GO
