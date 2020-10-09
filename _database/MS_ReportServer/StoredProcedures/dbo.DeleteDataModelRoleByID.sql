SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteDataModelRoleByID]
    @DataModelRoleID bigint  
AS
BEGIN
    DELETE FROM 
        [dbo].[DataModelRole]
    WHERE 
        [DataModelRoleID] = @DataModelRoleID
END
GO
