SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sp_send_dbmail : Sends a mail from Yukon outbox.
--
CREATE PROCEDURE [dbo].[sp_send_dbmail]
   @profile_name               sysname    = NULL,        
   @recipients                 VARCHAR(MAX)  = NULL, 
   @copy_recipients            VARCHAR(MAX)  = NULL,
   @blind_copy_recipients      VARCHAR(MAX)  = NULL,
   @subject                    NVARCHAR(255) = NULL,
   @body                       NVARCHAR(MAX) = NULL, 
   @body_format                VARCHAR(20)   = NULL, 
   @importance                 VARCHAR(6)    = 'NORMAL',
   @sensitivity                VARCHAR(12)   = 'NORMAL',
   @file_attachments           NVARCHAR(MAX) = NULL,  
   @query                      NVARCHAR(MAX) = NULL,
   @execute_query_database     sysname       = NULL,  
   @attach_query_result_as_file BIT          = 0,
   @query_attachment_filename  NVARCHAR(260) = NULL,  
   @query_result_header        BIT           = 1,
   @query_result_width         INT           = 256,            
   @query_result_separator     CHAR(1)       = ' ',
   @exclude_query_output       BIT           = 0,
   @append_query_error         BIT           = 0,
   @query_no_truncate          BIT           = 0,
   @query_result_no_padding    BIT           = 0,
   @mailitem_id               INT            = NULL OUTPUT,
   @from_address               VARCHAR(max)  = NULL,
   @reply_to                   VARCHAR(max)  = NULL
  WITH EXECUTE AS 'dbo'
