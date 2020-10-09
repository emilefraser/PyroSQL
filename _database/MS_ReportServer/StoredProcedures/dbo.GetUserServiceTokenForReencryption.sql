SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetUserServiceTokenForReencryption]
@UserID as uniqueidentifier
AS

SELECT [ServiceToken]
FROM [dbo].[Users]
WHERE [UserID] = @UserID
GO
