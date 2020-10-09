SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sysmail_start_sp : allows databasemail to process mail from the queue 
CREATE PROCEDURE sysmail_start_sp
AS
    SET NOCOUNT ON
    DECLARE @rc INT 
   DECLARE @localmessage nvarchar(255)

    ALTER QUEUE ExternalMailQueue WITH STATUS = ON
    SELECT @rc = @@ERROR
    IF(@rc = 0)
    BEGIN
      ALTER QUEUE ExternalMailQueue WITH ACTIVATION (STATUS = ON);
       SET @localmessage = FORMATMESSAGE(14639, SUSER_SNAME())
       exec msdb.dbo.sysmail_logmailevent_sp @event_type=1, @description=@localmessage
    END
RETURN @rc

GO
