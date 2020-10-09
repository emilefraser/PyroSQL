SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_update_collection_set]
    @collection_set_id        int = NULL,
    @name                    sysname = NULL,
    @new_name                sysname = NULL,
    @target                    nvarchar(128) = NULL,
    @collection_mode        smallint = NULL,         -- 0: cached, 1: non-cached
    @days_until_expiration  smallint = NULL,
    @proxy_id               int = NULL,              -- mutual exclusive; must specify either proxy_id or proxy_name to identify the proxy
    @proxy_name             sysname = NULL,          -- @proxy_name = N'' is a special case to allow change of an existing proxy with NULL
    @schedule_uid           uniqueidentifier = NULL, -- mutual exclusive; must specify either schedule_uid or schedule_name to identify the schedule
    @schedule_name          sysname = NULL,          -- @schedule_name = N'' is a special case to allow change of an existing schedule with NULL
    @logging_level            smallint = NULL,
    @description            nvarchar(4000) = NULL   -- @description = N'' is a special case to allow change of an existing description with NULL
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    -- Security checks will be performed against caller's security context
    EXECUTE AS CALLER;

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT;
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN (1)
    END

    -- Security checks (restrict functionality for non-dc_admin-s)
    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@new_name IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@new_name', 'dc_admin')
        RETURN (1)
    END

    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@target IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@target', 'dc_admin')
        RETURN (1)
    END

    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@proxy_id IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@proxy_id', 'dc_admin')
        RETURN (1)
    END

    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@collection_mode IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@collection_mode', 'dc_admin')
        RETURN (1)
    END

    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@description IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@description', 'dc_admin')
        RETURN (1)
    END

    IF (((NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1)) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
        AND (@days_until_expiration IS NOT NULL))
    BEGIN
        REVERT;
        RAISERROR(14676, -1, -1, '@days_until_expiration', 'dc_admin')
        RETURN (1) -- Failure
    END

    -- Security checks done, reverting now to internal data collector user security context
    REVERT;

    -- check for inconsistencies/errors in the parameters
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    IF (@collection_mode IS NOT NULL AND (@collection_mode < 0 OR @collection_mode > 1))
    BEGIN
        RAISERROR(14266, -1, -1, '@collection_mode', '0, 1')
        RETURN (1)
    END

    IF (@logging_level IS NOT NULL AND (@logging_level < 0 OR @logging_level > 2))
    BEGIN
        RAISERROR(14266, -1, -1, '@logging_level', '0, 1, or 2')
        RETURN(1)
    END

    IF (LEN(@new_name) = 0)
    BEGIN
      RAISERROR(21263, -1, -1, '@new_name')
      RETURN(1) -- Failure
    END    

    -- Remove any leading/trailing spaces from parameters
    SET @target                    = NULLIF(LTRIM(RTRIM(@target)), N'')
    SET @new_name                = NULLIF(LTRIM(RTRIM(@new_name)), N'')
    SET @description            = LTRIM(RTRIM(@description))
    
    DECLARE @is_system                    bit
    DECLARE @is_running                    bit
    DECLARE @collection_set_uid            uniqueidentifier
    DECLARE @old_collection_mode        smallint
    DECLARE @old_upload_job_id            uniqueidentifier
    DECLARE @old_collection_job_id        uniqueidentifier
    DECLARE @old_proxy_id                int

    SELECT    @is_running = is_running,
            @is_system = is_system,
            @collection_set_uid = collection_set_uid,
            @old_collection_mode = collection_mode,
            @old_collection_job_id = collection_job_id, 
            @old_upload_job_id = upload_job_id,
            @old_proxy_id = proxy_id
    FROM dbo.syscollector_collection_sets
    WHERE collection_set_id = @collection_set_id

    IF (@is_system = 1 AND (
            @new_name IS NOT NULL OR 
            @description IS NOT NULL))
    BEGIN
        -- cannot update, delete, or add new collection items to a system collection set
        RAISERROR(14696, -1, -1);
        RETURN (1)
    END
    
    IF (@proxy_id IS NOT NULL) OR (@proxy_name IS NOT NULL AND @proxy_name <> N'')
    BEGIN
        -- verify the proxy exists
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
    ELSE -- if no proxy_id provided, get the existing proxy_id, might need it later to create new jobs
    BEGIN
        SET @proxy_id = @old_proxy_id
    END

    -- can't have both uid and name passed for the schedule
    IF (@schedule_uid IS NOT NULL) AND (@schedule_name IS NOT NULL AND @schedule_name <> N'')
    BEGIN
        RAISERROR(14373, -1, -1, '@schedule_uid', '@schedule_name')
        RETURN (1)
    END

    -- check if it attempts to remove a schedule when the collection mode is cached
    IF    (@schedule_name = N'' AND @collection_mode = 0)    OR 
        (@collection_mode IS NULL AND @old_collection_mode = 0 AND @schedule_name = N'')
    BEGIN
        RAISERROR(14683, -1, -1)    
        RETURN (1)
    END    

    -- Execute the check for the schedule as caller to ensure only schedules owned by caller can be attached
    EXECUTE AS CALLER;

    DECLARE @schedule_id int
    SET @schedule_id = NULL
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
    ELSE IF (@schedule_name IS NOT NULL AND @schedule_name <> N'') -- @schedule_name is not null
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
    
    -- Stop the collection set if it is currently running
    IF (@is_running = 1 AND (
            @new_name IS NOT NULL OR 
            @target IS NOT NULL OR 
            @proxy_id IS NOT NULL OR 
            @logging_level IS NOT NULL OR 
            @collection_mode IS NOT NULL))
    BEGIN
        EXEC @retVal = sp_syscollector_stop_collection_set @collection_set_id = @collection_set_id
        IF (@retVal <> 0)
            RETURN (1)
    END

    -- Passed all necessary checks, go ahead with the update
    EXEC @retVal = sp_syscollector_update_collection_set_internal
        @collection_set_id = @collection_set_id,
        @collection_set_uid = @collection_set_uid,
        @name = @name,
        @new_name = @new_name,
        @target = @target,
        @collection_mode = @collection_mode,
        @days_until_expiration = @days_until_expiration,
        @proxy_id = @proxy_id,
        @proxy_name = @proxy_name,
        @schedule_uid = @schedule_uid,
        @schedule_name = @schedule_name,
        @logging_level = @logging_level,
        @description = @description,
        @schedule_id = @schedule_id,
        @old_collection_mode = @old_collection_mode,
        @old_proxy_id = @old_proxy_id,
        @old_collection_job_id = @old_collection_job_id,
        @old_upload_job_id = @old_upload_job_id
            
     IF (@retVal <> 0)
        RETURN (1)
        
     -- Restart the collection set if it has been already running
     IF (@is_running = 1)
     BEGIN
         EXEC @retVal = sp_syscollector_start_collection_set
                            @collection_set_id = @collection_set_id
         IF (@retVal <> 0)
            RETURN (1)
     END
        
     RETURN (0)
END

GO
