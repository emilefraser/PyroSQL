SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetModelItemInfo]
@Path nvarchar (425),
@UseUpdateLock bit
AS
    IF(@UseUpdateLock = 0)
    BEGIN
        SELECT
            C.[Intermediate]
        FROM
            [Catalog] AS C
        WHERE
            C.[Path] = @Path
    END
    ELSE BEGIN
        -- acquire update lock, this means that the operation is being performed in a
        -- different transaction context which will be committed before trying to
        -- perform the actual load, to prevent deadlock in the case where we have to
        -- republish, this new transaction will acquire and hold upgrade locks
        SELECT
            C.[Intermediate]
        FROM
            [Catalog] AS C WITH(UPDLOCK ROWLOCK)
        WHERE
            C.[Path] = @Path
    END

    SELECT
        MIP.[ModelItemID], SD.[NtSecDescPrimary], SD.[XmlDescription]
    FROM
        [Catalog] AS C
        INNER JOIN [ModelItemPolicy] AS MIP ON C.[ItemID] = MIP.[CatalogItemID]
        LEFT OUTER JOIN [SecData] AS SD ON MIP.[PolicyID] = SD.[PolicyID]
    WHERE
        C.[Path] = @Path
GO
