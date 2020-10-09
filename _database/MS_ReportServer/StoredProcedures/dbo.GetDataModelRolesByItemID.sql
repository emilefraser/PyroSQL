SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDataModelRolesByItemID]
    @ItemID uniqueidentifier
AS
    SELECT
        [DataModelRoleID],
        [ItemID],
        [ModelRoleID],
        [ModelRoleName]
    FROM
        [dbo].[DataModelRole]
    WHERE
        [ItemID] = @ItemID
GO
