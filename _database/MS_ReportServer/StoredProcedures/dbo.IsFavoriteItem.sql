SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[IsFavoriteItem]
@ItemID uniqueidentifier,
@UserName nvarchar (425),
@UserSid varbinary(85) = NULL,
@AuthType int
AS

DECLARE @UserID uniqueidentifier
EXEC GetUserIDWithNoCreate @UserSid, @UserName, @AuthType, @UserID OUTPUT

SELECT CAST(
    CASE WHEN EXISTS (SELECT ItemID FROM [dbo].[Favorites] WHERE UserID = @UserID AND ItemID = @ItemID) THEN 1
    ELSE 0
    END
AS BIT)
GO
