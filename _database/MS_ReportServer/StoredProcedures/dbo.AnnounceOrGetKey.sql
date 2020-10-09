SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AnnounceOrGetKey]
@MachineName nvarchar(256),
@InstanceName nvarchar(32),
@InstallationID uniqueidentifier,
@PublicKey image,
@NumAnnouncedServices int OUTPUT
AS

-- Acquire lock
IF NOT EXISTS (SELECT * FROM [dbo].[Keys] WITH(XLOCK) WHERE [Client] < 0)
BEGIN
    RAISERROR('Keys lock row not found', 16, 1)
    RETURN
END

-- Get the number of services that have already announced their presence
SELECT @NumAnnouncedServices = count(*)
FROM [dbo].[Keys]
WHERE [Client] = 1

DECLARE @StoredInstallationID uniqueidentifier
DECLARE @StoredInstanceName nvarchar(32)

SELECT @StoredInstallationID = [InstallationID], @StoredInstanceName = [InstanceName]
FROM [dbo].[Keys]
WHERE [InstallationID] = @InstallationID AND [Client] = 1

IF @StoredInstallationID IS NULL -- no record present
BEGIN
    INSERT INTO [dbo].[Keys]
        ([MachineName], [InstanceName], [InstallationID], [Client], [PublicKey], [SymmetricKey])
    VALUES
        (@MachineName, @InstanceName, @InstallationID, 1, @PublicKey, null)
END
ELSE
BEGIN
    IF @StoredInstanceName IS NULL
    BEGIN
        UPDATE [dbo].[Keys]
        SET [InstanceName] = @InstanceName
        WHERE [InstallationID] = @InstallationID AND [Client] = 1
    END
END

SELECT [MachineName], [SymmetricKey], [PublicKey]
FROM [Keys]
WHERE [InstallationID] = @InstallationID and [Client] = 1
GO
