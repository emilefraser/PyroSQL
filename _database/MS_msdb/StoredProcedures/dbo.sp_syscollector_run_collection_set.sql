SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_run_collection_set]
    @collection_set_id        int = NULL,
    @name                     sysname = NULL
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_run_collection_set
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY


    -- Security check (role membership)
    EXECUTE AS CALLER;
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT;
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END
    REVERT;

    -- Verify the input parameters
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    -- Make sure the collection set is in the right mode
    DECLARE @collection_mode smallint
    DECLARE @collection_set_uid uniqueidentifier;

    SELECT 
        @collection_set_uid = collection_set_uid,
        @collection_mode = collection_mode            
    FROM [dbo].[syscollector_collection_sets]
    WHERE collection_set_id = @collection_set_id

    IF (@collection_mode <> 1)
    BEGIN
        RAISERROR(14695, -1, -1, @name)
        RETURN(1)
    END


    -- Make sure the collector is enabled
    EXEC @retVal = [dbo].[sp_syscollector_verify_collector_state] @desired_state = 1
    IF (@retVal <> 0)
        RETURN (1)

    -- check if SQL Server Agent is enabled
    DECLARE @agent_enabled int
    SELECT @agent_enabled = CAST(value_in_use AS int) FROM sys.configurations WHERE name = N'Agent XPs'
    IF @agent_enabled <> 1
    BEGIN
        RAISERROR(14688, -1, -1)
        RETURN (1)
    END

    -- check if MDW is setup
    DECLARE @instance_name sysname
    SELECT @instance_name = CONVERT(sysname,parameter_value)
    FROM [msdb].[dbo].[syscollector_config_store_internal]
    WHERE parameter_name = N'MDWInstance'
    IF (@instance_name IS NULL)
    BEGIN
        RAISERROR(14689, -1, -1)
        RETURN (1)
    END    
    DECLARE @database_name sysname
    SELECT @database_name = CONVERT(sysname,parameter_value)
    FROM [msdb].[dbo].[syscollector_config_store_internal]
    WHERE parameter_name = N'MDWDatabase'
    IF (@database_name IS NULL)
    BEGIN
        RAISERROR(14689, -1, -1)
        RETURN (1)
    END

    -- Make sure the jobs are created for the collection set
    -- Verify the input parameters
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    -- Check if the collection set does not have any collection items
    IF NOT EXISTS(
        SELECT i.collection_item_id 
        FROM [dbo].[syscollector_collection_sets] AS s
        INNER JOIN [dbo].[syscollector_collection_items] AS i
            ON(s.collection_set_id = i.collection_set_id)
        WHERE s.collection_set_id = @collection_set_id
    )
    BEGIN
        RAISERROR(14685, 10, -1, @name) -- Raise a warning message
        IF (@TranCounter = 0)
            COMMIT TRANSACTION
        RETURN (0)
    END

    DECLARE @proxy_id int;
    DECLARE @collection_job_id uniqueidentifier
    DECLARE @upload_job_id uniqueidentifier

    SELECT @collection_job_id = collection_job_id, 
           @upload_job_id = upload_job_id, 
           @proxy_id = proxy_id
    FROM [dbo].[syscollector_collection_sets_internal]
    WHERE collection_set_id = @collection_set_id;

    -- Check if the set does not have a proxy
    IF (@proxy_id IS NULL)
    BEGIN
        -- to start a collection set without a proxy, the caller has to be a sysadmin
        EXECUTE AS CALLER;
            IF (NOT (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1))
            BEGIN
                REVERT;
                RAISERROR(14692, -1, -1, @name)
                RETURN (1)
            END
        REVERT;
    END

    -- Check if we have jobs created, and if not, create them
    DECLARE @jobs_just_created bit
    SET @jobs_just_created = 0  -- False until further notice
    IF (@collection_job_id IS NULL AND @upload_job_id IS NULL)
    BEGIN
        DECLARE @schedule_id int;
        DECLARE @schedule_uid uniqueidentifier;

        SELECT 
            @schedule_uid = schedule_uid
        FROM [dbo].[syscollector_collection_sets_internal]
        WHERE collection_set_id = @collection_set_id;
        
        IF (@schedule_uid IS NOT NULL)
        BEGIN
            SELECT @schedule_id = schedule_id FROM sysschedules_localserver_view WHERE @schedule_uid = schedule_uid
        END

        -- Sanity check
        -- Make sure the proxy and schedule are still there, someone could have
        -- remove them between when the collection set was created and now.
        IF (@proxy_id IS NOT NULL)
        BEGIN
            DECLARE @proxy_name sysname
            
            -- this will throw an error of proxy_id does not exist
            EXEC @retVal = msdb.dbo.sp_verify_proxy_identifiers '@proxy_name', '@proxy_id', @proxy_name OUTPUT, @proxy_id OUTPUT
            IF (@retVal <> 0)
                RETURN (0)
        END

        IF (@schedule_uid IS NOT NULL)
        BEGIN
            EXEC @retVal = sp_verify_schedule_identifiers  @name_of_name_parameter = '@schedule_name',
                                                           @name_of_id_parameter   = '@schedule_id',
                                                           @schedule_name          = NULL,
                                                           @schedule_id            = @schedule_id,
                                                           @owner_sid              = NULL,
                                                           @orig_server_id         = NULL 
            IF (@retVal <> 0)
                RETURN (1)
        END

        -- Go add the jobs
        EXEC [dbo].[sp_syscollector_create_jobs]
            @collection_set_id    = @collection_set_id,
            @collection_set_uid = @collection_set_uid,
            @collection_set_name = @name,
            @proxy_id            = @proxy_id,
            @schedule_id        = @schedule_id,
            @collection_mode    = @collection_mode,
            @collection_job_id    = @collection_job_id OUTPUT,
            @upload_job_id        = @upload_job_id OUTPUT

        -- Finally, update the collection_sets table
        UPDATE [dbo].[syscollector_collection_sets_internal]
        SET
            upload_job_id        = @upload_job_id,
            collection_job_id    = @collection_job_id
        WHERE @collection_set_id = collection_set_id

        SET @jobs_just_created = 1  -- Record the fact that we have just created the job here
    END

    IF (@jobs_just_created = 1)
    BEGIN  -- We created the jobs here in this transaction, post a request for agent to start as soon as we commit
        EXEC @retVal = sp_start_job @job_id = @upload_job_id
        IF (@retVal <> 0)
            RETURN (1)
    END
    ELSE   
    BEGIN
        -- The jobs were created previously, we need to guard against it already executing by the schedule
        -- So, check if the job is currently running before asking agent to start it
        DECLARE @is_upload_job_running INT
        EXECUTE [dbo].[sp_syscollector_get_collection_set_execution_status]
            @collection_set_id = @collection_set_id,
            @is_upload_running = @is_upload_job_running OUTPUT

        IF (@is_upload_job_running = 0)
        BEGIN
            -- Job is not running, we can trigger it now
            -- We run only one job because for this (non-cached) mode there is only one job. The same id is stored
            -- as collection and upload job id
            EXEC @retVal = sp_start_job @job_id = @upload_job_id
            IF (@retVal <> 0)
                RETURN (1)
        END
    END

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_run_collection_set

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
