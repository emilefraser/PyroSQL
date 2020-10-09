SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetContentCache]
    @CatalogItemID uniqueidentifier,
    @ParamsHash int,
    @ContentType nvarchar(256)
AS
BEGIN
    DECLARE @now as DateTime
    SET @now = GETDATE()

    SELECT ContentCacheID, CatalogItemID, CreatedDate, ParamsHash, ExpirationDate, Version, ContentType, Content
    FROM [ReportServerTempDB].dbo.ContentCache WITH (NOLOCK)
    WHERE
        CatalogItemID = @CatalogItemID
        AND ParamsHash = @ParamsHash
        AND ContentType = @ContentType
        AND ExpirationDate > @now
END
GO
