SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[FindItemsByDataSet]
@ItemID uniqueidentifier,
@AuthType int,
@Type int = NULL
AS
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
    CU.UserName,
    CU.UserName,
    MU.UserName,
    MU.UserName,
    C.MimeType,
    C.ExecutionTime,
    C.Hidden,
    C.SubType,
    C.ComponentID
FROM
   Catalog AS C WITH (NOLOCK)
   INNER JOIN Users AS CU ON C.CreatedByID = CU.UserID
   INNER JOIN Users AS MU ON C.ModifiedByID = MU.UserID
   LEFT OUTER JOIN SecData AS SD ON C.PolicyID = SD.PolicyID AND SD.AuthType = @AuthType
   INNER JOIN DataSets AS DS ON C.ItemID = DS.ItemID
WHERE
   (@Type IS NULL OR @Type = C.Type)
   AND DS.LinkID = @ItemID
GO
