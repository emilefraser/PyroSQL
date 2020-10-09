SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- sp_sysmail_activate : Starts the DatabaseMail process if it isn't already running
--
CREATE PROCEDURE [dbo].[sp_sysmail_activate]
AS
BEGIN
    DECLARE @mailDbName sysname
    DECLARE @mailDbId INT
    DECLARE @mailEngineLifeMin INT
    DECLARE @loggingLevel nvarchar(256)
    DECLARE @loggingLevelInt int   
    DECLARE @parameter_value nvarchar(256)
    DECLARE @localmessage nvarchar(max)
    DECLARE @readFromConfigFile INT
    DECLARE @rc INT

    SET NOCOUNT ON
    EXEC sp_executesql @statement = N'RECEIVE TOP(0) * FROM msdb.dbo.ExternalMailQueue'

    EXEC @rc = msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'DatabaseMailExeMinimumLifeTime', 
                                                        @parameter_value = @parameter_value OUTPUT
    IF(@rc <> 0)
        RETURN (1)

    --ConvertToInt will return the default if @parameter_value is null or config value can't be converted
    --Setting max exe lifetime is 1 week (604800 secs). Can't see a reason for it to ever run longer that this
    SET @mailEngineLifeMin = dbo.ConvertToInt(@parameter_value, 604800, 600) 

    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'ReadFromConfigurationFile', 
                                                  @parameter_value = @parameter_value OUTPUT
    --Try to read the optional read from configuration file:
    SET @readFromConfigFile = dbo.ConvertToInt(@parameter_value, 1, 0) 

    --Try and get the optional logging level for the DatabaseMail process
    EXEC msdb.dbo.sysmail_help_configure_value_sp @parameter_name = N'LoggingLevel', 
                                                  @parameter_value = @loggingLevel OUTPUT

    --Convert logging level into string value for passing into XP
    SET @loggingLevelInt = dbo.ConvertToInt(@loggingLevel, 3, 2) 
    IF @loggingLevelInt = 1
       SET @loggingLevel = 'Normal'
    ELSE IF @loggingLevelInt = 3
       SET @loggingLevel = 'Verbose'
    ELSE -- default
       SET @loggingLevel = 'Extended'

    SET @mailDbName = DB_NAME()
    SET @mailDbId   = DB_ID()

    EXEC @rc = master..xp_sysmail_activate @mailDbId, @mailDbName, @readFromConfigFile,
    @mailEngineLifeMin, @loggingLevel
    IF(@rc <> 0)
    BEGIN
        SET @localmessage = FORMATMESSAGE(14637)
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=3, @description=@localmessage
    END
    ELSE
    BEGIN
        SET @localmessage = FORMATMESSAGE(14638)
        exec msdb.dbo.sysmail_logmailevent_sp @event_type=0, @description=@localmessage
    END

    RETURN @rc
END

GO
