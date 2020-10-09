SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- For loading compiled definitions to check for internal republishing, this is
-- done before calling GetCompiledDefinition or GetReportForExecution
CREATE PROCEDURE [dbo].[LoadForDefinitionCheck]
@Path					nvarchar(425),
@AcquireUpdateLocks	bit,
@AuthType				int
AS
IF(@AcquireUpdateLocks = 0) BEGIN
SELECT
        CompiledDefinition.SnapshotDataID,
        CompiledDefinition.ProcessingFlags,
        SecData.NtSecDescPrimary
    FROM Catalog MainItem
    LEFT OUTER JOIN SecData ON (MainItem.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType)
    LEFT OUTER JOIN Catalog LinkTarget WITH (INDEX = PK_CATALOG) ON (MainItem.LinkSourceID = LinkTarget.ItemID)
    JOIN SnapshotData CompiledDefinition ON (CompiledDefinition.SnapshotDataID = COALESCE(LinkTarget.Intermediate, MainItem.Intermediate))
    WHERE MainItem.Path = @Path AND (MainItem.Type = 2 /* Report */ OR MainItem.Type = 4 /* Linked Report */)
END
ELSE BEGIN
    -- acquire upgrade locks, this means that the check is being perform in a
    -- different transaction context which will be committed before trying to
    -- perform the actual load, to prevent deadlock in the case where we have to
    -- republish this new transaction will acquire and hold upgrade locks
SELECT
        CompiledDefinition.SnapshotDataID,
        CompiledDefinition.ProcessingFlags,
        SecData.NtSecDescPrimary
    FROM Catalog MainItem WITH(UPDLOCK ROWLOCK)
    LEFT OUTER JOIN SecData ON (MainItem.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType)
    LEFT OUTER JOIN Catalog LinkTarget WITH (UPDLOCK ROWLOCK INDEX = PK_CATALOG) ON (MainItem.LinkSourceID = LinkTarget.ItemID)
    JOIN SnapshotData CompiledDefinition WITH(UPDLOCK ROWLOCK) ON (CompiledDefinition.SnapshotDataID = COALESCE(LinkTarget.Intermediate, MainItem.Intermediate))
    WHERE MainItem.Path = @Path AND (MainItem.Type = 2 /* Report */ OR MainItem.Type = 4 /* Linked Report */)
END
GO
