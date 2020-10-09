SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 2019-09-30
-- Description: Get the Load Type ID from the LoadType Code
-- =============================================

CREATE FUNCTION [DC].[udf_get_LoadTypeID_LoadTypeCode]
(
    -- Add the parameters for the function here
    @LoadTypeCode VARCHAR(20)
)
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT	
		@Result = gd.DetailID 
	FROM	
		TYPE.Generic_Detail gd 
	INNER JOIN 
		TYPE.Generic_Header AS gh
		ON gd.HeaderID = gh.HeaderID
	WHERE	
		gh.HeaderCode = 'LType'
	AND
		gd.DetailTypeCode = @LoadTypeCode
	AND
		ISNULL(gh.IsActive, 0) = 1
	AND
		ISNULL(gd.IsActive, 0) = 1

    -- Return the result of the function
    RETURN @Result
END

GO
