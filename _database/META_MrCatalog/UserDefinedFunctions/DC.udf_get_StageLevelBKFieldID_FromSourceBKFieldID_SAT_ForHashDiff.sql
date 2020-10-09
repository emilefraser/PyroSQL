SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Lookup the 1st data entity in the chain and return the Source System Abbreviation for the top level data entity
-- =============================================

-- Sample Execution
/*

	select DC.[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](6)

*/

CREATE FUNCTION [DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID_SAT_ForHashDiff]
(
    -- Add the parameters for the function here
    @SourceFieldID int
	, @VelocityType int -- (can be 0 - Keys, 1 - LVD, 2 - MVD, 3 - HVD)
)
RETURNS varchar(50)
AS
BEGIN
    --======================================================================================================================
	--Variable declerations
    DECLARE @Result varchar(50),
			@StageLevelFieldID int,
			@VelocityAbbreviation varchar(20)

		--------------------------------------------------------------------------------------------------------------------
--		/*
		-- Testing variables (comment out after use and testing)
		
		--DECLARE @SourceFieldID int = 163146
		--		, @VelocityType int = 2

		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================

	--======================================================================================================================
    --Get Velocity Type Description
	-- TODO: Investigate to add keys to the velocity table???
	--======================================================================================================================
	select	@VelocityAbbreviation = Velocity.[SatelliteDataVelocityTypeCode]
	from	
			(
				select	[SatelliteDataVelocityTypeID]
						, [SatelliteDataVelocityTypeCode]
						, [SatelliteDataVelocityTypeName]
				from	DMOD.SatelliteDataVelocityType
	
				union all

				select	0
						, 'KEYS'
						, 'Key data'
			)Velocity
	where	[SatelliteDataVelocityTypeID] = @VelocityType
	--======================================================================================================================
    --Get Source to Target DataEntity relationships
	--======================================================================================================================
	declare @DataLineage TABLE
	(
		SourceFieldID int
		, SourceFieldName varchar(100)
		, SourceDataEntityName varchar(100)
		, SourceDBName varchar(50)
		, ParentFieldID int
		, ParentFieldName varchar(100)
		, TargetDataEntityName varchar(100)
		, ParentDBName varchar(50)
	)

	INSERT INTO @DataLineage(SourceFieldID, SourceFieldName, SourceDataEntityName, SourceDBName, ParentFieldID, ParentFieldName, TargetDataEntityName, ParentDBName)
	select	distinct desource.SourceFieldID AS SourceFieldID
			, desource.FieldName AS SourceFieldName
			, desource.DataEntityName AS SourceDataEntityName
			, desource.DatabaseName AS SourceDBName
			, detarget.TargetFieldID AS ParentFieldID
			, detarget.FieldName AS TargetFieldName
			, detarget.DataEntityName AS TargetDataEntityName 
			, detarget.DatabaseName AS ParentDBName
	from	
			(
				select	frsource.FieldRelationID, desource.DataEntityID, desource.DataEntityName
						, frsource.SourceFieldID
						, fsource.FieldName
						, dbsource.DatabaseName
				from	DC.FieldRelation frsource
					inner join DC.Field fsource on frsource.SourceFieldID = fsource.FieldID
					inner join DC.DataEntity desource on desource.DataEntityID = fsource.DataEntityID
					inner join DC.[Schema] schemasource on desource.SchemaID = schemasource.SchemaID
					inner join DC.[Database] dbsource on dbsource.DatabaseID = schemasource.DatabaseID
				where	frsource.FieldRelationTypeID = 2
					and fsource.FieldID = @SourceFieldID
			) desource
		inner join 
			(
				select	frtarget.FieldRelationID, detarget.DataEntityID, detarget.DataEntityName
						, frtarget.TargetFieldID
						, ftarget.FieldName
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
			
			select	dlineage.SourceFieldID
					, SourceFieldName
					, CONVERT(INT, ParentFieldID) AS ParentFieldID
					, ParentDBName
					, TargetDataEntityName
					, ParentFieldName
					, 1 as DataLineageLevel 
			from	@DataLineage dlineage
			where	dlineage.SourceFieldID = @SourceFieldID

			UNION ALL

			select	dlineage.SourceFieldID
					, dlineage.SourceFieldName
					, ISNULL(dlineage.ParentFieldID,-99) ParentFieldID
					, dlineage.parentDBName
					, dlineage.TargetDataEntityName
					, dlineage.ParentFieldName
					, cte.DataLineageLevel + 1 as DataLineageLevel
			from	@DataLineage dlineage
				join cte_DataLineage cte on cte.ParentFieldID = dlineage.SourceFieldID
		)
		SELECT	@StageLevelFieldID = ParentFieldID
		FROM	cte_DataLineage cte
		where ParentFieldName = 'HashDiff'
		AND cte.SourceFieldID = @SourceFieldID
		AND	cte.ParentDBName like '%Stage%' --TODO: Replace this with switch fields when they get introduced into the DC (hard coded to DB name for now)
		AND cte.TargetDataEntityName like '%' + @VelocityAbbreviation
		--AND cte.ParentFieldName like '%BKHash%'


	--======================================================================================================================	
	--Lookup Source System Abbreviation for the top level data entity
	--======================================================================================================================
	SELECT	@Result = @StageLevelFieldID
	--======================================================================================================================
    -- Return the result of the function
	--======================================================================================================================
    RETURN @Result

END


GO
