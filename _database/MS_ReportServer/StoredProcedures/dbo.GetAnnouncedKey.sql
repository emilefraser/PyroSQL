SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetAnnouncedKey]
@InstallationID uniqueidentifier
AS

select PublicKey, MachineName, InstanceName
from Keys
where InstallationID = @InstallationID and Client = 1
GO
