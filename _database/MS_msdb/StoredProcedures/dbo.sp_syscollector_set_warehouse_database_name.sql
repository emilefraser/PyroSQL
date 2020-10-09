SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_set_warehouse_database_name]
    @database_name                    sysname = NULL
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_admin'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_admin')
        RETURN(1) -- Failure
    END

    -- Check if the collector is disabled
    DECLARE @retVal int
    EXEC @retVal = [dbo].[sp_syscollector_verify_collector_state] @desired_state = 0
    IF (@retVal <> 0)
        RETURN (1)

    UPDATE [msdb].[dbo].[syscollector_config_store_internal]
    SET parameter_value = @database_name
    WHERE parameter_name = N'MDWDatabase'

    RETURN (0)
END

GO
