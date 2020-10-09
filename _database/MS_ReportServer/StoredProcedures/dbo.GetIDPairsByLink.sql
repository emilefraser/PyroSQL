SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetIDPairsByLink]
@Link uniqueidentifier
AS
SELECT LinkSourceID, ItemID
FROM Catalog
WHERE LinkSourceID = @Link
GO
