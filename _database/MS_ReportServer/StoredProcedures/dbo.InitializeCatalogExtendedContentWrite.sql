SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[InitializeCatalogExtendedContentWrite]
    @CatalogItemID UNIQUEIDENTIFIER,
    @ContentType VARCHAR(50)
AS
BEGIN
    DECLARE @Id AS bigint
    
    IF @CatalogItemID IS NOT NULL
    BEGIN
        SELECT
            @Id = Id
        FROM
            [dbo].[CatalogItemExtendedContent]
        WHERE
            ItemID = @CatalogItemID AND ContentType = @ContentType
    END

    IF @Id IS NOT NULL
        BEGIN
            UPDATE
                [dbo].[CatalogItemExtendedContent]
            SET
                Content = 0x,
                ModifiedDate= GETDATE()
            WHERE
                ItemID = @CatalogItemID AND ContentType = @ContentType
        END
    ELSE
        BEGIN
            INSERT INTO [dbo].[CatalogItemExtendedContent] VALUES (@CatalogItemID, @ContentType , 0x, GETDATE())

            SELECT @Id = SCOPE_IDENTITY()
        END

    SELECT @Id AS Id
END
GO
