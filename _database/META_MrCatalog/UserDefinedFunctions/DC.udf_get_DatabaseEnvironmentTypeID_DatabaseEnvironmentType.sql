SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 2019-09-30
-- Description: Get the Database Environment Type ID from a DatabaseEnvironmentType
-- =============================================

CREATE FUNCTION [DC].[udf_get_DatabaseEnvironmentTypeID_DatabaseEnvironmentType]
(
    -- Add the parameters for the function here
    @DatabaseEnvironmentType VARCHAR(20)
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
		gh.HeaderCode = 'DB_ENV'
	AND
		gd.DetailTypeCode = @DatabaseEnvironmentType

    -- Return the result of the function
    RETURN @Result
END

GO
