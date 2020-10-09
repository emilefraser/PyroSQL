SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetAllConfigurationInfo]
AS
SELECT [Name], [Value]
FROM [ConfigurationInfo]
GO
