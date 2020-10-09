SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[WriteCatalogExtendedContentChunk]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50),
    @Chunk VARBINARY(max),
    @Offset INT,
    @Length INT
AS
BEGIN
    UPDATE
        [CatalogItemExtendedContent]
    SET [Content]
        .WRITE(@Chunk, @Offset, @Length)
    WHERE
        [ItemID] = @CatalogItemID AND ContentType = @ContentType
END
GO
