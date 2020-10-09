SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create proc [dbo].[ReadChunkSegment]
    @ChunkId		uniqueidentifier,
    @SegmentId		uniqueidentifier,
    @IsPermanent	bit,
    @DataIndex		int,
    @Length			int
as begin
    if(@IsPermanent = 1) begin
        select substring(seg.Content, @DataIndex + 1, @Length) as [Content]
        from Segment seg
        join ChunkSegmentMapping csm on (csm.SegmentId = seg.SegmentId)
        where csm.ChunkId = @ChunkId and csm.SegmentId = @SegmentId
    end
    else begin
        select substring(seg.Content, @DataIndex + 1, @Length) as [Content]
        from [ReportServerTempDB].dbo.Segment seg
        join [ReportServerTempDB].dbo.ChunkSegmentMapping csm on (csm.SegmentId = seg.SegmentId)
        where csm.ChunkId = @ChunkId and csm.SegmentId = @SegmentId
    end
end
GO
