SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE sp_autoadmin_notification_job_send_email
    @profile_name SYSNAME = null  -- If null, default mail profile is used
AS
BEGIN
    DECLARE @tableHTML  NVARCHAR(MAX) ;
    DECLARE @notification_email_ids NVARCHAR(MAX)

    SELECT @notification_email_ids = value
    FROM [msdb].[dbo].[autoadmin_system_flags]
    WHERE name = 'SSMBackup2WANotificationEmailIds'

    IF (@notification_email_ids IS NULL) OR (@notification_email_ids = N'')
    BEGIN
        RAISERROR (45209, 17, 1);
        RETURN
    END

        -- Construct HTML table; $ISSUE - Replace with Weiyun's Query
    SET @tableHTML =
        N'<H1>Smartadmin health check report</H1>' +
        N'<table border="1">' +
        N'<tr><th>Datetime</th>' +
        N'<th>Instance name</th>' +
        N'<th>Storage errors</th>' +
        N'<th>Sql errors</th>' +
        N'<th>Credential errors</th>' +
        N'<th>Other errors</th>' +
        N'<th>Deleted or invalid backup files</th>' +
        N'<th>Number of backup loops</th>' +
        N'<th>Number of retention loops</th></tr>' +
        CAST ( ( select  td = [Datetime],        '',
            td = [Instance name],       '',
            td =  [Storage errors],         '',
            td =  [Sql errors],         '',
            td =  [Credential errors],         '',
            td =  [Other errors],         '',
            td =  [Deleted or invalid backup files] ,  '',
            td =  [Number of backup loops],         '',
            td =  [Number of retention loops],         ''
            FROM msdb.dbo.vw_autoadmin_health_status
            FOR XML PATH('tr'), TYPE 
            ) AS NVARCHAR(MAX) ) +
        N'</table>' ;

    -- $ISSUE - Localize message
    DECLARE @subject NVARCHAR(255)
    SET @subject = 'Smartadmin health check on ' + @@servername + '  at ' + CONVERT(VARCHAR, GETDATE())

    EXEC [msdb].[dbo].[sp_send_dbmail]
            @profile_name = @profile_name,
            @recipients = @notification_email_ids,
            @subject = @subject,
            @body = @tableHTML,
            @body_format = 'HTML' ;

END

GO
