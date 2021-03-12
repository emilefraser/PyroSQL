SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[IsAgentInstanceValid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[IsAgentInstanceValid]
(
    @AgentId			UNIQUEIDENTIFIER,
    @AgentInstanceId	UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM [dss].[agent_instance] WHERE [id] = @AgentInstanceId AND [agentid] = @AgentId)
    BEGIN
        RETURN 1
    END

    RETURN 0
END' 
END
GO
