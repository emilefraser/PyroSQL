SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetConfigurationValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetConfigurationValue] AS' 
END
GO
ALTER PROCEDURE [dss].[GetConfigurationValue]
    @ConfigKey NVARCHAR(100)
AS
BEGIN
    DECLARE @ConfigValue NVARCHAR(256)

    SELECT [ConfigValue] FROM [dss].[configuration] WHERE [ConfigKey] = @ConfigKey
END
GO
