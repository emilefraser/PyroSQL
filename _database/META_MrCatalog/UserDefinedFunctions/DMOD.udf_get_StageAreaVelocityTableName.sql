SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--	Select [DMOD].[udf_get_StageAreaVelocityTableName](55)
--	Select [DMOD].[udf_get_StageAreaVelocityTableName](96)
*/

CREATE FUNCTION [DMOD].[udf_get_StageAreaVelocityTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @LoadConfigID INT = 55
	DECLARE @StageAreaVelocityTableName VARCHAR(MAX) = '';
	DECLARE @TargetDataEntityID INT = (SELECT DMOD.udf_get_LoadConfig_TargetDataEntityID(@LoadConfigID))
	DECLARE @TargetDataEntityName VARCHAR(150) = (SELECT DC.udf_GetDataEntityNameForDataEntityID(@TargetDataEntityID))
	DECLARE @TargetSchemaID INT =(SELECT Target_SchemaID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)
	DECLARE @TargetDatabaseID INT =(SELECT Target_DatabaseID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)

	DECLARE @EntityType AS VARCHAR(100) = 
	(
		SELECT 
			DataEntityTypeCode
		FROM 
			DMOD.LoadConfig AS lc
		INNER JOIN 
			DMOD.LoadType AS lt 
		ON 
			lc.LoadTypeID = lt.LoadTypeID
		INNER JOIN 
			DC.DataEntityType AS det
		ON 
			det.DataEntityTypeID = lt.DataEntityTypeID
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)


	IF (@EntityType <> 'KEYS')
	BEGIN 
		SET @StageAreaVelocityTableName = QUOTENAME(@TargetDataEntityName)
	END
	ELSE
	BEGIN

			-- START WITH HIGEST VELOCITY AND WORK YOURSELF DOWN
			 SET  @StageAreaVelocityTableName = REPLACE(@TargetDataEntityName, 'KEYS', 'HVD')

			 IF NOT EXISTS 
			 (
				SELECT 1 FROM DC.vw_rpt_DatabaseFieldDetail 
				WHERE 
					DataEntityName = @StageAreaVelocityTableName
				AND
					DatabaseID = @TargetDatabaseID
				AND 
					SchemaID = @TargetSchemaID
			 )
			 BEGIN
				SET  @StageAreaVelocityTableName = REPLACE(@TargetDataEntityName, 'KEYS', 'MVD')
			 END

			  ELSE IF NOT EXISTS 
			 (
				SELECT 1 FROM DC.vw_rpt_DatabaseFieldDetail 
				WHERE 
					DataEntityName = @StageAreaVelocityTableName
				AND
					DatabaseID = @TargetDatabaseID
				AND 
					SchemaID = @TargetSchemaID
			 )
			 BEGIN
				SET  @StageAreaVelocityTableName = REPLACE(@TargetDataEntityName, 'KEYS', 'LVD')
			 END

			 ELSE
			 BEGIN 
				SET  @StageAreaVelocityTableName = ''
			 END
		END

		--SELECT @StageAreaVelocityTableName

	RETURN @StageAreaVelocityTableName;
END;

GO
