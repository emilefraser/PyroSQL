SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_onerror]
    @log_id bigint,
    @message nvarchar(2048) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_event_onerror
    ELSE
        BEGIN TRANSACTION
    
    BEGIN TRY
    -- Check the log_id
    -- If @message is passed, we can allow to enter the error for a collection set
    -- otherwise we will rely on the entries in sysssislog table to get the error message.
    DECLARE @retVal INT
    IF (@message IS NULL)
    BEGIN
        EXEC @retVal = dbo.sp_syscollector_verify_event_log_id @log_id, 0
    END
    ELSE
    BEGIN
        EXEC @retVal = dbo.sp_syscollector_verify_event_log_id @log_id, 1
    END
    IF (@retVal <> 0)
        RETURN (@retVal)


    DECLARE
         @failure_message   NVARCHAR(2048)
        ,@execution_id        UNIQUEIDENTIFIER

    IF @message IS NULL 
    BEGIN
        -- If no message is provided, find the last task that has failed
        -- for this package in the sysssislog table.
        -- Store the message as the failure_message for our package log.
        SELECT 
            @execution_id = package_execution_id
        FROM dbo.syscollector_execution_log
        WHERE log_id = @log_id

        SELECT TOP 1 
            @failure_message = [message]
        FROM dbo.sysssislog
        WHERE executionid = @execution_id
            AND (UPPER([event] COLLATE SQL_Latin1_General_CP1_CS_AS) = 'ONERROR')
        ORDER BY endtime DESC
    END 
    ELSE 
    BEGIN
        -- Otherwise use the provided message
        SET @failure_message = @message
    END

    -- Update the execution log
    UPDATE dbo.syscollector_execution_log_internal SET
         [status] = 2                    -- Mark as Failed
        ,failure_message = @failure_message
    WHERE
        log_id = @log_id

    -- Update all parent logs with the failure status
    SELECT @log_id = parent_log_id FROM dbo.syscollector_execution_log_internal WHERE log_id = @log_id;
    WHILE @log_id IS NOT NULL
    BEGIN
        UPDATE dbo.syscollector_execution_log_internal SET
            [status] = 2                    -- Mark as Failed
        WHERE
            log_id = @log_id;

        -- get the next parent
        SELECT @log_id = parent_log_id FROM dbo.syscollector_execution_log_internal WHERE log_id = @log_id;
    END

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_event_onerror

        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        RAISERROR (14684, @ErrorSeverity, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        RETURN (1)    
    END CATCH
END

GO
