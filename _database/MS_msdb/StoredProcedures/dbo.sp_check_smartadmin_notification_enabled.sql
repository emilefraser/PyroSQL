SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE sp_check_smartadmin_notification_enabled
AS
BEGIN
    -- Check if master switch is on
    IF (0 =  msdb.smart_admin.fn_is_master_switch_on ())
    BEGIN
        RAISERROR (45208, 17, 1);
        RETURN
    END

    -- Check if notification Email was set
    DECLARE @notification_email_ids NVARCHAR(MAX)
    SELECT @notification_email_ids = value
    FROM [msdb].[dbo].[autoadmin_system_flags]
    WHERE name = 'SSMBackup2WANotificationEmailIds'

    IF (@notification_email_ids IS NULL) OR (@notification_email_ids = N'')
    BEGIN
        RAISERROR (45209, 17, 2);
        RETURN
    END

END

GO
