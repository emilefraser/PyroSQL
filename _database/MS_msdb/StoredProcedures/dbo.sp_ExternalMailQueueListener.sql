SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Processes messages from the external mail queue
--
CREATE PROCEDURE [dbo].[sp_ExternalMailQueueListener]
AS
BEGIN
    DECLARE 
        @mailitem_id        INT,
        @sent_status        INT,
        @sent_account_id    INT,
        @rc                 INT,
        @processId          INT,
        @sent_date          DATETIME,
        @localmessage       NVARCHAR(max),
        @conv_handle        uniqueidentifier,
       @message_type_name  NVARCHAR(256),
       @xml_message_body   NVARCHAR(max),
        @LogMessage         NVARCHAR(max)

    -- Table to store message information.
    DECLARE @msgs TABLE
    (
        [conversation_handle]   uniqueidentifier,
       [message_type_name]     nvarchar(256),
       [message_body]          varbinary(max)
    )

    --RECEIVE messages from the external queue. 
    --MailItem status messages are sent from the external sql mail process along with other SSB notifications and errors
    ;RECEIVE conversation_handle, message_type_name, message_body FROM InternalMailQueue INTO @msgs
    -- Check if there was some error in reading from queue
    SET @rc = @@ERROR
    IF (@rc <> 0)
    BEGIN
        --Log error and continue. Don't want to block the following messages on the queue
        SET @localmessage = FORMATMESSAGE(@@ERROR)
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@localmessage

        GOTO ErrorHandler;
    END
   
    -----------------------------------
    --Process sendmail status messages
    SELECT 
        @conv_handle        = conversation_handle,
        @message_type_name  = message_type_name, 
		@xml_message_body   = CAST(message_body AS NVARCHAR(MAX))
    FROM @msgs 
    WHERE [message_type_name] = N'{//www.microsoft.com/databasemail/messages}SendMailStatus'

    IF(@message_type_name IS NOT NULL)
    BEGIN
        --
        --Expecting the xml body to be n the following form:
        --
        --<?xml version="1.0" encoding="utf-16"?>
        --<responses:SendMail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.microsoft.com/databasemail/responses ResponseTypes.xsd" xmlns:responses="http://schemas.microsoft.com/databasemail/responses">
        --<Information>
        --    <Failure Message="THe error message...."/>
        --</Information>
        --<MailItemId Id="1" />
        --<SentStatus Status="3" />
        --<SentAccountId Id="0" />
        --<SentDate Date="2005-03-30T14:55:13" />
        --<CallingProcess Id="3012" />
        --</responses:SendMail>

        DECLARE @xmlblob xml
        SET  @xmlblob = CONVERT(xml, @xml_message_body)

        SELECT  @mailitem_id = MailResponses.Properties.value('(MailItemId/@Id)[1]', 'int'),
                @sent_status = MailResponses.Properties.value('(SentStatus/@Status)[1]', 'int'),
                @sent_account_id = MailResponses.Properties.value('(SentAccountId/@Id)[1]', 'int'),
                @sent_date = MailResponses.Properties.value('(SentDate/@Date)[1]', 'DateTime'),
                @processId = MailResponses.Properties.value('(CallingProcess/@Id)[1]', 'int'),
                @LogMessage = MailResponses.Properties.value('(Information/Failure/@Message)[1]', 'NVARCHAR(max)')
        FROM @xmlblob.nodes('
        declare namespace responses="http://schemas.microsoft.com/databasemail/responses";
        /responses:SendMail') 
        AS MailResponses(Properties) 

        IF(@mailitem_id IS NULL)
        BEGIN  
            --Log error and continue. Don't want to block the following messages on the queue by rolling back the tran
            SET @localmessage = FORMATMESSAGE(14652, CONVERT(NVARCHAR(50), @conv_handle), @message_type_name, @xml_message_body)
            exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@localmessage
        END      
        ELSE
        BEGIN
            -- check sent_status is valid : 0(PendingSend), 1(SendSuccessful), 2(SendFailed), 3(AttemptingSendRetry)
            IF(@sent_status NOT IN (1, 2, 3))
            BEGIN
                SET @localmessage = FORMATMESSAGE(14653, N'SentStatus', CONVERT(NVARCHAR(50), @conv_handle), @message_type_name, @xml_message_body)
                exec msdb.dbo.sysmail_logmailevent_sp @event_type=2, @description=@localmessage

                --Set value to SendFailed
                SET @sent_status = 2
            END

            --Make the @sent_account_id NULL if it is 0. 
            IF(@sent_account_id IS NOT NULL AND @sent_account_id = 0)
                SET @sent_account_id = NULL

            --
            -- Update the mail status if not a retry. Nothing else needs to be done in this case
            UPDATE sysmail_mailitems
            SET sent_status     = CAST (@sent_status as TINYINT),
                sent_account_id = @sent_account_id,
                sent_date       = @sent_date
            WHERE mailitem_id = @mailitem_id
        
            -- Report a failure if no record is found in the sysmail_mailitems table
            IF (@@ROWCOUNT = 0)
            BEGIN
                SET @localmessage = FORMATMESSAGE(14653, N'MailItemId', CONVERT(NVARCHAR(50), @conv_handle), @message_type_name, @xml_message_body)
                exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@localmessage
            END

            IF (@LogMessage IS NOT NULL)
            BEGIN
                exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@LogMessage, @process_id=@processId, @mailitem_id=@mailitem_id, @account_id=@sent_account_id
            END
        END
    END

    -------------------------------------------------------
    --Process all other messages by logging to sysmail_log
    SET @conv_handle = NULL;
    
    --Always end the conversion if this message is received
    SELECT @conv_handle = conversation_handle
    FROM @msgs 
    WHERE [message_type_name] = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    
    IF(@conv_handle IS NOT NULL)
    BEGIN
        END CONVERSATION @conv_handle;
    END

    DECLARE @queuemessage nvarchar(max)
    DECLARE queue_messages_cursor CURSOR LOCAL 
    FOR
        SELECT FORMATMESSAGE(14654, CONVERT(NVARCHAR(50), conversation_handle), message_type_name, message_body)
        FROM @msgs 
        WHERE [message_type_name] 
              NOT IN (N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog',
                      N'{//www.microsoft.com/databasemail/messages}SendMailStatus')
  
    OPEN queue_messages_cursor 
    FETCH NEXT FROM queue_messages_cursor INTO @queuemessage
    WHILE (@@fetch_status = 0)
    BEGIN
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=2, @description=@queuemessage
        FETCH NEXT FROM queue_messages_cursor INTO @queuemessage
    END
    CLOSE queue_messages_cursor 
    DEALLOCATE queue_messages_cursor 

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
    RETURN (@rc)
END

GO
