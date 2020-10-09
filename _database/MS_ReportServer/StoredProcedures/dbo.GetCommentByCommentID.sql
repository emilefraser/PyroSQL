SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetCommentByCommentID]
@CommentID bigint
AS
BEGIN
    SELECT TOP(1)
        C.[CommentID],
        C.[ItemID],
        U.[UserName],
        C.[ThreadID],
        C.[Text],
        C.[CreatedDate],
        C.[ModifiedDate],
        CAI.[Path] AS ItemPath,
        CAA.[Path] AS AttachmentPath,
        CAI.[Name]
    FROM
        [Comments] as C
        INNER JOIN Users as U ON C.[UserID] = U.[UserID]
        INNER JOIN Catalog as CAI ON C.[ItemID] = CAI.[ItemID]
        LEFT JOIN Catalog as CAA ON C.[AttachmentID] = CAA.[ItemID]
    WHERE
        C.[CommentID] = @CommentID
END
GO
