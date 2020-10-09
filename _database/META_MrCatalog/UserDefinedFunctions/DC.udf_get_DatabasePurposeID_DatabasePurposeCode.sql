SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 2019-09-30
-- Description: Get the Database Purpose ID from a DatabasePurposeCode
-- =============================================

CREATE FUNCTION [DC].[udf_get_DatabasePurposeID_DatabasePurposeCode]
(
    -- Add the parameters for the function here
    @DatabasePurposeCode VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT	
		@Result = dbp.DatabasePurposeID
	FROM	
		DC.DatabasePurpose dbp 
	WHERE	
		dbp.DatabasePurposeCode = @DatabasePurposeCode

    -- Return the result of the function
    RETURN @Result
END

GO
