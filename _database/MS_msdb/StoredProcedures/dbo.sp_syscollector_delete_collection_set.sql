SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_collection_set]
    @collection_set_id            int = NULL,
    @name                        sysname = NULL
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    -- Security check (role membership)
    EXECUTE AS CALLER;
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        REVERT;
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN (1)
    END
    REVERT;

    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    DECLARE @is_system            bit
    DECLARE @is_running            bit
    DECLARE @upload_job_id        uniqueidentifier
    DECLARE @collection_job_id    uniqueidentifier
    DECLARE @collection_mode    smallint
    SELECT    @is_running = is_running,
            @is_system = is_system,
            @upload_job_id = upload_job_id, 
            @collection_job_id = collection_job_id,
            @collection_mode = collection_mode
    FROM [dbo].[syscollector_collection_sets]
    WHERE collection_set_id = @collection_set_id

    IF (@is_system = 1)
    BEGIN
        -- cannot update, delete, or add new collection items to a system collection set
        RAISERROR(14696, -1, -1);
        RETURN (1)
    END

    IF (@is_running = 1)
    BEGIN
        EXEC @retVal = sp_syscollector_stop_collection_set @collection_set_id = @collection_set_id
        IF (@retVal <> 0)
            RETURN (1)
    END

    -- All checks are go
    -- Do the actual delete
    EXEC @retVal = sp_syscollector_delete_collection_set_internal
                        @collection_set_id = @collection_set_id, 
                        @name = @name,
                        @collection_job_id = @collection_job_id,
                        @upload_job_id = @upload_job_id,
                        @collection_mode = @collection_mode
    RETURN (0)
END

GO
