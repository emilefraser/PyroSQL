SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_oncollectionend]
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
    EXEC @retVal = dbo.sp_syscollector_verify_event_log_id @log_id, 1
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

    RETURN (0)
END

GO
