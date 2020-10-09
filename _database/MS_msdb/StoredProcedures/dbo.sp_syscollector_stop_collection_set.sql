SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_stop_collection_set]
    @collection_set_id        int = NULL,
    @name                     sysname = NULL,
    @stop_collection_job      bit = 1           -- Do we need to stop the collection job, YES by default
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END

    -- Verify the input parameters
    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    IF (@stop_collection_job = 1)
    BEGIN
        DECLARE @collection_mode INT
        DECLARE @collection_job_id UNIQUEIDENTIFIER

        SELECT  @collection_mode = collection_mode, @collection_job_id = collection_job_id
        FROM    dbo.syscollector_collection_sets
        WHERE   collection_set_id = @collection_set_id
       
        DECLARE @is_collection_job_running INT
        EXECUTE [dbo].[sp_syscollector_get_collection_set_execution_status]
                @collection_set_id = @collection_set_id,
                @is_collection_running = @is_collection_job_running OUTPUT

        -- Stop the collection job if we are in cached mode, this should signal the runtime to exit
        IF (@is_collection_job_running = 1      -- Collection job is running
            AND @collection_mode = 0
            AND @stop_collection_job = 1)
        BEGIN
            EXEC sp_stop_job @job_id = @collection_job_id
        END
    END


    -- Update the is_running column for this collection set
    -- There is a trigger defined for that table that turns off
    -- the collection and uplaod jobs in response to that bit
    -- changing.
    UPDATE [dbo].[syscollector_collection_sets_internal]
    SET is_running = 0
    WHERE collection_set_id = @collection_set_id

    RETURN (0)
END

GO
