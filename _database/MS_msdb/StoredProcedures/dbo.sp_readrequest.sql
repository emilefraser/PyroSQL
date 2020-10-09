SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- sp_readrequest : Reads a request from the the queue and returns its
--                  contents.
CREATE PROCEDURE sp_readrequest
    @receive_timeout    INT     -- the max time this read will wait for new message
AS
BEGIN
    SET NOCOUNT ON

    -- Table to store message information.
    DECLARE @msgs TABLE
    (
       [conversation_handle] uniqueidentifier,
       [service_contract_name] nvarchar(256),
       [message_type_name] nvarchar(256),
       [message_body] varbinary(max)
    )

    -- Declare variables to store row values fetched from the cursor
    DECLARE 
        @exit                   INT,
        @mailitem_id            INT,
        @profile_id             INT,
        @conversation_handle    uniqueidentifier,
        @service_contract_name  NVARCHAR(256),
        @message_type_name      NVARCHAR(256),
        @xml_message_body       VARCHAR(max),
        @timediff               INT,
        @rec_timeout            INT,
        @start_time             DATETIME,
        @localmessage           NVARCHAR(256),
        @rc                     INT

    --Init variables
    SELECT @start_time = GETDATE(),
           @timediff = 0,
           @exit = 0,
           @rc = 0

    WHILE (@timediff <= @receive_timeout)
    BEGIN
        -- Delete all messages from @msgs table
        DELETE FROM @msgs

        -- Pick all message from queue
        SET @rec_timeout = @receive_timeout - @timediff
        WAITFOR(RECEIVE conversation_handle, service_contract_name, message_type_name, message_body 
                FROM ExternalMailQueue INTO @msgs), TIMEOUT @rec_timeout

        -- Check if there was some error in reading from queue
        SET @rc = @@ERROR
        IF (@rc <> 0)
        BEGIN
           IF(@rc < 4) -- make sure return code is not in reserved range (1-3)
               SET @rc = 4

           --Note: we will get error no. 9617 if the service queue 'ExternalMailQueue' is currently disabled.
           BREAK
        END

       --If there is no message in the queue return 1 to indicate a timeout
        IF NOT EXISTS(SELECT * FROM @msgs)
        BEGIN
          SET @rc = 1
          BREAK
        END

        -- Create a cursor to iterate through the messages.
        DECLARE msgs_cursor CURSOR FOR
        SELECT conversation_handle, 
            service_contract_name, 
            message_type_name,
            CONVERT(VARCHAR(MAX), message_body)
        FROM @msgs;

        -- Open the cursor
        OPEN msgs_cursor;

        -- Perform the first fetch and store the values in the variables.
        FETCH NEXT FROM msgs_cursor
        INTO 
            @conversation_handle,
            @service_contract_name,
            @message_type_name,
            @xml_message_body

        -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            -- Check if the message is a send mail message
            IF(@message_type_name = N'{//www.microsoft.com/databasemail/messages}SendMail')
            BEGIN
                DECLARE @xmlblob xml
                
                SET @xmlblob = CONVERT(xml, @xml_message_body) 
                    
                SELECT  @mailitem_id = MailRequest.Properties.value('(MailItemId)[1]', 'int') 
                FROM @xmlblob.nodes('
                declare namespace requests="http://schemas.microsoft.com/databasemail/requests";
                /requests:SendMail') 
                AS MailRequest(Properties) 
                				
                -- get account information 
                SELECT @profile_id = profile_id
                FROM sysmail_mailitems 
                WHERE mailitem_id = @mailitem_id

                IF(@profile_id IS NULL) -- mail item has been deleted from the database
                BEGIN
                   -- log warning
                   SET @localmessage = FORMATMESSAGE(14667, @mailitem_id)
                   exec msdb.dbo.sysmail_logmailevent_sp @event_type=2, @description=@localmessage

                   -- Resource clean-up
                   IF(@conversation_handle IS NOT NULL)
                      END CONVERSATION @conversation_handle;
                   
                   -- return code has special meaning and will be propagated to the calling process
                   SET @rc = 2
                END
                ELSE
                BEGIN
                   -- This returns the mail item to the client as multiple result sets
                   EXEC sp_MailItemResultSets
                           @mailitem_id            = @mailitem_id,
                           @profile_id             = @profile_id,
                           @conversation_handle    = @conversation_handle,
                           @service_contract_name  = @service_contract_name,
                           @message_type_name      = @message_type_name
                
                   SET @exit = 1 -- make sure we exit outer loop
                END

                -- always break from the loop upon processing SendMail message
                BREAK
            END
            -- Check if the message is a dialog timer. This is used for account retries
            ELSE IF(@message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer')
            BEGIN
                -- Handle the retry case. - DialogTimer is used for send mail reties
                EXEC @rc = sp_process_DialogTimer
                            @conversation_handle    = @conversation_handle,
                            @service_contract_name  = @service_contract_name,
                            @message_type_name      = N'{//www.microsoft.com/databasemail/messages}SendMail'

                -- Always break from the loop upon processing DialogTimer message
                -- In case of failure return code from procedure call will simply be propagated to the calling process
                SET @exit = 1 -- make sure we exit outer loop
                BREAK
            END
            -- Error case
            ELSE IF (@message_type_name = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
            -- Error in the conversation, hence ignore all the messages of this conversation.
                BREAK

            -- This is executed as long as fetch succeeds.
            FETCH NEXT FROM msgs_cursor
            INTO 
                @conversation_handle,
                @service_contract_name,
                @message_type_name,
                @xml_message_body
        END

        CLOSE msgs_cursor;
        DEALLOCATE msgs_cursor;

        -- Check if we read any request or only SSB generated messages
        -- If a valid request is read with or without an error break out of loop
        IF (@exit = 1 OR @rc <> 0)
            BREAK

       --Keep track of how long this sp has been running
        select @timediff = DATEDIFF(ms, @start_time, getdate()) 
    END

    -- propagate return code to the calling process
    RETURN @rc
END

GO
