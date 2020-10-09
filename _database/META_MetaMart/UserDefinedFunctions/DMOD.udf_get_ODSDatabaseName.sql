SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019



-- Sample Execution Statement
--	Select [DMOD].[udf_get_ODSDatabaseName]()
*/
CREATE FUNCTION [DMOD].[udf_get_ODSDatabaseName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @LoadConfigID INT = 3804
	DECLARE @ODSDatabaseName VARCHAR(MAX)

	DECLARE @SourceDataEntityID INT
	DECLARE @TargetDataEntityID INT
	DECLARE @SourceDatabaseID INT
	DECLARE @TargetDatabaseID INT
	DECLARE @SourceDatabasePurpose VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	--SELECT @SourceDataEntityID, @TargetDataEntityID

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	--SELECT @SourceDatabaseID, @TargetDatabaseID

	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
	--SELECT @SourceDatabasePurpose, @TargetDatabasePurpose

	IF(@SourceDatabasePurpose = 'ODS' OR @SourceDatabasePurpose = 'DataManager')
		SET @ODSDatabaseName = 
		(
			SELECT db.DatabaseName FROM DC.[Database] AS db WHERE db.DatabaseID = @SourceDatabaseID
		)

	ELSE IF(@TargetDatabasePurpose = 'ODS' OR @TargetDatabasePurpose = 'DataManager')
		SET @ODSDatabaseName = 
		(
			SELECT db.DatabaseName FROM DC.[Database] AS db WHERE db.DatabaseID = @TargetDatabaseID
		)

	IF @ODSDatabaseName IS NULL 
			SET @ODSDatabaseName = 'ODS'

		
	RETURN QUOTENAME(@ODSDatabaseName)
		/*
	select @ODSDatabaseName
	*/
	

		END
		

GO
