SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-07-07
-- Description:	Gets the ViewFieldID FROM THE VIEW CODE AND FIELD NAME 
-- =============================================
CREATE   FUNCTION [XMLDATA].[usp_get_ApplicationViewID] (
	-- Add the parameters for the function here
	@ApplicationID	SMALLINT
,	@RotoID			VARCHAR(25)
,	@Version		VARCHAR(25)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnValue INT

	---- Add the T-SQL statements to compute the return value here
	--DECLARE @ApplicationID INT = (
	--	SELECT 
	--		ApplicationID 
	--	FROM 
	--		XMLDATA.ApplicationObjectModel
	--	WHERE 
	--		Prefix = SUBSTRING(@RotoID, 1, 2) 
	--	AND 
	--		ApplicationVersion = @Version
	--)

	SET @returnValue = ( 
		SELECT 
			ApplicationViewID 
		FROM 
			XMLDATA.ApplicationView
		WHERE 
			ApplicationID = @ApplicationID
		AND 
			RotoID = @RotoID
	)

	-- Return the result of the function
	RETURN @returnValue

END

GO
