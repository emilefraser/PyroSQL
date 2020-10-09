SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- gets either the intermediate format or snapshot from cache
CREATE PROCEDURE [dbo].[GetReportForExecution]
@Path nvarchar (425),
@EditSessionID varchar(32) = NULL,
@ParamsHash int,
@OwnerSid as varbinary(85) = NULL,
@OwnerName as nvarchar(260) = NULL,
@AuthType int
AS
DECLARE @OwnerID uniqueidentifier
if(@EditSessionID is not null)
BEGIN
    EXEC GetUserID @OwnerSid, @OwnerName, @AuthType, @OwnerID OUTPUT
END

DECLARE @now AS datetime
SET @now = GETDATE()

IF ( NOT EXISTS (
    SELECT TOP 1 1
        FROM
            ExtendedCatalog(@OwnerID, @Path, @EditSessionID) AS C
            INNER JOIN [ReportServerTempDB].dbo.ExecutionCache AS EC ON C.ItemID = EC.ReportID
        WHERE
            EC.AbsoluteExpiration > @now AND
            EC.ParamsHash = @ParamsHash
   ) )
BEGIN   -- no cache
    SELECT
        Cat.Type,
        Cat.LinkSourceID,
        Cat2.Path,
        Cat.Property,
        Cat.Description,
        SecData.NtSecDescPrimary,
        Cat.ItemID,
        CAST (0 AS BIT), -- not found,
        Cat.Intermediate,
        Cat.ExecutionFlag,
        SD.SnapshotDataID,
        SD.DependsOnUser,
        Cat.ExecutionTime,
        (SELECT Schedule.NextRunTime
         FROM
             Schedule WITH (XLOCK)
             INNER JOIN ReportSchedule ON Schedule.ScheduleID = ReportSchedule.ScheduleID
         WHERE ReportSchedule.ReportID = Cat.ItemID AND ReportSchedule.ReportAction = 1), -- update snapshot
        (SELECT Schedule.ScheduleID
         FROM
             Schedule
             INNER JOIN ReportSchedule ON Schedule.ScheduleID = ReportSchedule.ScheduleID
         WHERE ReportSchedule.ReportID = Cat.ItemID AND ReportSchedule.ReportAction = 1), -- update snapshot
        (SELECT CachePolicy.ExpirationFlags FROM CachePolicy WHERE CachePolicy.ReportID = Cat.ItemID),
        Cat2.Intermediate,
        SD.ProcessingFlags,
        Cat.IntermediateIsPermanent
    FROM
        ExtendedCatalog(@OwnerID, @Path, @EditSessionID) AS Cat
        LEFT OUTER JOIN SecData ON Cat.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType
        LEFT OUTER JOIN Catalog AS Cat2 on Cat.LinkSourceID = Cat2.ItemID
        LEFT OUTER JOIN SnapshotData AS SD ON Cat.SnapshotDataID = SD.SnapshotDataID
END
ELSE
BEGIN   -- use cache
    SELECT TOP 1
        Cat.Type,
        Cat.LinkSourceID,
        Cat2.Path,
        Cat.Property,
        Cat.Description,
        SecData.NtSecDescPrimary,
        Cat.ItemID,
        CAST (1 AS BIT), -- found,
        SN.SnapshotDataID,
        SN.DependsOnUser,
        SN.EffectiveParams,  -- offset 10
        SN.CreatedDate,
        EC.AbsoluteExpiration,
        (SELECT CachePolicy.ExpirationFlags FROM CachePolicy WHERE CachePolicy.ReportID = Cat.ItemID),
        (SELECT Schedule.ScheduleID
         FROM
             Schedule WITH (XLOCK)
             INNER JOIN ReportSchedule ON Schedule.ScheduleID = ReportSchedule.ScheduleID
             WHERE ReportSchedule.ReportID = Cat.ItemID AND ReportSchedule.ReportAction = 1), -- update snapshot
        SN.QueryParams,  -- offset 15
        SN.ProcessingFlags,
        Cat.IntermediateIsPermanent,
        Cat.Intermediate
    FROM
        ExtendedCatalog(@OwnerID, @Path, @EditSessionID) AS Cat
        INNER JOIN [ReportServerTempDB].dbo.ExecutionCache AS EC ON Cat.ItemID = EC.ReportID
        INNER JOIN [ReportServerTempDB].dbo.SnapshotData AS SN ON EC.SnapshotDataID = SN.SnapshotDataID AND EC.ParamsHash = SN.ParamsHash
        LEFT OUTER JOIN SecData ON Cat.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType
        LEFT OUTER JOIN Catalog AS Cat2 on Cat.LinkSourceID = Cat2.ItemID
    WHERE
        AbsoluteExpiration > @now
        AND SN.ParamsHash = @ParamsHash
    ORDER BY SN.CreatedDate DESC
END
GO
