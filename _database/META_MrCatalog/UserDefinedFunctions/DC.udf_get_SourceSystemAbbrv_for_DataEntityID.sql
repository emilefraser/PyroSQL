SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Lookup the 1st data entity in the chain and return the Source System Abbreviation for the top level data entity
-- =============================================

-- Sample Execution
/*

	select [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID](7128)

*/

CREATE FUNCTION [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID]
(
    @DataEntityID int
)
RETURNS varchar(50)
AS
BEGIN

    --======================================================================================================================
	--Variable declerations
	--======================================================================================================================
    -- Test Variables
	/*
		
		DECLARE @DataEntityID int = 4741

	--*/
	
	DECLARE @Result varchar(50)

	--======================================================================================================================
	--Function logic
	--======================================================================================================================
	SELECT	@Result = CASE WHEN schema_sys.SystemID IS NOT NULL
						THEN schema_sys.SystemAbbreviation
						ELSE db_sys.SystemAbbreviation
					  END
	FROM	DC.DataEntity de
		inner join DC.[Schema] sc on sc.SchemaID = de.SchemaID
		inner join DC.[Database] db on db.DatabaseID = sc.DatabaseID
		left join DC.[System] schema_sys on schema_sys.SystemID = sc.SystemID
		left join DC.[System] db_sys on db_sys.SystemID = db.SystemID
	where	de.DataEntityID = @DataEntityID
	
    RETURN @Result


END

GO
