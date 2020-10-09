SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- selects back 0 if lock NOT acquired
-- selects back 1 if lock acquired
-- Acquires a lock that governs the nightly cleanup (defaults to 2am) for the db.
-- this is done to keep scaleout farms from blocking each other, as each RS in a scaleout
-- farm  invokes the same cleanup job at the same time
-- IMPLEMENTATION: success updates the CleanupLock table with the specified machine name and time
-- lock is held for 8 hours
-- repeated calls from the same machine will all succeed
CREATE PROCEDURE [dbo].TryAcquireCleanupLock
@MachineName nvarchar(256)
AS

DECLARE @OldMachineName AS NVARCHAR(256);
DECLARE @OldLock        AS DATETIME;

SELECT @OldMachineName = CL.MachineName, @OldLock = CL.LockDate
FROM CleanupLock CL WITH (XLOCK)
WHERE CL.ID = 0;

IF @@ROWCOUNT = 0
BEGIN
    INSERT into CleanupLock
    (ID, MachineName, LockDate)
    VALUES
    (0, @MachineName, GETDATE());
    SELECT CAST(1 AS bit);
END
ELSE IF @OldMachineName = @MachineName
        OR @OldLock <  DATEADD(hour, -8, GETDATE())
BEGIN
    UPDATE CleanupLock
    SET MachineName = @MachineName,
        LockDate = GETDATE()
    WHERE
    ID = 0;
    SELECT CAST(1 AS bit);
END
ELSE
BEGIN
    SELECT CAST(0 AS bit);
END
GO
