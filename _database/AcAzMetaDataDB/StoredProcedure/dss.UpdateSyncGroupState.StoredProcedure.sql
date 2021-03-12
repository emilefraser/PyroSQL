SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncGroupState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncGroupState] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncGroupState]
    @SyncGroupId UNIQUEIDENTIFIER,
    @State		 INT
AS
BEGIN
    UPDATE [dss].[syncgroup]
    SET
        [state] = @State
    WHERE [id] = @SyncGroupId
END
GO
