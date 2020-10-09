SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019-06-20
-- Description: Get the Database Purpose Code for a DatabaseID
-- =============================================

CREATE FUNCTION [DC].[udf_get_DatabasePurposeCode]
(
    -- Add the parameters for the function here
    @DatabaseID int
)
RETURNS varchar(50)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result varchar(50)

    -- Add the T-SQL statements to compute the return value here
    SELECT	@Result = dbp.DatabasePurposeCode
	from	DC.[Database] db
		inner join DC.DatabasePurpose dbp on dbp.DatabasePurposeID = db.DatabasePurposeID
	where	db.DatabaseID = @DatabaseID

    -- Return the result of the function
    RETURN @Result
END

GO
