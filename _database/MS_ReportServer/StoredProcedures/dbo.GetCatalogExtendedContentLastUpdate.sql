SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetCatalogExtendedContentLastUpdate]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
BEGIN
    SELECT
        ModifiedDate
    FROM
        [CatalogItemExtendedContent]  WITH (READPAST) -- Ignoring rows that are in middle of a transaction
    WHERE
        [ItemID] = @CatalogItemID AND ContentType = @ContentType
END
GO
