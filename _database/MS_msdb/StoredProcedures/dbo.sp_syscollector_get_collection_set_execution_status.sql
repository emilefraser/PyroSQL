SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_get_collection_set_execution_status]
    @collection_set_id            int,
    @is_running                    int = NULL OUTPUT,
    @is_collection_running        int = NULL OUTPUT,
    @collection_job_state        int = NULL OUTPUT,
    @is_upload_running            int = NULL OUTPUT,
    @upload_job_state            int = NULL OUTPUT
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    DECLARE @TranCounter INT
    SET @TranCounter = @@TRANCOUNT
    IF (@TranCounter > 0)
        SAVE TRANSACTION tran_get_execution_status
    ELSE
        BEGIN TRANSACTION

    BEGIN TRY

    DECLARE @xp_results TABLE (job_id             UNIQUEIDENTIFIER NOT NULL,
                            last_run_date         INT              NOT NULL,
                            last_run_time         INT              NOT NULL,
                            next_run_date         INT              NOT NULL,
                            next_run_time         INT              NOT NULL,
                            next_run_schedule_id  INT              NOT NULL,
                            requested_to_run      INT              NOT NULL, -- BOOL
                            request_source        INT              NOT NULL,
                            request_source_id     sysname          COLLATE database_default NULL,
                            running               INT              NOT NULL, -- BOOL
                            current_step          INT              NOT NULL,
                            current_retry_attempt INT              NOT NULL,
                            job_state             INT              NOT NULL)


    DECLARE @is_sysadmin INT
    SELECT @is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0)

    DECLARE @collection_job_id UNIQUEIDENTIFIER
    DECLARE @upload_job_id UNIQUEIDENTIFIER
    
    SELECT @collection_job_id = collection_job_id, @upload_job_id = upload_job_id 
    FROM dbo.syscollector_collection_sets WHERE collection_set_id = @collection_set_id

    DECLARE @agent_enabled int
    SELECT @agent_enabled = CAST(value_in_use AS int) FROM sys.configurations WHERE name = N'Agent XPs'

    --  initialize to 0  == not running state; when agent XPs are disabled, call to xp_sqlagent_enum_jobs is never made in 
    -- code below.  When Agent Xps are disabled agent would not be running, in this case, jobs will also be in 'not running" state
    SET @is_collection_running = 0  
    SET @is_upload_running = 0
    SET @collection_job_state = 0
    SET @upload_job_state = 0

    IF (@agent_enabled <> 0)
    BEGIN
        INSERT  INTO @xp_results    
        EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, N'', @upload_job_id

        INSERT  INTO @xp_results    
        EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, N'', @collection_job_id

        SELECT @is_collection_running = running, 
        @collection_job_state = job_state 
        FROM @xp_results WHERE job_id = @collection_job_id

        SELECT @is_upload_running = running, 
        @upload_job_state = job_state 
        FROM @xp_results WHERE job_id = @upload_job_id
    END

    SELECT @is_running = is_running FROM dbo.syscollector_collection_sets WHERE collection_set_id = @collection_set_id

    IF (@TranCounter = 0)
        COMMIT TRANSACTION
    RETURN (0)

    END TRY
    BEGIN CATCH
        IF (@TranCounter = 0 OR XACT_STATE() = -1)
            ROLLBACK TRANSACTION
        ELSE IF (XACT_STATE() = 1)
            ROLLBACK TRANSACTION tran_get_execution_status

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
