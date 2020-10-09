SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE autoadmin_set_system_flag
    @flag_name		NVARCHAR(128),
    @flag_value		NVARCHAR(MAX)
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
    BEGIN
        SAVE TRANSACTION tran_autoadmin_set_system_flag
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION
    END

    BEGIN TRY
        -- Check if we are updating / adding Notification email ID 
        IF(@flag_name IS NOT NULL)
        BEGIN
            IF(@flag_name = N'SSMBackup2WANotificationEmailIds')
            BEGIN
                EXEC sp_autoadmin_configure_notification 
            END
        END

        IF EXISTS (SELECT TOP 1 * FROM autoadmin_system_flags WHERE name = @flag_name)
        BEGIN
            UPDATE autoadmin_system_flags SET value = @flag_value WHERE name = @flag_name
        END
        ELSE
        BEGIN
            INSERT autoadmin_system_flags VALUES (@flag_name, @flag_value)
        END

        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_autoadmin_set_system_flag

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
