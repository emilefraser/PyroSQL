SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetUserIDWithNoCreate]
@UserSid varbinary(85) = NULL,
@UserName nvarchar(260),
@AuthType int,
@UserID uniqueidentifier OUTPUT
AS
    IF @AuthType = 1 -- Windows
    BEGIN
        SELECT @UserID = (SELECT UserID FROM Users WHERE Sid = @UserSid AND AuthType = @AuthType)
    END
    ELSE
    BEGIN
        SELECT @UserID = (SELECT UserID FROM Users WHERE UserName = @UserName AND AuthType = @AuthType)
    END
GO
