SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-07-07
-- Description:	Gets the ViewFieldID FROM THE VIEW CODE AND FIELD NAME 
-- =============================================
CREATE   FUNCTION [XMLDATA].[usp_get_ApplicationViewFieldID]
(
	-- Add the parameters for the function here
	@RotoID VARCHAR(25), @Version VARCHAR(25), @FieldIndex INT
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnValue INT

	-- Add the T-SQL statements to compute the return value here
	DECLARE @ApplicationID INT = (
		SELECT 
			ApplicationID 
		FROM 
			XMLDATA.ApplicationObjectModel
		WHERE 
			Prefix = SUBSTRING(@RotoID, 1, 2) 
		AND 
			ApplicationVersion = @Version
	)

	-- Add the T-SQL statements to compute the return value here
	DECLARE @ApplicationViewID INT = (
		SELECT 
			ApplicationViewID 
		FROM 
			XMLDATA.ApplicationView 
		WHERE 
			RotoID = @RotoID 
		AND 
			ApplicationID = @ApplicationID
	)

	SET @returnValue = ( 
		SELECT 
			ApplicationViewFieldID 
		FROM 
			XMLDATA.ApplicationViewField 
		WHERE 
			ApplicationViewID = @ApplicationViewID
		AND 
			FieldIndex = @FieldIndex
	)

	-- Return the result of the function
	RETURN @returnValue

END

GO
