SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[WriteCatalogContentChunk]
    @CatalogItemID uniqueidentifier,
    @Chunk varbinary(max),
    @Offset int,
    @Length int
AS
BEGIN
    UPDATE
        [Catalog]
    SET [Content]
        .WRITE(@Chunk, @Offset, @Length)
    WHERE [ItemID] = @CatalogItemID
END
GO
