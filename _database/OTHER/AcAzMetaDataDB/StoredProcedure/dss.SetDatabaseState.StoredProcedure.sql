SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetDatabaseState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetDatabaseState] AS' 
END
GO
ALTER PROCEDURE [dss].[SetDatabaseState]
    @DatabaseID	UNIQUEIDENTIFIER,
    @DatabaseState int,
    @JobId      UNIQUEIDENTIFIER
AS
BEGIN
    -- Change the database state
    UPDATE [dss].[userdatabase]
    SET
        [state] = @DatabaseState,
        [jobId] = @JobId
    WHERE [id] = @DatabaseID
END
GO
