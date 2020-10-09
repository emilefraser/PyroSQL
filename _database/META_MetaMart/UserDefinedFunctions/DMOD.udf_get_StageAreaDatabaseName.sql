SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

*/

-- Sample Execution Statement
--	Select [DMOD].[udf_get_StageAreaDatabaseName](20)

CREATE FUNCTION [DMOD].[udf_get_StageAreaDatabaseName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- >DEBUG< --
	--DECLARE @LoadConfigID INT = 1
	-- >DEBUG< --

	DECLARE @StageAreaDatabaseName VARCHAR(MAX)

	DECLARE @SourceDataEntityID INT
	DECLARE @TargetDataEntityID INT
	DECLARE @SourceDatabaseID INT
	DECLARE @TargetDatabaseID INT
	DECLARE @SourceDatabasePurpose VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
    DECLARE @SourceDatabaseEnvironmentID INT
    DECLARE @TargetDatabaseEnvironmentID INT
	DECLARE @TargetDatabaseEnvironmentType VARCHAR(MAX)
	DECLARE @StageAreaDatabaseID AS INT
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))

	----Get the DB Environment of the databases
    SET @SourceDatabaseEnvironmentID = (SELECT DetailID AS SourceEnvironment FROM TYPE.Generic_Detail WHERE DetailTypeCode = (SELECT DC.udf_get_DatabaseEnvironmentCode(@SourceDatabaseID)))
    SET @TargetDatabaseEnvironmentID = (SELECT DetailID AS TargetEnvironment FROM TYPE.Generic_Detail WHERE DetailTypeCode = (SELECT DC.udf_get_DatabaseEnvironmentCode(@TargetDatabaseID)))
    --SELECT @SourceDatabaseEnvironment SourceDatabaseEnvironment, @TargetDatabaseEnvironment TargetDatabaseEnviroment

	IF(@SourceDatabasePurpose = 'StageArea')
		SET @StageAreaDatabaseName = 
		(
			SELECT db.DatabaseName FROM DC.[Database] AS db WHERE db.DatabaseID = @SourceDatabaseID
		)

	ELSE IF(@TargetDatabasePurpose = 'StageArea')
		SET @StageAreaDatabaseName = 
		(
			SELECT db.DatabaseName FROM DC.[Database] AS db WHERE db.DatabaseID = @TargetDatabaseID
		)

	ELSE
	BEGIN
		SET @TargetDatabaseEnvironmentType = (SELECT DetailTypeCode AS TargetEnvironment FROM TYPE.Generic_Detail WHERE DetailTypeCode = (SELECT DC.udf_get_DatabaseEnvironmentCode(@TargetDatabaseID)))
		SET @StageAreaDatabaseID = (SELECT [DC].[udf_get_DatabaseID_DatabasePurposeCode_DatabaseEnvironmentType]('StageArea', @TargetDatabaseEnvironmentType))
		SET @StageAreaDatabaseName = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @StageAreaDatabaseID)
	END

	RETURN QUOTENAME(@StageAreaDatabaseName)

END


GO
