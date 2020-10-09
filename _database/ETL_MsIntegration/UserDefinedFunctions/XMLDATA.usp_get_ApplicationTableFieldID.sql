SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-07-07
-- Description:	Gets the TableFieldID FROM THE Table CODE AND FIELD NAME 
-- =============================================
CREATE   FUNCTION [XMLDATA].[usp_get_ApplicationTableFieldID]
(
	-- Add the parameters for the function here
	@TableID VARCHAR(25), @Version VARCHAR(25), @FieldCode VARCHAR(50)
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

	-- Add the T-SQL statements to compute the return value here
	DECLARE @ApplicationTableID INT = (
		SELECT 
			ApplicationTableID 
		FROM 
			XMLDATA.ApplicationTable 
		WHERE 
			TableID = @TableID 
		AND 
			ApplicationID = @ApplicationID
	)

	SET @returnValue = ( 
		SELECT 
			ApplicationTableFieldID 
		FROM 
			XMLDATA.ApplicationTableField 
		WHERE 
			ApplicationTableID = @ApplicationTableID
		AND 
			FieldCode = @FieldCode
	)

	-- Return the result of the function
	RETURN @returnValue

END

GO
