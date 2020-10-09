SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syspolicy_set_config_enabled] 
	@value sql_variant
AS
BEGIN
	DECLARE @retval_check int;
	
	SET NOCOUNT ON
	
	EXECUTE @retval_check = [dbo].[sp_syspolicy_check_membership] 'PolicyAdministratorRole'
	IF ( 0!= @retval_check)
	BEGIN
		RETURN @retval_check
	END
    
    DECLARE @val bit;
    SET @val = CONVERT(bit, @value);
    IF (@val = 1)
    BEGIN
	    DECLARE @engine_edition INT
		SELECT @engine_edition = CAST(SERVERPROPERTY('EngineEdition') AS INT)
		IF @engine_edition = 4 -- All SQL Express types + embedded
		BEGIN
			RAISERROR (34054, 16, 1)			
            RETURN 34054
		END
		
	    UPDATE [msdb].[dbo].[syspolicy_configuration_internal]
	    SET current_value = @value
	    WHERE name = N'Enabled';
    
        -- enable policy automation
        ALTER QUEUE [syspolicy_event_queue] WITH ACTIVATION (STATUS = ON)

        EXEC sys.sp_syspolicy_update_ddl_trigger;
        EXEC sys.sp_syspolicy_update_event_notification;
    END
    ELSE
    BEGIN
	    UPDATE [msdb].[dbo].[syspolicy_configuration_internal]
	    SET current_value = @value
	    WHERE name = N'Enabled';

        -- disable policy automation
        ALTER QUEUE [syspolicy_event_queue] WITH ACTIVATION (STATUS = OFF)

        IF EXISTS (SELECT * FROM sys.server_event_notifications WHERE name = N'syspolicy_event_notification')
	        DROP EVENT NOTIFICATION [syspolicy_event_notification] ON SERVER 

        IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = N'syspolicy_server_trigger')
            DISABLE TRIGGER [syspolicy_server_trigger] ON ALL SERVER 
    END

END

GO