AS
BEGIN
    SET NOCOUNT ON

    -- And make sure ARITHABORT is on. This is the default for yukon DB's
    SET ARITHABORT ON

    --Declare variables used by the procedure internally
    DECLARE @profile_id         INT,
            @temp_table_uid     uniqueidentifier,
            @sendmailxml        VARCHAR(max),
            @CR_str             NVARCHAR(2),
            @localmessage       NVARCHAR(255),
            @QueryResultsExist  INT,
            @AttachmentsExist   INT,
            @RetErrorMsg        NVARCHAR(4000), --Impose a limit on the error message length to avoid memory abuse 
            @rc                 INT,
            @procName           sysname,
            @trancountSave      INT,
            @tranStartedBool    INT,
            @is_sysadmin        BIT,
            @send_request_user  sysname,
            @database_user_id   INT,
            @sid                varbinary(85)

    -- Initialize 
    SELECT  @rc                 = 0,
            @QueryResultsExist  = 0,
            @AttachmentsExist   = 0,
            @temp_table_uid     = NEWID(),
            @procName           = OBJECT_NAME(@@PROCID),
            @tranStartedBool    = 0,
            @trancountSave      = @@TRANCOUNT,
            @sid                = NULL

    EXECUTE AS CALLER
       SELECT @is_sysadmin       = IS_SRVROLEMEMBER('sysadmin'),
              @send_request_user = SUSER_SNAME(),
              @database_user_id  = USER_ID()
    REVERT

    --Check if SSB is enabled in this database
    IF (ISNULL(DATABASEPROPERTYEX(DB_NAME(), N'IsBrokerEnabled'), 0) <> 1)
    BEGIN
       RAISERROR(14650, 16, 1)
       RETURN 1
    END

    --Report error if the mail queue has been stopped. 
    --sysmail_stop_sp/sysmail_start_sp changes the receive status of the SSB queue
    IF NOT EXISTS (SELECT * FROM sys.service_queues WHERE name = N'ExternalMailQueue' AND is_receive_enabled = 1)
    BEGIN
       RAISERROR(14641, 16, 1)
       RETURN 1
    END

    -- Get the relevant profile_id 
    --
    IF (@profile_name IS NULL)
    BEGIN
        -- Use the global or users default if profile name is not supplied
        SELECT TOP (1) @profile_id = pp.profile_id
        FROM msdb.dbo.sysmail_principalprofile as pp
        WHERE (pp.is_default = 1) AND
            (dbo.get_principal_id(pp.principal_sid) = @database_user_id OR pp.principal_sid = 0x00)
        ORDER BY dbo.get_principal_id(pp.principal_sid) DESC

        --Was a profile found
        IF(@profile_id IS NULL)
        BEGIN
            -- Try a profile lookup based on Windows Group membership, if any
            EXEC @rc = msdb.dbo.sp_validate_user @send_request_user, @sid OUTPUT
            IF (@rc = 0)
            BEGIN
                SELECT TOP (1) @profile_id = pp.profile_id
                FROM msdb.dbo.sysmail_principalprofile as pp
                WHERE (pp.is_default = 1) AND
                      (pp.principal_sid = @sid)
                ORDER BY dbo.get_principal_id(pp.principal_sid) DESC
            END

            IF(@profile_id IS NULL)
            BEGIN
                RAISERROR(14636, 16, 1)
                RETURN 1
            END
        END
    END
    ELSE
    BEGIN
        --Get primary account if profile name is supplied
        EXEC @rc = msdb.dbo.sysmail_verify_profile_sp @profile_id = NULL, 
                         @profile_name = @profile_name, 
                         @allow_both_nulls = 0, 
                         @allow_id_name_mismatch = 0,
                         @profileid = @profile_id OUTPUT
        IF (@rc <> 0)
            RETURN @rc

        --Make sure this user has access to the specified profile.
        --sysadmins can send on any profiles
        IF ( @is_sysadmin <> 1)
        BEGIN
            --Not a sysadmin so check users access to profile
            iF NOT EXISTS(SELECT * 
                        FROM msdb.dbo.sysmail_principalprofile 
                        WHERE ((profile_id = @profile_id) AND
                                (dbo.get_principal_id(principal_sid) = @database_user_id OR principal_sid = 0x00)))
            BEGIN
                EXEC msdb.dbo.sp_validate_user @send_request_user, @sid OUTPUT
                IF(@sid IS NULL)
                BEGIN
                    RAISERROR(14607, -1, -1, 'profile')
                    RETURN 1
                END
            END
        END
    END

    --Attach results must be specified
    IF @attach_query_result_as_file IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'attach_query_result_as_file')
       RETURN 2
    END

    --No output must be specified
    IF @exclude_query_output IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'exclude_query_output')
       RETURN 3
    END

    --No header must be specified
    IF @query_result_header IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'query_result_header')
       RETURN 4
    END

    -- Check if query_result_separator is specifed
    IF @query_result_separator IS NULL OR DATALENGTH(@query_result_separator) = 0
    BEGIN
       RAISERROR(14618, 16, 1, 'query_result_separator')
       RETURN 5
    END

    --Echo error must be specified
    IF @append_query_error IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'append_query_error')
       RETURN 6
    END

    --@body_format can be TEXT (default) or HTML
    IF (@body_format IS NULL)
    BEGIN
       SET @body_format = 'TEXT'
    END
    ELSE
    BEGIN
       SET @body_format = UPPER(@body_format)

       IF @body_format NOT IN ('TEXT', 'HTML') 
       BEGIN
          RAISERROR(14626, 16, 1, @body_format)
          RETURN 13
       END
    END

    --Importance must be specified
    IF @importance IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'importance')
       RETURN 15
    END

    SET @importance = UPPER(@importance)

    --Importance must be one of the predefined values
    IF @importance NOT IN ('LOW', 'NORMAL', 'HIGH')
    BEGIN
       RAISERROR(14622, 16, 1, @importance)
       RETURN 16
    END

    --Sensitivity must be specified
    IF @sensitivity IS NULL
    BEGIN
       RAISERROR(14618, 16, 1, 'sensitivity')
       RETURN 17
    END

    SET @sensitivity = UPPER(@sensitivity)

    --Sensitivity must be one of predefined values
    IF @sensitivity NOT IN ('NORMAL', 'PERSONAL', 'PRIVATE', 'CONFIDENTIAL')
    BEGIN
       RAISERROR(14623, 16, 1, @sensitivity)
       RETURN 18
    END

    --Message body cannot be null. Atleast one of message, subject, query,
    --attachments must be specified.
    IF( (@body IS NULL AND @query IS NULL AND @file_attachments IS NULL AND @subject IS NULL)
       OR
    ( (LEN(@body) IS NULL OR LEN(@body) <= 0)  
       AND (LEN(@query) IS NULL  OR  LEN(@query) <= 0)
       AND (LEN(@file_attachments) IS NULL OR LEN(@file_attachments) <= 0)
       AND (LEN(@subject) IS NULL OR LEN(@subject) <= 0)
    )
    )
    BEGIN
       RAISERROR(14624, 16, 1, '@body, @query, @file_attachments, @subject')
       RETURN 19
    END   
    ELSE
       IF @subject IS NULL OR LEN(@subject) <= 0
          SET @subject='SQL Server Message'

    --Recipients cannot be empty. Atleast one of the To, Cc, Bcc must be specified
    IF ( (@recipients IS NULL AND @copy_recipients IS NULL AND 
       @blind_copy_recipients IS NULL
        )     
       OR
        ( (LEN(@recipients) IS NULL OR LEN(@recipients) <= 0)
       AND (LEN(@copy_recipients) IS NULL OR LEN(@copy_recipients) <= 0)
       AND (LEN(@blind_copy_recipients) IS NULL OR LEN(@blind_copy_recipients) <= 0)
        )
    )
    BEGIN
       RAISERROR(14624, 16, 1, '@recipients, @copy_recipients, @blind_copy_recipients')
       RETURN 20
    END

    EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @recipients, @parameter_name='@recipients' 
    IF (@rc <> 0)
       RETURN @rc
    EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @copy_recipients, @parameter_name='@copy_recipients' 
    IF (@rc <> 0)
       RETURN @rc
    EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @blind_copy_recipients, @parameter_name='@blind_copy_recipients' 
    IF (@rc <> 0)
       RETURN @rc
    EXEC @rc = msdb.dbo.sysmail_verify_addressparams_sp @address = @reply_to, @parameter_name='@reply_to' 
    IF (@rc <> 0)
       RETURN @rc

    --If query is not specified, attach results and no header cannot be true.
    IF ( (@query IS NULL OR LEN(@query) <= 0) AND @attach_query_result_as_file = 1)
    BEGIN
       RAISERROR(14625, 16, 1)
       RETURN 21
    END

    --
    -- Execute Query if query is specified
    IF ((@query IS NOT NULL) AND (LEN(@query) > 0))
    BEGIN
        EXECUTE AS CALLER
        EXEC @rc = sp_RunMailQuery 
                @query                     = @query,
                @attach_results            = @attach_query_result_as_file,
                @query_attachment_filename = @query_attachment_filename,
                @no_output                 = @exclude_query_output,
                @query_result_header       = @query_result_header,
                @separator                 = @query_result_separator,
                @echo_error                = @append_query_error,
                @dbuse                     = @execute_query_database,
                @width                     = @query_result_width,
                @temp_table_uid            = @temp_table_uid,
                @query_no_truncate         = @query_no_truncate,
                @query_result_no_padding   = @query_result_no_padding
        
        --Switches the execution context back to the caller after last EXECUTE AS CALLER
        REVERT      

        IF(@rc <> 0 )
        BEGIN
            GOTO ErrorHandler;
        END
 
         -- Always check the transfer tables for data. They may also contain error messages
         -- Only one of the tables receives data in the call to sp_RunMailQuery
         IF(@attach_query_result_as_file = 1)
         BEGIN
             IF EXISTS(SELECT * FROM sysmail_attachments_transfer WHERE uid = @temp_table_uid)
            SET @AttachmentsExist = 1
         END
         ELSE
         BEGIN
             IF EXISTS(SELECT * FROM sysmail_query_transfer WHERE uid = @temp_table_uid AND uid IS NOT NULL)
            SET @QueryResultsExist = 1
         END

         -- Exit if there was an error and caller doesn't want the error appended to the mail
         IF (@rc <> 0 AND @append_query_error = 0)
         BEGIN
            --Error msg with be in either the attachment table or the query table 
            --depending on the setting of @attach_query_result_as_file
            IF(@attach_query_result_as_file = 1)
            BEGIN
               --Copy query results from the attachments table to mail body
               SELECT @RetErrorMsg = CONVERT(NVARCHAR(4000), attachment)
               FROM sysmail_attachments_transfer 
               WHERE uid = @temp_table_uid
            END
            ELSE
            BEGIN
               --Copy query results from the query table to mail body
               SELECT @RetErrorMsg = text_data 
               FROM sysmail_query_transfer 
               WHERE uid = @temp_table_uid
            END

            GOTO ErrorHandler;
         END
         SET @AttachmentsExist = @attach_query_result_as_file
    END
    ELSE
    BEGIN
        --If query is not specified, attach results cannot be true.
        IF (@attach_query_result_as_file = 1)
        BEGIN
           RAISERROR(14625, 16, 1)
           RETURN 21
        END
    END

    --Get the prohibited extensions for attachments from sysmailconfig.
    IF ((@file_attachments IS NOT NULL) AND (LEN(@file_attachments) > 0)) 
    BEGIN
        EXECUTE AS CALLER
        EXEC @rc = sp_GetAttachmentData 
                        @attachments = @file_attachments, 
                        @temp_table_uid = @temp_table_uid,
                        @exclude_query_output = @exclude_query_output
        REVERT
        IF (@rc <> 0)
            GOTO ErrorHandler;
        
        IF EXISTS(SELECT * FROM sysmail_attachments_transfer WHERE uid = @temp_table_uid)
            SET @AttachmentsExist = 1
    END

    -- Start a transaction if not already in one. 
    -- Note: For rest of proc use GOTO ErrorHandler for falures  
    if (@trancountSave = 0) 
       BEGIN TRAN @procName

    SET @tranStartedBool = 1

    -- Store complete mail message for history/status purposes  
    INSERT sysmail_mailitems
    (
       profile_id,   
       recipients,
       copy_recipients,
       blind_copy_recipients,
       subject,
       body, 
       body_format, 
       importance,
       sensitivity,
       file_attachments,  
       attachment_encoding,
       query,
       execute_query_database,
       attach_query_result_as_file,
       query_result_header,
       query_result_width,          
       query_result_separator,
       exclude_query_output,
       append_query_error,
       send_request_user,
       from_address,
       reply_to
    )
    VALUES
    (
       @profile_id,        
       @recipients, 
       @copy_recipients,
       @blind_copy_recipients,
       @subject,
       @body, 
       @body_format, 
       @importance,
       @sensitivity,
       @file_attachments,  
       'MIME',
       @query,
       @execute_query_database,  
       @attach_query_result_as_file,
       @query_result_header,
       @query_result_width,            
       @query_result_separator,
       @exclude_query_output,
       @append_query_error,
       @send_request_user,
       @from_address,
       @reply_to
    )

    SELECT @rc          = @@ERROR,
           @mailitem_id = SCOPE_IDENTITY()

    IF(@rc <> 0)
        GOTO ErrorHandler;

    --Copy query into the message body
    IF(@QueryResultsExist = 1)
    BEGIN
      -- if the body is null initialize it
        UPDATE sysmail_mailitems
        SET body = N''
        WHERE mailitem_id = @mailitem_id
        AND body is null

        --Add CR, a \r followed by \n, which is 0xd and then 0xa
        SET @CR_str = CHAR(13) + CHAR(10)
        UPDATE sysmail_mailitems
        SET body.WRITE(@CR_str, NULL, NULL)
        WHERE mailitem_id = @mailitem_id

   --Copy query results to mail body
        UPDATE sysmail_mailitems
        SET body.WRITE( (SELECT text_data from sysmail_query_transfer WHERE uid = @temp_table_uid), NULL, NULL )
        WHERE mailitem_id = @mailitem_id

    END

    --Copy into the attachments table
    IF(@AttachmentsExist = 1)
    BEGIN
        --Copy temp attachments to sysmail_attachments      
        INSERT INTO sysmail_attachments(mailitem_id, filename, filesize, attachment)
        SELECT @mailitem_id, filename, filesize, attachment
        FROM sysmail_attachments_transfer
        WHERE uid = @temp_table_uid
    END

    -- Create the primary SSB xml maessage
    SET @sendmailxml = '<requests:SendMail xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.microsoft.com/databasemail/requests RequestTypes.xsd" xmlns:requests="http://schemas.microsoft.com/databasemail/requests"><MailItemId>'
                        + CONVERT(NVARCHAR(20), @mailitem_id) + N'</MailItemId></requests:SendMail>'

    -- Send the send request on queue.
    EXEC @rc = sp_SendMailQueues @sendmailxml
    IF @rc <> 0
    BEGIN
       RAISERROR(14627, 16, 1, @rc, 'send mail')
       GOTO ErrorHandler;
    END

    -- Print success message if required
    IF (@exclude_query_output = 0)
    BEGIN
       SET @localmessage = FORMATMESSAGE(14635, @mailitem_id)
       PRINT @localmessage
    END  

    --
    -- See if the transaction needs to be commited
    --
    IF (@trancountSave = 0 and @tranStartedBool = 1)
       COMMIT TRAN @procName

    -- All done OK
    goto ExitProc;

    -----------------
    -- Error Handler
    -----------------
ErrorHandler:
    IF (@tranStartedBool = 1) 
       ROLLBACK TRAN @procName

    ------------------
    -- Exit Procedure
    ------------------
ExitProc:
   
    --Always delete query and attactment transfer records. 
   --Note: Query results can also be returned in the sysmail_attachments_transfer table
    DELETE sysmail_attachments_transfer WHERE uid = @temp_table_uid
    DELETE sysmail_query_transfer WHERE uid = @temp_table_uid

   --Raise an error it the query execution fails
   -- This will only be the case when @append_query_error is set to 0 (false)
   IF( (@RetErrorMsg IS NOT NULL) AND (@exclude_query_output=0) )
   BEGIN
      RAISERROR(14661, -1, -1, @RetErrorMsg)
   END

    RETURN (@rc)
END

GO
