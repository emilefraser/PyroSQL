SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteCatalogExtendedContent]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
BEGIN
    DELETE FROM [dbo].[CatalogItemExtendedContent] WHERE [ItemID] = @CatalogItemID AND ContentType = @ContentType
END

GRANT EXECUTE ON [dbo].[DeleteCatalogExtendedContent] TO RSExecRole
GO
