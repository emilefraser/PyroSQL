SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteKey]
@InstallationID uniqueidentifier
AS

if (@InstallationID = '00000000-0000-0000-0000-000000000000')
RAISERROR('Cannot delete reserved key', 16, 1)

-- Remove the encryption keys
delete from keys where InstallationID = @InstallationID and Client = 1
GO
