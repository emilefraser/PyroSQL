SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_upload_collection_set]
    @collection_set_id        int = NULL,
    @name                     sysname = NULL
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    SET NOCOUNT ON

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

    -- Make sure the collection set is running and is in the right mode
    DECLARE @is_running bit
    DECLARE @collection_mode smallint

    SELECT 
        @is_running = is_running,
        @collection_mode = collection_mode            
    FROM [dbo].[syscollector_collection_sets]
    WHERE collection_set_id = @collection_set_id

    IF (@collection_mode <> 0)
    BEGIN
        RAISERROR(14694, -1, -1, @name)
        RETURN(1)
    END

    IF (@is_running = 0)
    BEGIN
        RAISERROR(14674, -1, -1, @name)
        RETURN(1)
    END

    -- Make sure the collector is enabled
    EXEC @retVal = [dbo].[sp_syscollector_verify_collector_state] @desired_state = 1
    IF (@retVal <> 0)
        RETURN (1)

    -- Check if the upload job is currently running
    DECLARE @is_upload_job_running INT
    EXECUTE [dbo].[sp_syscollector_get_collection_set_execution_status]
        @collection_set_id = @collection_set_id,
        @is_upload_running = @is_upload_job_running OUTPUT

    IF (@is_upload_job_running = 0)
    BEGIN
        -- Job is not running, we can trigger it now
        DECLARE @job_id UNIQUEIDENTIFIER
        SELECT @job_id = upload_job_id 
            FROM [dbo].[syscollector_collection_sets] 
            WHERE collection_set_id = @collection_set_id

        EXEC @retVal = sp_start_job @job_id = @job_id
        IF (@retVal <> 0)
            RETURN (1)
    END

    RETURN (0)
END

GO
