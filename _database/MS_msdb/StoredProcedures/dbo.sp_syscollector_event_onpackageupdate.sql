SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_onpackageupdate]
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

    -- Update the log
    UPDATE dbo.syscollector_execution_log_internal SET
        last_iteration_time = GETDATE()
    WHERE log_id = @log_id

    RETURN (0)
END

GO
