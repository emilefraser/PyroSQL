SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Returns the config value to be used be the creation of the Date Dimension
				
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	Created the Function

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================
    DECLARE @ConfigCode	VARCHAR(50)		= 'CalendarStartDate'
	SELECT [MASTER].[Create_DateDimension](@ConfigCode)
======================================================================================================================== */
CREATE   FUNCTION config.GetConfigValue (
    @ConfigCode VARCHAR(50)
)
RETURNS NVARCHAR(250)
AS
BEGIN
	DECLARE @returnValue NVARCHAR(250)

	SELECT @returnValue = ConfigValue FROM config.Generic WHERE ConfigCode = @ConfigCode

	RETURN @returnValue
END
GO
