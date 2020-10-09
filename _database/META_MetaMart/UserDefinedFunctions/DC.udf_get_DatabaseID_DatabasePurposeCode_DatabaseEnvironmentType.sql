SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 2019-09-30
-- Description: Get the Database ID from the DatabasePurpose and DataBaseEnvironmentType
-- =============================================

CREATE FUNCTION [DC].[udf_get_DatabaseID_DatabasePurposeCode_DatabaseEnvironmentType]
(
    -- Add the parameters for the function here
	@DatabasePurposeCode VARCHAR(50),
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
		DC.[Database] AS db
	INNER JOIN 
		DC.[DatabasePurpose] AS dp
		ON db.DatabasePurposeID = dp.DatabasePurposeID
	INNER JOIN
		TYPE.Generic_Detail gd 
		ON db.DatabaseEnvironmentTypeID = gd.DetailID
	INNER JOIN 
		TYPE.Generic_Header AS gh
		ON gd.HeaderID = gh.HeaderID
	WHERE
		dp.DatabasePurposeCode = @DatabasePurposeCode
	AND
		gh.HeaderCode = 'DB_ENV'
	AND
		gd.DetailTypeCode = @DatabaseEnvironmentType
	AND 
		db.IsActive = 1
	AND
		dp.IsActive = 1
	AND
		gh.IsActive = 1
	AND
		gd.IsActive = 1

    -- Return the result of the function
    RETURN @Result
END

GO
