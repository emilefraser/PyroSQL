SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[TaskKeepAlive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[TaskKeepAlive] AS' 
END
GO
ALTER PROCEDURE [dss].[TaskKeepAlive]
    @TaskId	UNIQUEIDENTIFIER
AS
BEGIN

    DECLARE @State INT
    SELECT @State = 0
    SET NOCOUNT ON

    UPDATE [dss].[task]
    SET [lastheartbeat] = GETUTCDATE(),
        @State = [state]
    WHERE [id] = @TaskId

    -- check if the task is cancelling
    IF (@State <> -4) -- -4: cancelling
        SELECT 1
    ELSE
        SELECT 0

END
GO
