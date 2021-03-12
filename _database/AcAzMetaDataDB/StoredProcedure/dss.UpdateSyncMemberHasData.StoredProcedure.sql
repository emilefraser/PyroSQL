SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateSyncMemberHasData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateSyncMemberHasData] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateSyncMemberHasData]
    @syncMemberid uniqueidentifier,
    @hasData bit
AS
BEGIN
    UPDATE [dss].[syncgroupmember]
    SET
        [memberhasdata] = @hasData
    WHERE [id] = @syncMemberid
END
GO
