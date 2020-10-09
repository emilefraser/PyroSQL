SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteDataSets]
@ItemID [uniqueidentifier]
AS
DELETE
FROM [DataSets]
WHERE [ItemID] = @ItemID
DELETE
FROM [ReportServerTempDB].dbo.TempDataSets
WHERE [ItemID] = @ItemID
GO
