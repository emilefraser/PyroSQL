SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_create_collection_set]
    @name                        sysname,
    @target                        nvarchar(128) = NULL,
    @collection_mode            smallint = 0,    -- 0: cached, 1: non-cached
    @days_until_expiration      smallint = 730, -- two years
    @proxy_id                   int = NULL,     -- mutual exclusive; must specify either proxy_id or proxy_name to identify the proxy
    @proxy_name                    sysname = NULL,
    @schedule_uid               uniqueidentifier = NULL, 
    @schedule_name              sysname = NULL, -- mutual exclusive; must specify either schedule_uid or schedule_name to identify the schedule
    @logging_level                smallint = 1,
    @description                nvarchar(4000) = NULL,
    @collection_set_id            int OUTPUT,
    @collection_set_uid            uniqueidentifier = NULL OUTPUT
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_create_collection_set
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY

    -- Security check (role membership)
    EXECUTE AS CALLER;
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT;
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END
    REVERT;

    -- Remove any leading/trailing spaces from parameters
    SET @name                    = NULLIF(LTRIM(RTRIM(@name)), N'')
    SET @proxy_name                = NULLIF(LTRIM(RTRIM(@proxy_name)), N'')
    SET @schedule_name            = NULLIF(LTRIM(RTRIM(@schedule_name)), N'')
    SET @target                    = NULLIF(LTRIM(RTRIM(@target)), N'')
    SET @description            = LTRIM(RTRIM(@description))

    IF (@name IS NULL)
    BEGIN
        RAISERROR(21263, -1, -1, '@name')
        RETURN (1)
    END

    -- can't have both name and uid for the schedule
    IF (@schedule_uid IS NOT NULL) AND (@schedule_name IS NOT NULL)
    BEGIN
        RAISERROR(14373, -1, -1, '@schedule_uid', '@schedule_name')
        RETURN (1)
    END

    -- Execute the check for the schedule as caller to ensure only schedules owned by caller can be attached
    EXECUTE AS CALLER;

    DECLARE @schedule_id int
    IF (@schedule_uid IS NOT NULL)
    BEGIN
        SElECT @schedule_id = schedule_id FROM sysschedules_localserver_view WHERE @schedule_uid = schedule_uid
    
        IF (@schedule_id IS NULL)
        BEGIN
            DECLARE @schedule_uid_as_char VARCHAR(36)
            SELECT @schedule_uid_as_char = CONVERT(VARCHAR(36), @schedule_uid)
            REVERT;
            RAISERROR(14262, -1, -1, N'@schedule_uid', @schedule_uid_as_char)
            RETURN (1)
        END
    END
    ELSE IF (@schedule_name IS NOT NULL)
    BEGIN
        SELECT @schedule_id = schedule_id, @schedule_uid = schedule_uid FROM sysschedules_localserver_view WHERE name = @schedule_name 
    
        IF (@schedule_id IS NULL)
        BEGIN
            REVERT;
            RAISERROR(14262, -1, -1, N'@schedule_name', @schedule_name)
            RETURN (1)
        END
    END

    REVERT;

    -- if collection_mode is cached, make sure schedule_id is not null
    IF    (@collection_mode = 0 AND @schedule_id IS NULL)
    BEGIN
        RAISERROR(14683, -1, -1)    
        RETURN (1)
    END    

    IF (@proxy_id IS NOT NULL) OR (@proxy_name IS NOT NULL) 
    BEGIN
        -- check if the proxy exists
        EXEC sp_verify_proxy_identifiers '@proxy_name',
                                         '@proxy_id',
                                         @proxy_name OUTPUT,
                                         @proxy_id   OUTPUT

        -- check if proxy_id is granted to dc_admin
        IF (@proxy_id NOT IN (SELECT proxy_id 
                              FROM sysproxylogin 
                              WHERE sid = USER_SID(USER_ID('dc_admin'))
                              )
            )
        BEGIN
            RAISERROR(14719, -1, -1, N'dc_admin')
            RETURN (1)
        END
    END

    IF (@collection_mode < 0 OR @collection_mode > 1)
    BEGIN
        RAISERROR(14266, -1, -1, '@collection_mode', '0, 1')
        RETURN (1)
    END

    IF (@logging_level < 0 OR @logging_level > 2)
    BEGIN
        RAISERROR(14266, -1, -1, '@logging_level', '0, 1, or 2')
        RETURN (1)
    END

    IF (@collection_set_uid IS NULL)
    BEGIN
        SET @collection_set_uid = NEWID()
    END

    IF (@days_until_expiration < 0)
    BEGIN
        RAISERROR(14266, -1, -1, '@days_until_expiration', '>= 0')
        RETURN (1)
    END

    INSERT INTO [dbo].[syscollector_collection_sets_internal]
    (
        collection_set_uid,
        schedule_uid,
        name,
        target,
        is_running,
        proxy_id,
        is_system,
        upload_job_id,
        collection_job_id,
        collection_mode,
        logging_level,
        days_until_expiration,
        description
    )
    VALUES
    (
        @collection_set_uid,
        @schedule_uid,
        @name,
        @target,
        0,
        @proxy_id,
        0,
        NULL,
        NULL,
        @collection_mode,
        @logging_level,
        @days_until_expiration,
        @description
    )

    SET @collection_set_id = SCOPE_IDENTITY()

    IF (@collection_set_id IS NULL)
    BEGIN
        DECLARE @collection_set_id_as_char VARCHAR(36)
        SELECT @collection_set_id_as_char = CONVERT(VARCHAR(36), @collection_set_id)
        RAISERROR(14262, -1, -1, '@collection_set_id', @collection_set_id_as_char)
        RETURN (1)
    END

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_create_collection_set

        DECLARE @ErrorMessage   NVARCHAR(4000);
        DECLARE @ErrorSeverity  INT;
        DECLARE @ErrorState     INT;
        DECLARE @ErrorNumber    INT;
        DECLARE @ErrorLine      INT;
        DECLARE @ErrorProcedure NVARCHAR(200);
        SELECT @ErrorLine = ERROR_LINE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorNumber = ERROR_NUMBER(),
               @ErrorMessage = ERROR_MESSAGE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
        RAISERROR (14684, @ErrorSeverity, -1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);

        RETURN (1)        
    END CATCH
END

GO
