SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddReportToCache]
@ReportID as uniqueidentifier,
@ExecutionDate datetime,
@SnapshotDataID uniqueidentifier,
@CacheLimit int = 0,
@EditSessionTimeout int = NULL,
@QueryParamsHash int,
@ExpirationDate datetime OUTPUT,
@ScheduleID uniqueidentifier OUTPUT
AS
DECLARE @ExpirationFlags as int
DECLARE @Timeout as int

SET @ExpirationDate = NULL
SET @ScheduleID = NULL
SET @ExpirationFlags = (SELECT ExpirationFlags FROM CachePolicy WHERE ReportID = @ReportID)
IF @EditSessionTimeout IS NOT NULL
BEGIN
    SET @ExpirationFlags = 1 -- use timeout based expiration
    SET @Timeout = @EditSessionTimeout
    SET @ExpirationDate = DATEADD(n, @Timeout, @ExecutionDate)
END
ELSE IF @ExpirationFlags = 1 -- timeout based
BEGIN
    SET @Timeout = (SELECT CacheExpiration FROM CachePolicy WHERE ReportID = @ReportID)
    SET @ExpirationDate = DATEADD(n, @Timeout, @ExecutionDate)
END
ELSE IF @ExpirationFlags = 2 -- schedule based
BEGIN
    SELECT @ScheduleID=s.ScheduleID, @ExpirationDate=s.NextRunTime
    FROM Schedule s WITH(UPDLOCK) INNER JOIN ReportSchedule rs ON rs.ScheduleID = s.ScheduleID and rs.ReportAction = 3 WHERE rs.ReportID = @ReportID
END
ELSE
BEGIN
    -- Ignore NULL case. It means that a user set the Report not to be cached after the report execution fired.
    IF @ExpirationFlags IS NOT NULL
    BEGIN
        RAISERROR('Invalid cache flags', 16, 1)
    END
    RETURN
END

-- mark any existing entries for this parameter combination to expire very soon in the future
-- note that we do not explicitly delete them here to avoid a race with execution sessions which
-- have discovered these cache entries but have not as of yet increased their transient refcounts
DECLARE @NewExpirationTime DATETIME ;
SELECT @NewExpirationTime = DATEADD(n, 1, GETDATE()) ;

BEGIN TRANSACTION

UPDATE	[ReportServerTempDB].dbo.ExecutionCache WITH (ROWLOCK) -- had deadlocks caused by page lock escalation using rowlock to avoid it.
SET		AbsoluteExpiration = @NewExpirationTime
WHERE	AbsoluteExpiration > @NewExpirationTime AND
        ReportID = @ReportID AND
        ParamsHash = @QueryParamsHash

-- add to the report cache
INSERT INTO [ReportServerTempDB].dbo.ExecutionCache
(ExecutionCacheID, ReportID, ExpirationFlags, AbsoluteExpiration, RelativeExpiration, SnapshotDataID, LastUsedTime, ParamsHash)
VALUES
(newid(), @ReportID, @ExpirationFlags, @ExpirationDate, @Timeout, @SnapshotDataID, @ExecutionDate, @QueryParamsHash)

UPDATE [ReportServerTempDB].dbo.SnapshotData
SET PermanentRefcount = PermanentRefcount + 1,
    IsCached = CONVERT(BIT, 1),
    TransientRefcount = CASE
                        WHEN @EditSessionTimeout IS NOT NULL THEN TransientRefcount - 1
                        ELSE TransientRefCount
                        END
WHERE SnapshotDataID = @SnapshotDataID;
EXEC EnforceCacheLimits @ReportID, @CacheLimit ;

COMMIT
GO
