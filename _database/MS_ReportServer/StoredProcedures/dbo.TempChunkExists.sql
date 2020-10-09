SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [dbo].[TempChunkExists]
    @ChunkId uniqueidentifier
AS
BEGIN
    SELECT COUNT(1) FROM [ReportServerTempDB].dbo.SegmentedChunk
    WHERE ChunkId = @ChunkId
END
GO
