SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetAgentCredentials]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetAgentCredentials] AS' 
END
GO
ALTER PROCEDURE [dss].[SetAgentCredentials]
    @AgentID	UNIQUEIDENTIFIER,
    @PasswordHash	[dss].[PASSWORD_HASH],
    @PasswordSalt	[dss].[PASSWORD_SALT]
AS
BEGIN
    UPDATE [dss].[agent]
    SET
        [password_hash] = @PasswordHash,
        [password_salt] = @PasswordSalt
    WHERE [id] = @AgentID
END
GO
