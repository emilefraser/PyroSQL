SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetCatalogItemProperties]
@CatalogItemID AS uniqueidentifier
AS

SELECT
   [ItemID] AS [ItemId],
   [Path],
   [Name],
   [Type],
   [ContentSize] AS [SizeInBytes],
   C.[UserName] AS [CreatorUserName],
   [CreationDate],
   M.[UserName] AS [ModifierUserName],
   [Catalog].[ModifiedDate],
   [MimeType],
   [Hidden]
FROM
    [Catalog]
    INNER JOIN Users C ON [Catalog].CreatedByID = C.UserID
    INNER JOIN Users M ON [Catalog].ModifiedByID = M.UserID
WHERE
    [ItemID] = @CatalogItemID
GO
