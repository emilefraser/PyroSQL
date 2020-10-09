SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[UpdateSnapshot]
@Path as nvarchar(425),
@SnapshotDataID as uniqueidentifier,
@executionDate as datetime
AS
DECLARE @OldSnapshotDataID uniqueidentifier
DECLARE @ExecutionFlag int

SELECT @OldSnapshotDataID = SnapshotDataID,
       @ExecutionFlag = ExecutionFlag
       FROM Catalog WITH (XLOCK) WHERE Catalog.Path = @Path

    -- If the report is deleted after execution snapshot is fired
    IF (@@rowcount = 0)
    BEGIN
        RAISERROR('Report does not exist', 16, 1)
        RETURN
    END

-- update reference count in snapshot table
UPDATE SnapshotData
SET PermanentRefcount = PermanentRefcount-1
WHERE SnapshotData.SnapshotDataID = @OldSnapshotDataID

 -- If the report is not set to execution snapshot after the
 -- update execution snapshot fired, ignore this case.
IF (@ExecutionFlag & 3) <> 2
    BEGIN
        RAISERROR('Invalid snapshot flag', 16, 1)
        RETURN
    END

-- update catalog to point to the new execution snapshot
UPDATE Catalog
SET SnapshotDataID = @SnapshotDataID, ExecutionTime = @executionDate
WHERE Catalog.Path = @Path

UPDATE SnapshotData
SET PermanentRefcount = PermanentRefcount+1, TransientRefcount = TransientRefcount-1
WHERE SnapshotData.SnapshotDataID = @SnapshotDataID
GO
