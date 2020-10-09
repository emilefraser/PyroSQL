SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[WriteCatalogExtendedContentChunkById]
    @Id bigint,
    @Chunk VARBINARY(max),
    @Offset INT,
    @Length INT
AS
BEGIN
    UPDATE
        [dbo].[CatalogItemExtendedContent]
    SET [Content]
        .WRITE(@Chunk, @Offset, @Length)
    WHERE
        [Id] = @Id
END
GO
