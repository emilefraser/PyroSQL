SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetUpgradeItemStatus]
@ItemName nvarchar(260),
@Status nvarchar(512)
AS
UPDATE
    [UpgradeInfo]
SET
    [Status] = @Status
WHERE
    [Item] = @ItemName
GO
