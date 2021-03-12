SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncGroupHubHasData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncGroupHubHasData] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncGroupHubHasData]
    @syncGroupId uniqueidentifier,
    @hasData bit
AS
BEGIN
    UPDATE [dss].[syncgroup]
    SET
        [hubhasdata] = @hasData
    WHERE [id] = @syncGroupId
END
GO
