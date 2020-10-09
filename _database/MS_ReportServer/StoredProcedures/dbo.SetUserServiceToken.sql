SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- set AAD token on user account
CREATE PROCEDURE [dbo].[SetUserServiceToken]
@ServiceToken ntext,
@UserSid as varbinary(85) = NULL,
@UserName as nvarchar(260) = NULL,
@AuthType int
AS
BEGIN
DECLARE @UserID uniqueidentifier
EXEC GetUserID @UserSid, @UserName, @AuthType, @UserID OUTPUT

IF (@UserID is not null)
    BEGIN
        UPDATE Users
        SET ServiceToken = @ServiceToken
        WHERE UserID = @UserID
    END
END
GO
