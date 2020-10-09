SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-07-07
-- Description:	Gets the ObjectFieldID FROM THE Object CODE AND FIELD NAME 
-- =============================================
CREATE     FUNCTION [XMLDATA].[usp_get_ApplicationObjectID]
(
	-- Add the parameters for the function here
	@ApplicationID SMALLINT
,	@ObjectCode VARCHAR(25)
,	@Version VARCHAR(25)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnValue INT

	---- Gets the correct prefix version to retrieve the ApplicationID
	--DECLARE @ApplicationID INT = (
	--	SELECT 
	--		ApplicationID 
	--	FROM 
	--		XMLDATA.ApplicationObjectModel
	--	WHERE 
	--		Prefix = SUBSTRING('UP0128'/*@ObjectCode*/, 1, 2) 
	--	AND 
	--		ApplicationVersion = '2018'/*@Version*/
	--)

	SET @returnValue = ( 
		SELECT 
			ApplicationObjectID 
		FROM 
			XMLDATA.ApplicationObject
		WHERE 
			ApplicationID = @ApplicationID
		AND 
			ObjectCode = @ObjectCode
	)

	-- Return the result of the function
	RETURN @returnValue

END

GO
