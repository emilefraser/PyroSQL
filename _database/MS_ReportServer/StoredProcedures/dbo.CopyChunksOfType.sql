SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CopyChunksOfType]
@FromSnapshotID uniqueidentifier,
@FromIsPermanent bit,
@ToSnapshotID uniqueidentifier,
@ToIsPermanent bit,
@ChunkType int,
@ChunkName nvarchar(260) = NULL,
@TargetChunkName nvarchar(260) = NULL
AS

DECLARE @Machine nvarchar(512)

IF @FromIsPermanent != 0 AND @ToIsPermanent = 0 BEGIN

    -- copy the contiguous chunks
    INSERT INTO [ReportServerTempDB].dbo.ChunkData
        (ChunkID, SnapshotDataID, ChunkName, ChunkType, MimeType, Version, ChunkFlags, Content)
    SELECT
         newid(), @ToSnapshotID, COALESCE(@TargetChunkName, S.ChunkName), S.ChunkType, S.MimeType, S.Version, S.ChunkFlags, S.Content
    FROM
        ChunkData AS S
    WHERE
        S.SnapshotDataID = @FromSnapshotID AND
        (S.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (S.ChunkName = @ChunkName OR @ChunkName IS NUll) AND
    NOT EXISTS(
        SELECT T.ChunkName
        FROM [ReportServerTempDB].dbo.ChunkData AS T -- exclude the ones in the target
        WHERE
            T.ChunkName = COALESCE(@TargetChunkName, S.ChunkName) AND
            T.ChunkType = S.ChunkType AND
            T.SnapshotDataID = @ToSnapshotID)


    -- the chunks will be cleaned up by the machine in which they are being allocated to
    select @Machine = Machine from [ReportServerTempDB].dbo.SnapshotData SD where SD.SnapshotDataID = @ToSnapshotID

    INSERT INTO [ReportServerTempDB].dbo.SegmentedChunk
        (SnapshotDataId, ChunkId, ChunkFlags, ChunkName, ChunkType, Version, MimeType, Machine)
    SELECT
        @ToSnapshotID, SC.ChunkId, SC.ChunkFlags | 0x4, COALESCE(@TargetChunkName, SC.ChunkName), SC.ChunkType, SC.Version, SC.MimeType, @Machine
    FROM SegmentedChunk SC WITH(INDEX (UNIQ_SnapshotChunkMapping))
    WHERE
        SC.SnapshotDataId = @FromSnapshotID AND
        (SC.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (SC.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
        NOT EXISTS(
            -- exclude chunks already in the target
            SELECT TSC.ChunkName
            FROM [ReportServerTempDB].dbo.SegmentedChunk TSC
            -- JOIN [ReportServerTempDB].dbo.SnapshotChunkMapping TSCM ON (TSC.ChunkId = TSCM.ChunkId)
            WHERE
                TSC.ChunkName = COALESCE(@TargetChunkName, SC.ChunkName) AND
                TSC.ChunkType = SC.ChunkType AND
                TSC.SnapshotDataId = @ToSnapshotID
            )

 END ELSE IF @FromIsPermanent = 0 AND @ToIsPermanent = 0 BEGIN
    -- the chunks exist on the node in which they were originally allocated on, they should
    -- be cleaned up by that node
    select @Machine = Machine from [ReportServerTempDB].dbo.SnapshotData SD where SD.SnapshotDataID = @FromSnapshotID

    INSERT INTO [ReportServerTempDB].dbo.ChunkData
        (ChunkId, SnapshotDataID, ChunkName, ChunkType, MimeType, Version, ChunkFlags, Content)
    SELECT
        newid(), @ToSnapshotID, COALESCE(@TargetChunkName, S.ChunkName), S.ChunkType, S.MimeType, S.Version, S.ChunkFlags, S.Content
    FROM
        [ReportServerTempDB].dbo.ChunkData AS S
    WHERE
        S.SnapshotDataID = @FromSnapshotID AND
        (S.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (S.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
        NOT EXISTS(
            SELECT T.ChunkName
            FROM [ReportServerTempDB].dbo.ChunkData AS T -- exclude the ones in the target
            WHERE
                T.ChunkName = COALESCE(@TargetChunkName, S.ChunkName) AND
                T.ChunkType = S.ChunkType AND
                T.SnapshotDataID = @ToSnapshotID)

    -- copy the segmented chunks, copying the segmented
    -- chunks really just needs to update the mappings
    INSERT INTO [ReportServerTempDB].dbo.SegmentedChunk
        (SnapshotDataId, ChunkId, ChunkName, ChunkType, Version, ChunkFlags, MimeType, Machine)
    SELECT
        @ToSnapshotID, ChunkId, COALESCE(@TargetChunkName, C.ChunkName), C.ChunkType, C.Version, C.ChunkFlags, C.MimeType, @Machine
    FROM [ReportServerTempDB].dbo.SegmentedChunk C WITH(INDEX (UNIQ_SnapshotChunkMapping))
    WHERE	C.SnapshotDataId = @FromSnapshotID AND
            (C.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
            (C.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
            NOT EXISTS(
                -- exclude chunks that are already mapped into this snapshot
                SELECT T.ChunkId
                FROM [ReportServerTempDB].dbo.SegmentedChunk T
                WHERE	T.SnapshotDataId = @ToSnapshotID and
                        T.ChunkName = COALESCE(@TargetChunkName, C.ChunkName) and
                        T.ChunkType = C.ChunkType
                )

END ELSE IF @FromIsPermanent != 0 AND @ToIsPermanent != 0 BEGIN

    INSERT INTO ChunkData
        (ChunkID, SnapshotDataID, ChunkName, ChunkType, MimeType, Version, ChunkFlags, Content)
    SELECT
        newid(), @ToSnapshotID, COALESCE(@TargetChunkName, S.ChunkName), S.ChunkType, S.MimeType, S.Version, S.ChunkFlags, S.Content
    FROM
        ChunkData AS S
    WHERE
        S.SnapshotDataID = @FromSnapshotID AND
        (S.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (S.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
        NOT EXISTS(
            SELECT T.ChunkName
            FROM ChunkData AS T -- exclude the ones in the target
            WHERE
                T.ChunkName = COALESCE(@TargetChunkName, S.ChunkName) AND
                T.ChunkType = S.ChunkType AND
                T.SnapshotDataID = @ToSnapshotID)

    -- copy the segmented chunks, copying the segmented
    -- chunks really just needs to update the mappings
    INSERT INTO SegmentedChunk
        (SnapshotDataId, ChunkId, ChunkName, ChunkType, Version, ChunkFlags, C.MimeType)
    SELECT
        @ToSnapshotID, ChunkId, COALESCE(@TargetChunkName, C.ChunkName), C.ChunkType, C.Version, C.ChunkFlags, C.MimeType
    FROM SegmentedChunk C WITH(INDEX (UNIQ_SnapshotChunkMapping))
    WHERE	C.SnapshotDataId = @FromSnapshotID AND
            (C.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
            (C.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
            NOT EXISTS(
                -- exclude chunks that are already mapped into this snapshot
                SELECT T.ChunkId
                FROM SegmentedChunk T
                WHERE	T.SnapshotDataId = @ToSnapshotID and
                        T.ChunkName = COALESCE(@TargetChunkName, C.ChunkName) and
                        T.ChunkType = C.ChunkType
                )

END ELSE IF @FromIsPermanent = 0 AND @ToIsPermanent != 0 BEGIN
    INSERT INTO ChunkData
        (ChunkId, SnapshotDataID, ChunkName, ChunkType, MimeType, Version, ChunkFlags, Content)
    SELECT
        newid(), @ToSnapshotID, COALESCE(@TargetChunkName, S.ChunkName), S.ChunkType, S.MimeType, S.Version, S.ChunkFlags, S.Content
    FROM
        [ReportServerTempDB].dbo.ChunkData AS S
    WHERE
        S.SnapshotDataID = @FromSnapshotID AND
        (S.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (S.ChunkName = @ChunkName OR @ChunkName IS NULL) AND
        NOT EXISTS(
            SELECT T.ChunkName
            FROM ChunkData AS T -- exclude the ones in the target
            WHERE
                T.ChunkName = COALESCE(@TargetChunkName, S.ChunkName) AND
                T.ChunkType = S.ChunkType AND
                T.SnapshotDataID = @ToSnapshotID)

    declare @mapping_temp table (ChunkId uniqueidentifier not null primary key)

    INSERT INTO SegmentedChunk
        (SnapshotDataId, ChunkId, ChunkName, ChunkType, Version, ChunkFlags, MimeType)
    OUTPUT inserted.ChunkId INTO @mapping_temp
    SELECT
        @ToSnapshotID, ChunkId, COALESCE(@TargetChunkName, C.ChunkName), C.ChunkType, C.Version, C.ChunkFlags, C.MimeType
    FROM [ReportServerTempDB].dbo.SegmentedChunk C WITH(INDEX (UNIQ_SnapshotChunkMapping))
    WHERE
        C.SnapshotDataId = @FromSnapshotID AND
        (C.ChunkType = @ChunkType OR @ChunkType IS NULL) AND
        (C.ChunkName = @ChunkName OR @ChunkName IS NULL)  AND
        NOT EXISTS(
            -- exclude chunks that are already mapped into this snapshot
            SELECT T.ChunkId
            FROM SegmentedChunk T
            WHERE    T.SnapshotDataId = @ToSnapshotID and
               T.ChunkName = COALESCE(@TargetChunkName, C.ChunkName) and
               T.ChunkType = C.ChunkType
        )

     declare @segment_temp table (SegmentId uniqueidentifier not null primary key)

     INSERT INTO ChunkSegmentMapping
         (ChunkId, SegmentId, StartByte, LogicalByteCount, ActualByteCount)
     OUTPUT inserted.SegmentId INTO @segment_temp
     SELECT CM.ChunkId, SegmentId, StartByte, LogicalByteCount, ActualByteCount
     FROM [ReportServerTempDB].dbo.ChunkSegmentMapping CM
     INNER JOIN @mapping_temp as MT on MT.ChunkId = CM.ChunkId
     WHERE
        NOT EXISTS(
            -- exclude segment mappings that already exist in the target snapshot
            SELECT CMT.ChunkId
            FROM ChunkSegmentMapping CMT
            WHERE
               CMT.ChunkId = CM.ChunkId
               and CMT.SegmentId = CM.SegmentId
        )

     INSERT INTO Segment
         (SegmentId, Content)
     SELECT CS.SegmentId, Content
     FROM [ReportServerTempDB].dbo.Segment CS
     INNER JOIN @segment_temp as ST ON CS.SegmentId = ST.SegmentId
     WHERE
        NOT EXISTS(
            -- exclude segments that already exist in the target snapshot
            SELECT CST.SegmentId
            FROM Segment CST
            WHERE
               CST.SegmentId = CS.SegmentId
        )
END
GO
