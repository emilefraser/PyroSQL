SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE [dbo].[sp_RunMailQuery]
   @query                      NVARCHAR(max),
   @attach_results             BIT,
   @query_attachment_filename  NVARCHAR(260) = NULL,
   @no_output                  BIT,
   @query_result_header        BIT,
   @separator                  VARCHAR(1),
   @echo_error                 BIT,
   @dbuse                      sysname,
   @width                      INT,
   @temp_table_uid             uniqueidentifier,
   @query_no_truncate          BIT,
   @query_result_no_padding    BIT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER ON

    DECLARE @rc             INT,
            @prohibitedExts NVARCHAR(1000),
            @fileSizeStr    NVARCHAR(256),
            @fileSize       INT,
            @attach_res_int INT,
            @no_output_int  INT,
            @no_header_int  INT,
            @echo_error_int INT,
            @query_no_truncate_int INT,
            @query_result_no_padding_int   INT,
            @mailDbName     sysname,
            @uid            uniqueidentifier,
            @uidStr         VARCHAR(36)

    -- Initialize return code value as 1
    SET @rc = 1

    --
    --Get config settings and verify parameters
    --
    SET @query_attachment_filename = LTRIM(RTRIM(@query_attachment_filename))

    --Get the maximum file size allowed for attachments from sysmailconfig.
    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'MaxFileSize', 
                                                @parameter_value = @fileSizeStr OUTPUT
    --ConvertToInt will return the default if @fileSizeStr is null
    SET @fileSize = dbo.ConvertToInt(@fileSizeStr, 0x7fffffff, 100000)

    IF (@attach_results = 1)
    BEGIN
        --Need this if attaching the query
        EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'ProhibitedExtensions', 
                                                    @parameter_value = @prohibitedExts OUTPUT

        -- If attaching query results to a file and a filename isn't given create one
        IF ((@query_attachment_filename IS NOT NULL) AND (LEN(@query_attachment_filename) > 0))
        BEGIN 
          EXEC @rc = sp_isprohibited @query_attachment_filename, @prohibitedExts
          IF (@rc <> 0)
          BEGIN
              RAISERROR(14630, 16, 1, @query_attachment_filename, @prohibitedExts)
              RETURN 2
          END
        END
        ELSE
        BEGIN
            --If queryfilename is not specified, generate a random name (doesn't have to be unique)
           SET @query_attachment_filename = 'QueryResults' + CONVERT(varchar, ROUND(RAND() * 1000000, 0)) + '.txt'
        END
    END

    --Init variables used in the query execution
    SET @mailDbName = db_name()
    SET @uidStr = convert(varchar(36), @temp_table_uid)

    SET @attach_res_int        = CONVERT(int, @attach_results)
    SET @no_output_int         = CONVERT(int, @no_output)
    IF(@query_result_header = 0) SET @no_header_int  = 1 ELSE SET @no_header_int  = 0
    SET @echo_error_int        = CONVERT(int, @echo_error)
    SET @query_no_truncate_int = CONVERT(int, @query_no_truncate)
    SET @query_result_no_padding_int = CONVERT(int, @query_result_no_padding )

    EXEC @rc = master..xp_sysmail_format_query  
            @query                      = @query,
            @message                    = @mailDbName,
            @subject                    = @uidStr,
            @dbuse                      = @dbuse, 
            @attachments                = @query_attachment_filename,
            @attach_results             = @attach_res_int,
            -- format params
            @separator                  = @separator,
            @no_header                  = @no_header_int,
            @no_output                  = @no_output_int,
            @echo_error                 = @echo_error_int,
            @max_attachment_size        = @fileSize,
            @width                      = @width, 
            @query_no_truncate          = @query_no_truncate_int,
            @query_result_no_padding    = @query_result_no_padding_int
   RETURN @rc
END

GO
