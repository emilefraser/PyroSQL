SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetOneConfigurationInfo]
@Name nvarchar (260)
AS
SELECT [Value]
FROM [ConfigurationInfo]
WHERE [Name] = @Name
GO
