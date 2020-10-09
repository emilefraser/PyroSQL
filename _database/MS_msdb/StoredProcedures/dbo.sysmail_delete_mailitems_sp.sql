SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sysmail_delete_mailitems_sp
   @sent_before DATETIME   = NULL, -- sent before
   @sent_status varchar(8)   = NULL -- sent status
AS
BEGIN

   SET @sent_status       = LTRIM(RTRIM(@sent_status))
   IF @sent_status           = '' SET @sent_status = NULL

   IF ( (@sent_status IS NOT NULL) AND
         (LOWER(@sent_status collate SQL_Latin1_General_CP1_CS_AS) NOT IN ( 'unsent', 'sent', 'failed', 'retrying') ) )
   BEGIN
      RAISERROR(14266, -1, -1, '@sent_status', 'unsent, sent, failed, retrying')
      RETURN(1) -- Failure
   END

   IF ( @sent_before IS NULL AND @sent_status IS NULL )
   BEGIN
      RAISERROR(14608, -1, -1, '@sent_before', '@sent_status')  
      RETURN(1) -- Failure
   END

   DELETE FROM msdb.dbo.sysmail_allitems 
   WHERE 
        ((@sent_before IS NULL) OR ( send_request_date < @sent_before))
   AND ((@sent_status IS NULL) OR (sent_status = @sent_status))

   DECLARE @localmessage nvarchar(255)
    SET @localmessage = FORMATMESSAGE(14665, SUSER_SNAME(), @@ROWCOUNT)
    exec msdb.dbo.sysmail_logmailevent_sp @event_type=1, @description=@localmessage

END

GO
