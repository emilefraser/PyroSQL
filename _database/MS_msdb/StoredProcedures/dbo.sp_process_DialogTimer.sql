SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- Processes a DialogTimer message from the the queue. This is used for send mail retries.
-- Returns the mail to be send if a retry is required or logs a failure if max retry count has been reached 
CREATE PROCEDURE sp_process_DialogTimer
    @conversation_handle    uniqueidentifier,
   @service_contract_name  NVARCHAR(256),
   @message_type_name      NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON

    -- Declare all variables
    DECLARE 
        @mailitem_id        INT,
        @profile_id         INT,
        @send_attempts      INT,
        @mail_request_date  DATETIME,
        @localmessage       NVARCHAR(255),
        @paramStr           NVARCHAR(256),
        @accRetryAttempts   INT

    -- Get the associated mail item data for the given @conversation_handle
   SELECT @mailitem_id     = mi.mailitem_id,
      @profile_id         = mi.profile_id,
        @mail_request_date  = mi.send_request_date,
      @send_attempts      = sr.send_attempts
   FROM sysmail_send_retries as sr
      JOIN sysmail_mailitems as mi
        ON sr.mailitem_id = mi.mailitem_id
   WHERE sr.conversation_handle = @conversation_handle

   -- If not able to find a mailitem_id return and move to the next message.
    -- This could happen if the mail items table was cleared before the retry was fired
   IF(@mailitem_id IS NULL)
   BEGIN
        --Log warning and continue
        -- "mailitem_id on conversation %s was not found in the sysmail_send_retries table. This mail item will not be sent."
        SET @localmessage = FORMATMESSAGE(14662, convert(NVARCHAR(50), @conversation_handle))
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=2, @description=@localmessage

        -- Resource clean-up
        IF(@conversation_handle IS NOT NULL)
        BEGIN
           END CONVERSATION @conversation_handle;
        END

        -- return code has special meaning and will be propagated to the calling process
        RETURN 2;
    END


    --Get the retry attempt count from sysmailconfig.
    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'AccountRetryAttempts', 
                                                 @parameter_value = @paramStr OUTPUT
    --ConvertToInt will return the default if @paramStr is null
    SET @accRetryAttempts = dbo.ConvertToInt(@paramStr, 0x7fffffff, 1)


   --Check the send attempts and log and error if send_attempts >= retry count.
    --This shouldn't happen unless the retry configuration was changed
   IF(@send_attempts > @accRetryAttempts)
   BEGIN
        --Log warning and continue
        -- "Mail Id %d has exceeded the retry count. This mail item will not be sent."
        SET @localmessage = FORMATMESSAGE(14663, @mailitem_id)
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=2, @description=@localmessage, @mailitem_id=@mailitem_id

        -- Resource clean-up
        IF(@conversation_handle IS NOT NULL)
        BEGIN
           END CONVERSATION @conversation_handle;
        END

        -- return code has special meaning and will be propagated to the calling process
        RETURN 3;
    END

    -- This returns the mail item to the client as multiple result sets
    EXEC sp_MailItemResultSets
            @mailitem_id            = @mailitem_id,
            @profile_id             = @profile_id,
            @conversation_handle    = @conversation_handle,
           @service_contract_name  = @service_contract_name,
           @message_type_name      = @message_type_name

   
   RETURN 0

END

GO
