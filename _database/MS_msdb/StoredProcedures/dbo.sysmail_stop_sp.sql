SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sysmail_stop_sp : stops the DatabaseMail process. Mail items remain in the queue until sqlmail started 
CREATE PROCEDURE sysmail_stop_sp
AS
    SET NOCOUNT ON
    DECLARE @rc INT
   DECLARE @localmessage nvarchar(255)
  
    ALTER QUEUE ExternalMailQueue WITH ACTIVATION (STATUS = OFF);
    SELECT @rc = @@ERROR
    IF(@rc = 0)
    BEGIN
       ALTER QUEUE ExternalMailQueue WITH STATUS = OFF;
       SELECT @rc = @@ERROR
       IF(@rc = 0)
       BEGIN
          SET @localmessage = FORMATMESSAGE(14640, SUSER_SNAME())
          exec msdb.dbo.sysmail_logmailevent_sp @event_type=1, @description=@localmessage
       END
    END
RETURN @rc

GO
