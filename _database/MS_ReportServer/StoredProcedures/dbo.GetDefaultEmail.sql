SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDefaultEmail]
    @UserID uniqueidentifier
AS
BEGIN
    SELECT TOP(1)
        U.[DefaultEmailAddress]
    FROM
        [UserContactInfo] as U
    WHERE
        U.UserID = @UserID
END
GO
