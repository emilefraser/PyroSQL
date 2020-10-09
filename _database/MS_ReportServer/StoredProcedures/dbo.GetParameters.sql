SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetParameters]
@Path nvarchar (425),
@AuthType int
AS
SELECT
   Type,
   [Parameter],
   ItemID,
   SecData.NtSecDescPrimary,
   [LinkSourceID],
   [ExecutionFlag]
FROM Catalog
LEFT OUTER JOIN SecData ON Catalog.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType
WHERE Path = @Path
GO
