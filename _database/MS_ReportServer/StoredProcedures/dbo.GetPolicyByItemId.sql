SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetPolicyByItemId]
    @ItemId as UNIQUEIDENTIFIER,
    @AuthType INT
AS
    SELECT SecData.XmlDescription, Catalog.PolicyRoot, Catalog.Type
    FROM Catalog
        INNER JOIN Policies ON Catalog.PolicyID = Policies.PolicyID
        LEFT OUTER JOIN SecData ON Policies.PolicyID = SecData.PolicyID AND AuthType = @AuthType
    WHERE Catalog.ItemId = @ItemId
        AND PolicyFlag = 0
GO
