SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_update_job_proxy]
    @job_id                    uniqueidentifier,
    @proxy_id                int = NULL,
    @proxy_name                sysname = NULL
AS
BEGIN
    -- update the proxy id for the all job steps
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_syscollector_update_proxy
    ELSE
        BEGIN TRANSACTION
    
    BEGIN TRY
        DECLARE @step_id         INT
        DECLARE cursor_job_steps CURSOR FOR
            SELECT step_id FROM dbo.sysjobsteps WHERE job_id = @job_id AND subsystem = N'CMDEXEC'

        OPEN cursor_job_steps
        FETCH NEXT FROM cursor_job_steps INTO @step_id

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_update_jobstep
                @job_id = @job_id,
                @step_id = @step_id,
                @proxy_id = @proxy_id,
                @proxy_name = @proxy_name

            FETCH NEXT FROM cursor_job_steps INTO @step_id
        END

        CLOSE      cursor_job_steps
        DEALLOCATE cursor_job_steps

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_syscollector_update_proxy

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
