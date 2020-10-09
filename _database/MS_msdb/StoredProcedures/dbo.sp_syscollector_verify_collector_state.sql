SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_verify_collector_state]
    @desired_state          int
WITH EXECUTE AS OWNER -- 'MS_DataCollectorInternalUser'
AS
BEGIN
    DECLARE @collector_enabled      INT
    SET @collector_enabled = CONVERT(int, (SELECT parameter_value FROM dbo.syscollector_config_store_internal
                            WHERE parameter_name = 'CollectorEnabled'))

    IF (@collector_enabled IS NULL)
    BEGIN
        RAISERROR(14691, -1, -1)
        RETURN(1)
    END

    IF (@collector_enabled = 0) AND (@desired_state = 1)
    BEGIN
        RAISERROR(14681, -1, -1)
        RETURN(1)
    END

    IF (@collector_enabled = 1) AND (@desired_state = 0)
    BEGIN
        RAISERROR(14690, -1, -1)
        RETURN(1)
    END

    RETURN(0)
END

GO
