SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetAgentCredentials]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetAgentCredentials] AS' 
END
GO
ALTER PROCEDURE [dss].[GetAgentCredentials]
    @AgentID	UNIQUEIDENTIFIER
AS
BEGIN

    SELECT
        [id],
        [password_hash],
        [password_salt]
    FROM [dss].[agent]
    WHERE [id] = @AgentID

END
GO
