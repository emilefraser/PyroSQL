SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CopyChunks]
    @OldSnapshotId UNIQUEIDENTIFIER,
    @NewSnapshotId UNIQUEIDENTIFIER,
    @IsPermanentSnapshot BIT
AS
BEGIN
    IF(@IsPermanentSnapshot = 1) BEGIN
        -- copy non-segmented chunks
        INSERT [dbo].[ChunkData] (
            ChunkId,
            SnapshotDataId,
            ChunkFlags,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            Content
            )
        SELECT
            NEWID(),
            @NewSnapshotId,
            [c].[ChunkFlags],
            [c].[ChunkName],
            [c].[ChunkType],
            [c].[Version],
            [c].[MimeType],
            [c].[Content]
        FROM [dbo].[ChunkData] [c] WHERE [c].[SnapshotDataId] = @OldSnapshotId

        -- copy segmented chunks... real easy just add the mapping
        INSERT [dbo].[SegmentedChunk](
            ChunkId,
            SnapshotDataId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags
            )
        SELECT
            ChunkId,
            @NewSnapshotId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags
        FROM [dbo].[SegmentedChunk] WITH (INDEX (UNIQ_SnapshotChunkMapping))
        WHERE [SnapshotDataId] = @OldSnapshotId
    END
    ELSE BEGIN
        -- copy non-segmented chunks
        INSERT [ReportServerTempDB].dbo.[ChunkData] (
            ChunkId,
            SnapshotDataId,
            ChunkFlags,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            Content
            )
        SELECT
            NEWID(),
            @NewSnapshotId,
            [c].[ChunkFlags],
            [c].[ChunkName],
            [c].[ChunkType],
            [c].[Version],
            [c].[MimeType],
            [c].[Content]
        FROM [ReportServerTempDB].dbo.[ChunkData] [c] WHERE [c].[SnapshotDataId] = @OldSnapshotId

        -- copy segmented chunks... real easy just add the mapping
        INSERT [ReportServerTempDB].[dbo].[SegmentedChunk](
            ChunkId,
            SnapshotDataId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags,
            Machine
            )
        SELECT
            ChunkId,
            @NewSnapshotId,
            ChunkName,
            ChunkType,
            Version,
            MimeType,
            ChunkFlags,
            Machine
        FROM [ReportServerTempDB].dbo.[SegmentedChunk] WITH (INDEX (UNIQ_SnapshotChunkMapping))
        WHERE [SnapshotDataId] = @OldSnapshotId
    END
END
GO
