SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 2019-07-13
-- Description: Get the equivalent FieldID in a Target Database from a FieldID in the Source Database
-- =============================================
/*SAMPLE EXECUTION:
SELECT [DC].[udf_get_EquivalentFieldID_in_TargetDatabaseID](342264, 7)
SELECT * FROM [DC].[vw_rpt_DatabaseFieldDetail] WHERE FieldID IN (342264, 697221)
*/
CREATE FUNCTION [DC].[udf_get_EquivalentFieldID_in_TargetDatabaseID]
(
    @SourceFieldID int,
	@TargetDatabaseID int
)
RETURNS int
AS
BEGIN
    DECLARE @Result int

	--Match to equivalent field in Target Database based on SchemaName, DataEntityName and FieldName

    SELECT	@Result = targetF.FieldID
	FROM	[DC].[Field] sourceF
		    INNER JOIN [DC].[DataEntity] sourceDE ON
				sourceDE.DataEntityID = sourceF.DataEntityID
			INNER JOIN [DC].[Schema] sourceS ON
				sourceS.SchemaID = sourceDE.SchemaID
		    INNER JOIN [DC].[Schema] targetS ON
				targetS.DatabaseID = @TargetDatabaseID AND
				targetS.SchemaName = sourceS.SchemaName
			INNER JOIN [DC].[DataEntity] targetDE ON
				targetDE.SchemaID = targetS.SchemaID AND
				targetDE.DataEntityName = sourceDE.DataEntityName
			INNER JOIN [DC].[Field] targetF ON
				targetF.DataEntityID = targetDE.DataEntityID AND
				targetF.FieldName = sourceF.FieldName
	WHERE	sourceF.FieldID = @SourceFieldID

    RETURN @Result
END

GO
