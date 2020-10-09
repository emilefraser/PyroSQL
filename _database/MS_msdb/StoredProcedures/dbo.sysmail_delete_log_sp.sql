SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sysmail_delete_log_sp
   @logged_before DATETIME   = NULL, 
   @event_type varchar(15)   = NULL
AS
BEGIN

   SET @event_type       = LTRIM(RTRIM(@event_type))
   IF @event_type        = '' SET @event_type = NULL
   DECLARE @event_type_numeric INT

   IF ( (@event_type IS NOT NULL) AND
         (LOWER(@event_type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ( 'success', 'warning', 'error', 'information' ) ) )
   BEGIN
        RAISERROR(14266, -1, -1, '@event_type', 'success, warning, error, information')
      RETURN(1) -- Failure
   END   
   
   IF ( @event_type IS NOT NULL)
   BEGIN
      SET @event_type_numeric = ( SELECT CASE 
                           WHEN @event_type = 'success' THEN 0
                           WHEN @event_type = 'information' THEN 1
                           WHEN @event_type = 'warning' THEN 2
                           ELSE 3 END 
                        )
   END
   ELSE
      SET @event_type_numeric = NULL

   DELETE FROM msdb.dbo.sysmail_log 
   WHERE 
        ((@logged_before IS NULL) OR ( log_date < @logged_before))
   AND ((@event_type_numeric IS NULL) OR (@event_type_numeric = event_type))
END

GO
