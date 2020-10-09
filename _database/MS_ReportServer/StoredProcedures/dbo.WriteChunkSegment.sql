SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create proc [dbo].[WriteChunkSegment]
    @ChunkId			uniqueidentifier,
    @IsPermanent		bit,
    @SegmentId			uniqueidentifier,
    @DataIndex			int,
    @Length				int,
    @LogicalByteCount	int,
    @Content			varbinary(max)
as begin
    declare @output table (actualLength int not null) ;
    if(@IsPermanent = 1) begin
        update Segment
        set Content.write( substring(@Content, 1, @Length), @DataIndex, @Length )
        output datalength(inserted.Content) into @output(actualLength)
        where SegmentId = @SegmentId

        update ChunkSegmentMapping
        set LogicalByteCount = @LogicalByteCount,
            ActualByteCount = (select top 1 actualLength from @output)
        where ChunkSegmentMapping.ChunkId = @ChunkId and ChunkSegmentMapping.SegmentId = @SegmentId
    end
    else begin
        update [ReportServerTempDB].dbo.Segment
        set Content.write( substring(@Content, 1, @Length), @DataIndex, @Length )
        output datalength(inserted.Content) into @output(actualLength)
        where SegmentId = @SegmentId

        update [ReportServerTempDB].dbo.ChunkSegmentMapping
        set LogicalByteCount = @LogicalByteCount,
            ActualByteCount = (select top 1 actualLength from @output)
        where ChunkId = @ChunkId and SegmentId = @SegmentId
    end

    if(@@rowcount <> 1)
        raiserror('unexpected # of segments update', 16, 1)
end
GO
