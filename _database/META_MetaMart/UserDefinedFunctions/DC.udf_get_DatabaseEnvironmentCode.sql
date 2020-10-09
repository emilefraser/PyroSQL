SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-09-14
-- Description:	Get the enviornment type code for a database
-- =============================================
CREATE FUNCTION [DC].[udf_get_DatabaseEnvironmentCode] 
(
	-- Add the parameters for the function here
	@DatabaseID int
)
RETURNS varchar(10)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(10)
			--, @DatabaseID int = 2

	SELECT @Result = gd.DetailTypeCode
	--SELECT	*
	FROM	DC.[Database] d
		INNER JOIN TYPE.tvf_GenericDetailTypes('DB_ENV') gd
			ON d.DatabaseEnvironmentTypeID = gd.DetailID
	WHERE	d.DatabaseID = @DatabaseID
	
	-- Return the result of the function
	RETURN @Result

END

GO
