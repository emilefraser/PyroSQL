SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_configure_sql_dumper]
    @collection_set_id        int = NULL,
    @name                    sysname = NULL,
    @dump_on_any_error      bit = NULL,                -- configure SQL dumper to dump on any SSIS errors
    @dump_on_codes          nvarchar(max) = NULL    -- configure SQL dumper to dump when we hit one of the specified SSIS errors. Set to N'' to remove the codes.
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN(1) -- Failure
    END

    DECLARE @retVal int
    EXEC @retVal = dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
    IF (@retVal <> 0)
        RETURN (1)

    DECLARE @is_running bit
    SELECT    @is_running = is_running
    FROM dbo.syscollector_collection_sets
    WHERE collection_set_id = @collection_set_id
    IF (@is_running = 1)
    BEGIN
        RAISERROR(14711, 0, 1)
    END

    IF (@dump_on_codes = N'')
    BEGIN
        UPDATE [dbo].[syscollector_collection_sets_internal]
        SET dump_on_codes = NULL
        WHERE @collection_set_id = collection_set_id
    END
    ELSE IF (@dump_on_codes IS NOT NULL)
    BEGIN
        UPDATE [msdb].[dbo].[syscollector_collection_sets_internal]
        SET dump_on_codes = @dump_on_codes
        WHERE @collection_set_id = collection_set_id
    END    

    IF (@dump_on_any_error IS NOT NULL)
    BEGIN
        UPDATE [msdb].[dbo].[syscollector_collection_sets_internal]
        SET dump_on_any_error = @dump_on_any_error
        WHERE @collection_set_id = collection_set_id
    END

    RETURN (0)
END

GO
