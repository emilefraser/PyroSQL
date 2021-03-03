DECLARE @mailserver VARCHAR(100) = 'smtp.gmail.com'
,@username  VARCHAR(100) = 'efraser25@gmail.com'
, @password  VARCHAR(100)  = '105022_Alpha'
, @loginemail varchar(100) =   'efraser25@gmail.com'
, @body varchar(max) = 'testing testing... is ths thing on?'

-- Create a Database Mail account
--EXECUTE msdb.dbo.sysmail_add_account_sp
--    @account_name = 'Kevro Notification',
--    @description = 'Kevro Notification Mail Account',
--    @email_address = @loginemail, 
--    @display_name = 'Kevro Notification',
--    @mailserver_name = @mailserver ,
--    @username = @username ,  
--    @password = @password

---- Create a Database Mail profile
--EXECUTE msdb.dbo.sysmail_add_profile_sp
--    @profile_name = 'AzureManagedInstance_dbmail_profile',
--    @description = 'Kevro Notification Mail Profile' 

---- Add the account to the profile
--EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
--    @profile_name = 'AzureManagedInstance_dbmail_profile',
--    @account_name = 'Kevro Notification',
--    @sequence_number = 1;


--     EXEC sp_configure 'show advanced options', 1;  
--GO  
--RECONFIGURE;  
--GO  
--EXEC sp_configure 'Database Mail XPs', 1;  
--GO  
--RECONFIGURE  
--GO  


 DECLARE @body VARCHAR(4000) = 'The email is sent with msdb.dbo.sp_send_dbmail from ' + @@SERVERNAME;
EXEC msdb.dbo.sp_send_dbmail 
        @profile_name = 'AzureManagedInstance_dbmail_profile', 
        @recipients = @loginemail ,
        @body = @body, 
        @subject = 'Azure SQL Instance - test email' ;


--        EXEC msdb.dbo.sp_add_operator 
--          @name = N'SQL DevOp', 
--          @enabled = 1, 
--          @email_address = N'$(email)', 
--          @weekday_pager_start_time = 080000, 
--          @weekday_pager_end_time = 170000, 
--          @pager_days = 62 ;
--Then, you can send an email notification to the operator:


--Copy
-- DECLARE @body VARCHAR(4000) = 'The email is sent using sp_notify_operator from ' + @@SERVERNAME;
--EXEC msdb.dbo.sp_notify_operator 
--              @profile_name = N'AzureManagedInstance_dbmail_profile', 
--              @name = N'SQL DevOp', 
--              @subject = N'Azure SQL Instance - Test Notification', 
--              @body = @body;
--Again, the important thing here is that you need to specify AzureManagedInstance_dbmail_profile as the email profile that will be used to send the notifications.

--Job notifications
--Managed Instance enables you to notify an operator via email when a job succeeds or fails using the following script:


--Copy
-- EXEC msdb.dbo.sp_update_job
--              @job_name=N'My job name', 
--              @notify_level_email=2, 
--              @notify_level_page=2, 
--              @notify_email_operator_name=N'SQL DevOp'