SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetSyncGroupByIdV2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetSyncGroupByIdV2] AS' 
END
GO
ALTER PROCEDURE [dss].[GetSyncGroupByIdV2]
    @SyncGroupId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT
    [id],
    [name],
    [subscriptionid],
    [schema_description],
    [state],
    [hub_memberid],
    [conflict_resolution_policy],
    [sync_interval],
    [lastupdatetime],
    [ocsschemadefinition],
    [hubhasdata],
    [ConflictLoggingEnabled],
    [ConflictTableRetentionInDays]
    FROM [dss].[syncgroup]
    WHERE [id] = @SyncGroupId
END
GO
