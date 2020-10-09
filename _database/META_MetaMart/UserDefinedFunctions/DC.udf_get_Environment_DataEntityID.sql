SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019-06-20
-- Description: Get the Database Purpose Code for a DatabaseID
-- =============================================
--SELECT [DC].[udf_get_Environment_DatabaseName]( 'StageArea')
CREATE FUNCTION [DC].[udf_get_Environment_DataEntityID]
(
    -- Add the parameters for the function here
    @DataEntityID INT
)
RETURNS varchar(50)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result varchar(50)

	declare @databaseid INT = (SELECT DC.udf_get_DatabaseID_from_DataEntityID(@DataEntityID))

	declare @DatabaseName VARCHAR(100) = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @databaseid)

    -- Add the T-SQL statements to compute the return value here
    IF(CHARINDEX('PROD_', UPPER(@DatabaseName))>0 OR CHARINDEX('PRODUCTION_', UPPER(@DatabaseName))>0 OR CHARINDEX('_PROD', UPPER(@DatabaseName))>0)
		SET @Result = 'PROD'
	ELSE IF(CHARINDEX('UAT_', UPPER(@DatabaseName))>0 OR CHARINDEX('TEST_', UPPER(@DatabaseName))>0 OR CHARINDEX('_TEST', UPPER(@DatabaseName))>0 OR CHARINDEX('_UAT', UPPER(@DatabaseName))>0)
		SET @Result = 'UAT'
	ELSE IF(CHARINDEX('DEV_', UPPER(@DatabaseName))>0 OR CHARINDEX('DEVELOPMENT_', UPPER(@DatabaseName))>0 OR CHARINDEX('_DEV', UPPER(@DatabaseName))>0)
		SET @Result = 'UAT'
	ELSE 
		SET @Result = 'PROD'

    -- Return the result of the function
    RETURN @Result
END

GO
