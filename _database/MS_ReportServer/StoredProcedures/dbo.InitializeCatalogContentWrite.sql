SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[InitializeCatalogContentWrite]
    @CatalogItemID uniqueidentifier
AS
BEGIN
    IF EXISTS (SELECT * FROM [dbo].[Catalog] WHERE [ItemID] = @CatalogItemID)
    BEGIN
        UPDATE
            [Catalog]
        SET
            [Content] = 0x
        WHERE [ItemID] = @CatalogItemID
    END
END
GO
