SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Lookup the 1st data entity in the chain and return the Source System Abbreviation for the top level data entity
-- =============================================

-- Sample Execution
/*

	select DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(7128)

*/

CREATE FUNCTION [DC].[udf_get_TopLevelParentDataEntity_SourceSystemAbbr]
(
    -- Add the parameters for the function here
    @DataEntityID int
)
RETURNS varchar(50)
AS
BEGIN
    --======================================================================================================================
	--Variable declerations
    DECLARE @Result varchar(50),
			@TopLevelDataEntity int

		--------------------------------------------------------------------------------------------------------------------
		/*
		-- Testing variables (comment out after use and testing)
		
		DECLARE @DataEntityID int = 7182

		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================

	--======================================================================================================================
    --Get Source to Target DataEntity relationships
	--======================================================================================================================
	declare @DataLineage TABLE
	(
		DataEntity int
		, ParentDataEntityID int
	)

	INSERT INTO @DataLineage(DataEntity, ParentDataEntityID)
	select	distinct detarget.DataEntityID as DataEntity
			, desource.DataEntityID as ParentDataEntityID
	from	
			(
				select	frsource.FieldRelationID, desource.DataEntityID, desource.DataEntityName
				from	DC.FieldRelation frsource
					inner join DC.Field fsource on frsource.SourceFieldID = fsource.FieldID
					inner join DC.DataEntity desource on desource.DataEntityID = fsource.DataEntityID
				where	frsource.FieldRelationTypeID = 2
			) desource
		inner join 
			(
				select	frtarget.FieldRelationID, detarget.DataEntityID, detarget.DataEntityName
				from	DC.FieldRelation frtarget
					inner join DC.Field ftarget on frtarget.TargetFieldID = ftarget.FieldID
					inner join DC.DataEntity detarget on detarget.DataEntityID = ftarget.DataEntityID
				where	frtarget.FieldRelationTypeID = 2
			) detarget 
			ON desource.FieldRelationID = detarget.FieldRelationID;

	--======================================================================================================================
	--Resolve DataEntity source to target hierarchy
	--======================================================================================================================
	WITH cte_DataLineage 
	AS
		(
			
			select	dlineage.DataEntity
					, CONVERT(INT, ParentDataEntityID) AS ParentDataEntityID
					, 1 as DataLineageLevel 
			from	@DataLineage dlineage
			where	dlineage.DataEntity = @DataEntityID

			UNION ALL

			select	dlineage.DataEntity
					, ISNULL(dlineage.ParentDataEntityID,-99) ParentDataEntityID
					, cte.DataLineageLevel + 1 as DataLineageLevel
			from	@DataLineage dlineage
				join cte_DataLineage cte on cte.ParentDataEntityID = dlineage.DataEntity
		)
		SELECT	@TopLevelDataEntity = ParentDataEntityID
		FROM	cte_DataLineage cte
		WHERE	DataLineageLevel = (select top 1 MAX(DataLineageLevel) from cte_DataLineage)
	
	--======================================================================================================================	
	--Lookup Source System Abbreviation for the top level data entity
	--======================================================================================================================
	SELECT	@Result = DC.udf_get_DataEntity_SourceSystemAbbreviation(@TopLevelDataEntity)

	--======================================================================================================================
    -- Return the result of the function
	--======================================================================================================================
    RETURN @Result
END

GO
