SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_GetAttachmentData
   @attachments           nvarchar(max),
   @temp_table_uid        uniqueidentifier,
   @exclude_query_output  BIT        = 0
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER ON

    DECLARE @rc             INT,
            @prohibitedExts NVARCHAR(1000),
            @attachFilePath NVARCHAR(260),
            @scIndex        INT,
            @startLocation  INT,
            @fileSizeStr    NVARCHAR(256),
            @fileSize       INT,
            @mailDbName     sysname,
            @uidStr         VARCHAR(36)

    --Get the maximum file size allowed for attachments from sysmailconfig.
    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'MaxFileSize', 
                                                @parameter_value = @fileSizeStr OUTPUT
    --ConvertToInt will return the default if @fileSizeStr is null
    SET @fileSize = dbo.ConvertToInt(@fileSizeStr, 0x7fffffff, 100000)

    --May need this if attaching files
    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'ProhibitedExtensions', 
                                                @parameter_value = @prohibitedExts OUTPUT

    SET @mailDbName = DB_NAME()
    SET @uidStr = CONVERT(VARCHAR(36), @temp_table_uid)

   SET @attachments = @attachments + ';'
   SET @startLocation = 0
   SET @scIndex = CHARINDEX(';', @attachments, @startLocation)

   WHILE (@scIndex <> 0)
   BEGIN
      SET @attachFilePath = SUBSTRING(@attachments, @startLocation, (@scIndex - @startLocation))
      
      -- Make sure we have an attachment file name to work with, and that it hasn't been truncated
      IF (@scIndex - @startLocation > 260 )
      BEGIN
            RAISERROR(14628, 16, 1)
          RETURN 1 
      END

        IF ((@attachFilePath IS NULL) OR (LEN(@attachFilePath) = 0))
        BEGIN
            RAISERROR(14628, 16, 1)
          RETURN 1 
        END

      --Check if attachment ext is allowed 
      EXEC @rc = sp_isprohibited @attachFilePath, @prohibitedExts
      IF (@rc <> 0)
      BEGIN
          RAISERROR(14630, 16, 1, @attachFilePath, @prohibitedExts)
          RETURN @rc
      END

        DECLARE  @no_output_int  INT
        SET @no_output_int         = CONVERT(int, @exclude_query_output)

        -- return code checked after select and delete calls
        EXEC @rc = master..xp_sysmail_attachment_load @message       = @mailDbName, 
                                                      @attachments      = @attachFilePath,
                                                      @subject       = @uidStr,
                                                      @max_attachment_size = @fileSize,
                                                      @no_output = @no_output_int
      IF (@rc <> 0)
            RETURN (@rc)
               
        --Get next substring index
      SET @startLocation = @scIndex + 1
      SET @scIndex = CHARINDEX(';', @attachments, @startLocation)

      IF (@scIndex = 0)
         BREAK
   END

    RETURN 0
END

GO
