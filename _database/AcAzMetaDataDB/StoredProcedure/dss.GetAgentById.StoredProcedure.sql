SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetAgentById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetAgentById] AS' 
END
GO
ALTER PROCEDURE [dss].[GetAgentById]
    @AgentId	UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
        [id],
        [name],
        [subscriptionid],
        [state],
        [lastalivetime],
        [is_on_premise],
        [version],
        [password_hash],
        [password_salt]
    FROM [dss].[agent]
    WHERE [id] = @AgentId
END
GO
