SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Lookup the 1st data entity in the chain and return the Source System Abbreviation for the top level data entity
-- =============================================

-- Sample Execution
/*

	select [DC].[udf_get_ODSDataEntityID_From_SourceDataEntityID](63)

*/

CREATE FUNCTION [DC].[udf_get_ODSDataEntityID_From_SourceDataEntityID]
(
    @SourceDataEntityID int
)
RETURNS varchar(50)
AS
BEGIN
    --======================================================================================================================
	--Variable declerations
    DECLARE @Result varchar(50),
			@ODSLevelDataEntityID int,
			@VelocityAbbreviation varchar(20)

		--------------------------------------------------------------------------------------------------------------------
		/*
		-- Testing variables (comment out after use and testing)
		
		DECLARE @SourceDataEntityID int = 498
				--, @VelocityType int = 3

		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================

	--======================================================================================================================
    --Get Velocity Type Description
	-- TODO: Investigate to add keys to the velocity table???
	--======================================================================================================================
	--select	@VelocityAbbreviation = Velocity.[SatelliteDataVelocityTypeCode]
	--from	
	--		(
	--			select	[SatelliteDataVelocityTypeID]
	--					, [SatelliteDataVelocityTypeCode]
	--					, [SatelliteDataVelocityTypeName]
	--			from	DMOD.SatelliteDataVelocityType
	
	--			union all

	--			select	0
	--					, 'KEYS'
	--					, 'Key data'
	--		)Velocity
	--where	[SatelliteDataVelocityTypeID] = @VelocityType
	--======================================================================================================================
    --Get Source to Target DataEntity relationships
	--======================================================================================================================

	IF (SELECT TOP 1 DatabasePurposeCode
		  FROM [DC].[vw_rpt_DatabaseFieldDetail] vw
				INNER JOIN DC.[Database] db ON
					db.DatabaseID = vw.DatabaseID
			   INNER JOIN DC.DatabasePurpose dbp ON
					dbp.DatabasePurposeID = db.DatabasePurposeID
		 WHERE vw.DataEntityID = @SourceDataEntityID
			) = 'ODS'
	BEGIN
		SELECT	@Result = @SourceDataEntityID
	END
	ELSE
	BEGIN

		declare @DataLineage TABLE
		(
			SourceFieldID int
			, SourceDataEntityID int
			, SourceDataEntityName varchar(100)
			, SourceDBID int
			, SourceDBName varchar(50)
			, ParentFieldID int
			, TargetDataEntityID int
			, TargetDataEntityName varchar(100)
			, ParentDBID int
			, ParentDBName varchar(50)
		)

		INSERT INTO @DataLineage(SourceFieldID, SourceDataEntityID, SourceDataEntityName, SourceDBID, SourceDBName, ParentFieldID, TargetDataEntityID, TargetDataEntityName, ParentDBID, ParentDBName)
		select	distinct desource.SourceFieldID AS SourceFieldID
				, desource.DataEntityID AS SourceDataEntityID
				, desource.DataEntityName AS SourceDataEntityName
				, desource.DatabaseID AS SourceDBID
				, desource.DatabaseName AS SourceDBName
				, detarget.TargetFieldID AS ParentFieldID
				, detarget.DataEntityID AS TargetDataEntityID
				, detarget.DataEntityName AS TargetDataEntityName 
				, detarget.DatabaseID AS ParentDBID
				, detarget.DatabaseName AS ParentDBName
		from	
				(
					select	frsource.FieldRelationID, desource.DataEntityID, desource.DataEntityName
							, frsource.SourceFieldID
							, dbsource.DatabaseID
							, dbsource.DatabaseName
					from	DC.FieldRelation frsource
						inner join DC.Field fsource on frsource.SourceFieldID = fsource.FieldID
						inner join DC.DataEntity desource on desource.DataEntityID = fsource.DataEntityID
						inner join DC.[Schema] schemasource on desource.SchemaID = schemasource.SchemaID
						inner join DC.[Database] dbsource on dbsource.DatabaseID = schemasource.DatabaseID
					where	frsource.FieldRelationTypeID = 2
				) desource
			inner join 
				(
					select	frtarget.FieldRelationID, detarget.DataEntityID, detarget.DataEntityName
							, frtarget.TargetFieldID
							, dbtarget.DatabaseID
							, dbtarget.DatabaseName
					from	DC.FieldRelation frtarget
						inner join DC.Field ftarget on frtarget.TargetFieldID = ftarget.FieldID
						inner join DC.DataEntity detarget on detarget.DataEntityID = ftarget.DataEntityID
						inner join DC.[Schema] schematarget on detarget.SchemaID = schematarget.SchemaID
						inner join DC.[Database] dbtarget on dbtarget.DatabaseID = schematarget.DatabaseID
					where	frtarget.FieldRelationTypeID = 2
				) detarget 
				ON desource.FieldRelationID = detarget.FieldRelationID
			--order by desource.DatabaseName, detarget.TargetFieldID
			;

		--======================================================================================================================
		--Resolve DataEntity source to target hierarchy
		--======================================================================================================================
		WITH cte_DataLineage 
		AS
			(
			
				select	dlineage.SourceDBID
						, dlineage.SourceDBName
						, dlineage.SourceDataEntityID
						, dlineage.SourceDataEntityName
						, dlineage.SourceFieldID
						, CONVERT(INT, ParentFieldID) AS ParentFieldID
						, ParentDBID
						, ParentDBName
						, TargetDataEntityID
						, TargetDataEntityName
						, 1 as DataLineageLevel 
				from	@DataLineage dlineage
				where	dlineage.SourceDataEntityID = @SourceDataEntityID

				UNION ALL

				select	dlineage.SourceDBID
						, dlineage.SourceDBName
						, dlineage.SourceDataEntityID
						, dlineage.SourceDataEntityName
						, dlineage.SourceFieldID
						, ISNULL(dlineage.ParentFieldID,-99) ParentFieldID
						, dlineage.ParentDBID
						, dlineage.parentDBName
						, dlineage.TargetDataEntityID
						, dlineage.TargetDataEntityName
						, cte.DataLineageLevel + 1 as DataLineageLevel
				from	@DataLineage dlineage
					join cte_DataLineage cte on cte.ParentFieldID = dlineage.SourceFieldID
			)
			SELECT	@ODSLevelDataEntityID = TargetDataEntityID
			FROM	cte_DataLineage cte
				inner join DC.[Database] db on db.DatabaseID = cte.ParentDBID
				inner join DC.[DatabasePurpose] dbp on dbp.DatabasePurposeID = db.DatabasePurposeID
			WHERE	dbp.DatabasePurposeCode = 'ODS'
		
		
			/*
			--======================================================================================================================
			-- This code is left here for testing purposes
			--======================================================================================================================

			SELECT	distinct SourceDBID, SourceDBName, SourceDataEntityID, SourceDataEntityName, ParentDBID, ParentDBName, dbp.DatabasePurposeCode, TargetDataEntityID, TargetDataEntityName
			FROM	cte_DataLineage cte
				inner join DC.[Database] db on db.DatabaseID = cte.ParentDBID
				inner join DC.[DatabasePurpose] dbp on dbp.DatabasePurposeID = db.DatabasePurposeID
			WHERE	dbp.DatabasePurposeCode = 'ODS'
		
			--*/
		--======================================================================================================================	
		--Lookup Source System Abbreviation for the top level data entity
		--======================================================================================================================
	
		SELECT	@Result = @ODSLevelDataEntityID

	END

	--======================================================================================================================
    -- Return the result of the function
	--======================================================================================================================
	
	RETURN @Result

END


GO
