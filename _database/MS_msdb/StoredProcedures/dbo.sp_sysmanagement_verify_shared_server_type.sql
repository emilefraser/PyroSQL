SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_verify_shared_server_type]
    @server_type INT
AS
BEGIN
    IF (@server_type IS NULL)
    BEGIN
        RAISERROR (35009, -1, -1)
        RETURN(1)
    END
    
    -- 0 --> DatabaseEngineServerGroup, 1 --> AnalysisServicesServerGroup, 2 --> ReportingServicesServerGroup, 3 --> IntegrationServicesServerGroup, 4 --> SqlServerCompactEditionServerGroup
    IF (@server_type < 0 OR @server_type > 4)
    BEGIN
        RAISERROR (35010, -1, -1, @server_type)
        RETURN (1)
    END
    
    RETURN (0)
END

GO
