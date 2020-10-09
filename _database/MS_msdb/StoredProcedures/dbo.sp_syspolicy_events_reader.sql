SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_events_reader] 
AS
BEGIN
	DECLARE @retval_check int;
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END

	DECLARE @dh uniqueidentifier;
	DECLARE @mt sysname;
	DECLARE @body varbinary(max);
	DECLARE @msg nvarchar(max)

    BEGIN TRANSACTION;
    WAITFOR (RECEIVE TOP (1)
        @dh = conversation_handle,
        @mt = message_type_name,
        @body = message_body
        FROM [syspolicy_event_queue]), timeout 5000;
    WHILE (@dh is not null)
    BEGIN
        IF (@mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
        BEGIN
            -- @body contains the error
            DECLARE @bodyStr nvarchar(max)
            SET @bodyStr = convert(nvarchar(max), @body)
            RAISERROR (34001, 1,1, @bodyStr) with log;
            END CONVERSATION @dh;
        END
        IF (@mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
        BEGIN
            RAISERROR (34002, 1,1) with log;
            END CONVERSATION @dh;
        END
        IF (@mt = N'http://schemas.microsoft.com/SQL/Notifications/EventNotification')
        BEGIN
            -- process the event
            BEGIN TRY
                EXEC [dbo].[sp_syspolicy_dispatch_event]  @event_data = @body, @synchronous = 0
            END TRY
            BEGIN CATCH
                -- report the error

                DECLARE @errorNumber int
                DECLARE @errorMessage nvarchar(max)
                SET @errorNumber = ERROR_NUMBER()
                SET @errorMessage = ERROR_MESSAGE()

                RAISERROR (34003, 1,1, @errorNumber, @errorMessage ) with log;
            END CATCH
        END
        -- every message is handled in its own transaction
        COMMIT TRANSACTION;
        SELECT @dh = null;
        BEGIN TRANSACTION;
        WAITFOR (RECEIVE TOP (1)
            @dh = conversation_handle,
            @mt = message_type_name,
            @body = message_body
            FROM [syspolicy_event_queue]), TIMEOUT 5000;
    END
    COMMIT;
END

GO
