SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[RemoveConfigurationInfoValue]
@Name nvarchar (260)
AS

DELETE FROM [dbo].[ConfigurationInfo] 
WHERE [Name] = @Name
GO
