SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-07-07
-- Description:	Gets the TableFieldID FROM THE Table CODE AND FIELD NAME 
-- =============================================
CREATE   FUNCTION [XMLDATA].[usp_get_ApplicationTableID]
(
	-- Add the parameters for the function here
	@TableID VARCHAR(25), @Version VARCHAR(25)
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
			Prefix = SUBSTRING(@TableID, 1, 2) 
		AND 
			ApplicationVersion = @Version
	)

	SET @returnValue = ( 
		SELECT 
			ApplicationTableID 
		FROM 
			XMLDATA.ApplicationTable
		WHERE 
			ApplicationID = @ApplicationID
		AND 
			TableID = @TableID
	)

	-- Return the result of the function
	RETURN @returnValue

END

GO
