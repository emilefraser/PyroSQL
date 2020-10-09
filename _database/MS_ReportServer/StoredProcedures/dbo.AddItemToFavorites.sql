SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddItemToFavorites]
@ItemID uniqueidentifier,
@UserName nvarchar (425),
@UserSid varbinary(85) = NULL,
@AuthType int
AS

DECLARE @UserID uniqueidentifier
EXEC GetUserID @UserSid, @UserName, @AuthType, @UserID OUTPUT

IF NOT EXISTS (SELECT UserID FROM [Favorites] WHERE UserID = @UserID AND ItemID = @ItemID)
BEGIN
    INSERT INTO [dbo].[Favorites] (ItemID, UserID) VALUES (@ItemID, @UserID)
END
GO
