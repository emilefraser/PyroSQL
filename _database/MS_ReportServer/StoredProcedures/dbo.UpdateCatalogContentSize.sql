SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdateCatalogContentSize]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentSize bigint
AS
BEGIN
    UPDATE
        [dbo].[Catalog]
    SET
        [ContentSize] = @ContentSize
    WHERE
        [ItemID] = @CatalogItemID
END
GO
