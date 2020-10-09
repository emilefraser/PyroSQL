SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Processes responses from dbmail 
--
CREATE PROCEDURE [dbo].[sp_ProcessResponse]
    @conv_handle        uniqueidentifier,
    @message_type_name  NVARCHAR(256),
    @xml_message_body   NVARCHAR(max)
AS
BEGIN
    DECLARE 
        @mailitem_id        INT,
        @sent_status        INT,
        @rc                 INT,
        @index              INT,
        @processId          INT,
        @sent_date          DATETIME,
        @localmessage       NVARCHAR(max),
        @LogMessage         NVARCHAR(max),
        @retry_hconv        uniqueidentifier,
        @paramStr           NVARCHAR(256),
        @accRetryDelay      INT

    --------------------------
    --Always send the response 
    ;SEND ON CONVERSATION @conv_handle MESSAGE TYPE @message_type_name (@xml_message_body)
    --
    -- Need to handle the case where a sent retry is requested. 
    -- This is done by setting a conversation timer, The timer with go off in the external queue

    --  $ISSUE: 325439 - DBMail: Use XML type  for all xml document handling in DBMail stored procs
    DECLARE @xmlblob xml
    SET  @xmlblob = CONVERT(xml, @xml_message_body)

    SELECT  @mailitem_id = MailResponses.Properties.value('(MailItemId/@Id)[1]', 'int'),
          @sent_status = MailResponses.Properties.value('(SentStatus/@Status)[1]', 'int')
    FROM @xmlblob.nodes('
    declare namespace responses="http://schemas.microsoft.com/databasemail/responses";
    /responses:SendMail') 
    AS MailResponses(Properties) 

    IF(@mailitem_id IS NULL OR @sent_status IS NULL)
    BEGIN  
        --Log error and continue.
        SET @localmessage = FORMATMESSAGE(14652, CONVERT(NVARCHAR(50), @conv_handle), @message_type_name, @xml_message_body)
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@localmessage

        GOTO ErrorHandler;
    END      

    -- Update the status of the email item
    UPDATE msdb.dbo.sysmail_mailitems
    SET sent_status = @sent_status
    WHERE mailitem_id = @mailitem_id

    --
    -- A send retry has been requested. Set a conversation timer
    IF(@sent_status = 3)
    BEGIN
        -- Get the associated mail item data for the given @conversation_handle (if it exists)
       SELECT @retry_hconv = conversation_handle
       FROM sysmail_send_retries as sr
            RIGHT JOIN sysmail_mailitems as mi
            ON sr.mailitem_id = mi.mailitem_id
       WHERE mi.mailitem_id = @mailitem_id

        --Must be the first retry attempt. Create a sysmail_send_retries record to track retries
        IF(@retry_hconv IS NULL)
        BEGIN
            INSERT sysmail_send_retries(conversation_handle, mailitem_id) --last_send_attempt_date
            VALUES(@conv_handle, @mailitem_id)
        END
        ELSE
        BEGIN
            --Update existing retry record
            UPDATE sysmail_send_retries
            SET last_send_attempt_date = GETDATE(),
                send_attempts = send_attempts + 1
            WHERE mailitem_id = @mailitem_id

        END

        --Get the global retry delay time
        EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'AccountRetryDelay', 
                                                    @parameter_value = @paramStr OUTPUT
        --ConvertToInt will return the default if @paramStr is null
        SET @accRetryDelay = dbo.ConvertToInt(@paramStr, 0x7fffffff, 300) -- 5 min default


        --Now set the dialog timer. This triggers the send retry
        ;BEGIN CONVERSATION TIMER (@conv_handle) TIMEOUT = @accRetryDelay 

    END
    ELSE
    BEGIN
        --Only end theconversation if a retry isn't being attempted
        END CONVERSATION @conv_handle
    END


    -- All done OK
    goto ExitProc;

    -----------------
    -- Error Handler
    -----------------
ErrorHandler:

    ------------------
    -- Exit Procedure
    ------------------
ExitProc:
    RETURN (@rc);

END

GO
