SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdatePolicyRole]
@PolicyID uniqueidentifier,
@PrincipalID uniqueidentifier,
@RoleName nvarchar(260),
@RoleID uniqueidentifier OUTPUT
AS
SELECT @RoleID = (SELECT RoleID FROM Roles WHERE RoleName = @RoleName)
INSERT INTO PolicyUserRole
(ID, RoleID, UserID, PolicyID)
VALUES (newid(), @RoleID, @PrincipalID, @PolicyID)
GO
