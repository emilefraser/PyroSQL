SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetCacheOptions]
@Path as nvarchar(425),
@CacheReport as bit,
@ExpirationFlags as int,
@CacheExpiration as int = NULL
AS
DECLARE @CachePolicyID as uniqueidentifier
SELECT @CachePolicyID = (SELECT CachePolicyID
FROM CachePolicy with (XLOCK) INNER JOIN Catalog ON Catalog.ItemID = CachePolicy.ReportID
WHERE  Catalog.Path = @Path)
IF @CachePolicyID IS NULL -- no policy exists
BEGIN
    IF @CacheReport = 1 -- create a new one
    BEGIN
        INSERT INTO CachePolicy
        (CachePolicyID, ReportID, ExpirationFlags, CacheExpiration)
        (SELECT NEWID(), ItemID, @ExpirationFlags, @CacheExpiration
        FROM Catalog WHERE Catalog.Path = @Path)
    END
    -- ELSE if it has no policy and we want to remove its policy do nothing
END
ELSE -- existing policy
BEGIN
    IF @CacheReport = 1
    BEGIN
        UPDATE CachePolicy SET ExpirationFlags = @ExpirationFlags, CacheExpiration = @CacheExpiration
        WHERE CachePolicyID = @CachePolicyID
        EXEC FlushReportFromCache @Path
        EXEC FlushContentCache @Path
    END
    ELSE
    BEGIN
        DELETE FROM CachePolicy
        WHERE CachePolicyID = @CachePolicyID
        EXEC FlushReportFromCache @Path
        EXEC FlushContentCache @Path
    END
END
GO
