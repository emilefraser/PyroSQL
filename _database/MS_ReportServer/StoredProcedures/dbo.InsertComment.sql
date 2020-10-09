SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[InsertComment]
@UserSid varbinary(85) = NULL,
@UserName nvarchar(260),
@AuthType int,
@ItemID uniqueidentifier,
@ThreadID bigint = NULL,
@Text nvarchar(2048),
@AttachmentPath nvarchar(425) = NULL
AS
BEGIN
    DECLARE @NewComment TABLE(CommentID bigint)
    DECLARE @NewCommentID bigint
    DECLARE @UserID uniqueidentifier
    DECLARE @AttachmentID uniqueidentifier
    EXEC GetUserID @UserSid, @UserName, @AuthType, @UserID OUTPUT
    SET @AttachmentID = (SELECT TOP(1) ItemID FROM Catalog WHERE Path = @AttachmentPath)
    INSERT INTO [Comments] (ItemID, UserID, ThreadID, Text, CreatedDate, ModifiedDate, AttachmentID)
    OUTPUT INSERTED.CommentID INTO @NewComment(CommentID)
    VALUES (@ItemID, @UserID, @ThreadID, @Text, GETDATE(), null, @AttachmentID)
    SET @NewCommentID = (SELECT TOP(1) CommentID FROM @NewComment)
    EXEC GetCommentByCommentID @NewCommentID
END
GO
