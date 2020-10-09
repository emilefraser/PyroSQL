SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ReadRoleProperties]
@RoleName as nvarchar(260)
AS
SELECT Description, TaskMask, RoleFlags FROM Roles WHERE RoleName = @RoleName
GO
