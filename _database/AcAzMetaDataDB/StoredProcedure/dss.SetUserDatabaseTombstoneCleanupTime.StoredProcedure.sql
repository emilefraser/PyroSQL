SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetUserDatabaseTombstoneCleanupTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetUserDatabaseTombstoneCleanupTime] AS' 
END
GO
ALTER PROCEDURE [dss].[SetUserDatabaseTombstoneCleanupTime]
    @DatabaseId UNIQUEIDENTIFIER,
    @LastTombstoneCleanup datetime
AS
    UPDATE [dss].[userdatabase]
    SET
        [last_tombstonecleanup] = @LastTombstoneCleanup
    WHERE [id] = @DatabaseId

    RETURN @@ROWCOUNT
GO
