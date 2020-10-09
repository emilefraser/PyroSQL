SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[FinalizeTempCatalogExtendedContentWrite]
    @Id bigint,
    @CatalogItemID UNIQUEIDENTIFIER
AS
BEGIN
    UPDATE
        [dbo].[CatalogItemExtendedContent]
    SET 
        [ItemID] = @CatalogItemID
    WHERE
        [Id] = @Id
END

GRANT EXECUTE ON [dbo].[FinalizeTempCatalogExtendedContentWrite] TO RSExecRole
GO
