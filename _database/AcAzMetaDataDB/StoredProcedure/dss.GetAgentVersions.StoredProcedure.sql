SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetAgentVersions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetAgentVersions] AS' 
END
GO
ALTER PROCEDURE [dss].[GetAgentVersions]
    AS
BEGIN
    SELECT
        [Id],
        [Version],
        [ExpiresOn],
        [Comment]

    FROM [dss].[agent_version]
END
GO
