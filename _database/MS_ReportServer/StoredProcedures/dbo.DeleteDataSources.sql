SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteDataSources]
@ItemID [uniqueidentifier]
AS

DELETE
FROM [DataSource]
WHERE [ItemID] = @ItemID or [SubscriptionID] = @ItemID
DELETE
FROM [ReportServerTempDB].dbo.TempDataSources
WHERE [ItemID] = @ItemID
GO
