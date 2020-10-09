SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_oncollectionstop]
    @collection_set_id int
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    -- Check the collection_set_id
    IF (@collection_set_id IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@collection_set_id')
        RETURN (1)
    END
    ELSE IF (NOT EXISTS (SELECT collection_set_id FROM dbo.syscollector_collection_sets WHERE collection_set_id = @collection_set_id))
    BEGIN
        DECLARE @collection_set_id_as_char VARCHAR(36)
        SELECT @collection_set_id_as_char = CONVERT(VARCHAR(36), @collection_set_id)

        RAISERROR(14262, -1, -1, '@collection_set_id', @collection_set_id_as_char)
        RETURN (1)
    END

    -- Find the log_id
    -- It will be a log entry for the same collection set, with no parent and not finished
    DECLARE @log_id bigint
    SELECT TOP 1 @log_id = log_id FROM dbo.syscollector_execution_log_internal 
        WHERE collection_set_id = @collection_set_id 
        AND parent_log_id IS NULL
        AND finish_time IS NULL
        ORDER BY start_time DESC

    IF (@log_id IS NULL)
    BEGIN
        -- Raise a warning message
        RAISERROR(14606, 9, -1, '@log_id')
    END
    ELSE
    BEGIN
        -- Mark the log as finished
        UPDATE dbo.syscollector_execution_log_internal SET
            finish_time = GETDATE(),
            [status] = CASE
                WHEN [status] = 0 THEN 1 -- Mark complete if it was running
                ELSE [status]            -- Leave the error status unchanged
            END
        WHERE log_id = @log_id
    END

    RETURN (0)
END

GO
