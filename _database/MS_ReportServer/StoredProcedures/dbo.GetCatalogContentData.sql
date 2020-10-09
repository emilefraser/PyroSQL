SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetCatalogContentData]
    @CatalogItemID uniqueidentifier
AS
BEGIN
    SELECT
        COALESCE(DATALENGTH([Content]), 0) AS ContentLength,
        [Content]
    FROM
        [Catalog]
    WHERE
        [ItemID] = @CatalogItemID
END
GO
