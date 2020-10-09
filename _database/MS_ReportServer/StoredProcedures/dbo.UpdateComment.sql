SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdateComment]
@Text nvarchar(2048),
@CommentID bigint
AS
BEGIN
    UPDATE
        [Comments]
    SET
        [Text]=@Text,
        [ModifiedDate]=GETDATE()
    WHERE
        [CommentID]=@CommentID
END
GO
