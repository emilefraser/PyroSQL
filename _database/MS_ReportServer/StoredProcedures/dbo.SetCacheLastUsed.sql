SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [dbo].[SetCacheLastUsed]
    @SnapshotDataID uniqueidentifier,
    @Timestamp datetime
AS
BEGIN
    -- Extend the cache lifetime based on the current timestamp
    -- set the last used time, which is utilized to compute which entries
    -- to evict when enforcing cache limits
    -- in the case where the cache entry is using schedule based expiration (RelativeExpiration is null)
    -- then don't update AbsoluteExpiration
    UPDATE [ReportServerTempDB].dbo.ExecutionCache
    SET		AbsoluteExpiration = ISNULL(DATEADD(n, RelativeExpiration, @Timestamp), AbsoluteExpiration),
            LastUsedTime = @Timestamp
    WHERE SnapshotDataID = @SnapshotDataID ;
END
GO
