SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[GetConfigValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [config].[GetConfigValue] AS' 
END
GO

/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2021-01-10
	DECSRIPTION: 	    Gets a config value and type from sql 
	TODO:
*/
/*
	DECLARE 
		@ConfigValue NVARCHAR(150)
	,	@ConfigType SYSNAME 

	EXEC  [config].[GetConfigValue] 
		@ConfigClassName = 'dimension'
		,@ConfigCode = 'DATEDIM_START'
		,@ConfigValue = @ConfigValue OUTPUT
		,@ConfigType = @ConfigType OUTPUT

		SELECT @ConfigValue, @ConfigType
*/
ALTER     PROCEDURE [config].[GetConfigValue]
		@ConfigClassName	VARCHAR(50)
	,	@ConfigCode			VARCHAR(50)
	,	@ConfigValue		NVARCHAR(150) OUTPUT
	,	@ConfigType			SYSNAME OUTPUT
AS
BEGIN
	-- Gets the Values from the Generic Config table 
	SELECT 
		@ConfigValue	= congen.ConfigValue
	,	@ConfigType		= congen.ConfigValueType 
	FROM
		config.Generic AS congen
	WHERE
		congen.ConfigClassName  = @ConfigClassName
	AND
		congen.ConfigCode		= @ConfigCode


END -- PROCEDURE
GO
