SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create proc [dbo].[DeepCopySegment]
    @ChunkId		uniqueidentifier,
    @IsPermanent	bit,
    @SegmentId		uniqueidentifier,
    @NewSegmentId	uniqueidentifier out
as
begin
    select @NewSegmentId = newid() ;
    if (@IsPermanent = 1) begin
        insert Segment(SegmentId, Content)
        select @NewSegmentId, seg.Content
        from Segment seg
        where seg.SegmentId = @SegmentId ;

        update ChunkSegmentMapping
        set SegmentId = @NewSegmentId
        where ChunkId = @ChunkId and SegmentId = @SegmentId ;
    end
    else begin
        insert [ReportServerTempDB].dbo.Segment(SegmentId, Content)
        select @NewSegmentId, seg.Content
        from [ReportServerTempDB].dbo.Segment seg
        where seg.SegmentId = @SegmentId ;

        update [ReportServerTempDB].dbo.ChunkSegmentMapping
        set SegmentId = @NewSegmentId
        where ChunkId = @ChunkId and SegmentId = @SegmentId ;
    end
end
GO
