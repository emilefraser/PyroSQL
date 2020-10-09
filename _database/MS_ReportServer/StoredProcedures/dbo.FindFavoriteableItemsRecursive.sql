SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[FindFavoriteableItemsRecursive]
@Path nvarchar (850),
@UserName nvarchar (425),
@UserSid varbinary(85) = NULL,
@AuthType int
AS

DECLARE @UserID uniqueidentifier
EXEC GetUserIDWithNoCreate @UserSid, @UserName, @AuthType, @UserID OUTPUT

SET NOCOUNT ON;

SELECT
    C.Type,
    C.PolicyID,
    SD.NtSecDescPrimary,
    C.Name,
    C.Path,
    C.ItemID,
    C.ContentSize AS [Size],
    C.Description,
    C.CreationDate,
    C.ModifiedDate,
    CU.[UserName],
    CU.[UserName],
    MU.[UserName],
    MU.[UserName],
    C.MimeType,
    C.ExecutionTime,
    C.Hidden,
    C.SubType,
    C.ComponentID,
    CAST (CASE WHEN F.ItemId IS NULL THEN 0 ELSE 1 END AS BIT)
FROM
    Catalog AS C
    INNER JOIN [dbo].[Catalog] AS P ON C.ParentID = P.ItemID
    INNER JOIN [dbo].[Users] AS CU ON C.CreatedByID = CU.UserID
    INNER JOIN [dbo].[Users] AS MU ON C.ModifiedByID = MU.UserID
    LEFT OUTER JOIN [dbo].[SecData] SD ON C.PolicyID = SD.PolicyID AND SD.AuthType = @AuthType
    LEFT OUTER JOIN [dbo].[Favorites] F ON C.ItemID = F.ItemID AND F.UserID = @UserID
WHERE C.Path LIKE @Path ESCAPE '*'
   AND (C.SubType IS NULL OR C.SubType <> 'MobileReportChild') -- Do not drill into associated mobile report items
   AND C.Path <> '/68f0607b-9378-4bbb-9e70-4da3d7d66838' -- hide System Resources folder from output
   AND C.Path NOT LIKE '/68f0607b-9378-4bbb-9e70-4da3d7d66838/%' -- hide System Resources from recursive output
GO
