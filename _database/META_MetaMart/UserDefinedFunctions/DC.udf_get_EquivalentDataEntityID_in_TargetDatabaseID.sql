SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 2019-07-13
-- Description: Get the equivalent DataEntityID in a Target Database from a DataEntityID in the Source Database
-- =============================================
/*SAMPLE EXECUTION:
SELECT [DC].[udf_get_EquivalentDataEntityID_in_TargetDatabaseID](32926, 7)
SELECT * FROM [DC].[vw_rpt_DatabaseFieldDetail] WHERE DataEntityID IN (32926, 38988) ORDER BY DatabaseID, FieldSortOrder
*/
CREATE FUNCTION [DC].[udf_get_EquivalentDataEntityID_in_TargetDatabaseID]
(
    @SourceDataEntityID int,
	@TargetDatabaseID int
)
RETURNS int
AS
BEGIN
    DECLARE @Result int

	--Match to equivalent DataEntity in Target Database based on SchemaName and DataEntityName

    SELECT	@Result = targetDE.DataEntityID
	FROM	[DC].[DataEntity] sourceDE
			INNER JOIN [DC].[Schema] sourceS ON
				sourceS.SchemaID = sourceDE.SchemaID
		    INNER JOIN [DC].[Schema] targetS ON
				targetS.DatabaseID = @TargetDatabaseID AND
				targetS.SchemaName = sourceS.SchemaName
			INNER JOIN [DC].[DataEntity] targetDE ON
				targetDE.SchemaID = targetS.SchemaID AND
				targetDE.DataEntityName = sourceDE.DataEntityName
	WHERE	sourceDE.DataEntityID = @SourceDataEntityID

    RETURN @Result
END


/* SAMPLE EXECUTION:
EXEC [DC].[sp_LeftRightFieldComparison] 6, 7
*/

GO
