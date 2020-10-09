SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdateDataModelRoleByID]
    @DataModelRoleID bigint,
    @ModelRoleName NVARCHAR(255)
AS
BEGIN
    UPDATE 
        [dbo].[DataModelRole]
    SET
        [ModelRoleName] = @ModelRoleName
    WHERE 
        [DataModelRoleID] = @DataModelRoleID
END
GO
