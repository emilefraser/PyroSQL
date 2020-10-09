SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetConfigurationInfoValue]
@ConfigValue nvarchar (260),
@ConfigName nvarchar (260)
AS

UPDATE [dbo].[ConfigurationInfo]
SET [Value] = @ConfigValue
WHERE [Name] = @ConfigName
GO
