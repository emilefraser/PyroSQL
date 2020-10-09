SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
/*
-- Sample Execution: select [DMOD].[udf_get_WhereClause_IncrementalLoads](26)

-- !~ IncrementalWithHistoryUpdate where clause		
		WHERE
			  (
				StandardAlias1.[Created_Date] > @LastCreateDT
				AND StandardAlias1.[Created_Date] <= CASE WHEN @IsTest = 1 THEN @Today ELSE '9999/12/31 23:59:59' END
			  )
			  OR 
			  (
				StandardAlias1.[Updated_By] > @LastUpdateDT
				AND StandardAlias1.[Updated_By] <= CASE WHEN @IsTest = 1 THEN @Today ELSE '9999/12/31 23:59:59' END
			  )
-- End of IncrementalWithHistoryUpdate where clause ~!
*/

CREATE FUNCTION [DMOD].[udf_get_WhereClause_IncrementalLoads]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @WhereStatement varchar(MAX) = ''
	DECLARE @CreatedDT_FieldName VARCHAR(150) = (SELECT [DMOD].[udf_get_SatelliteCreatedDT_Last_Field](@LoadConfigID))
	DECLARE @UpdatedDT_FieldName VARCHAR(150) = (SELECT [DMOD].[udf_get_SatelliteUpdatedDT_Last_Field](@LoadConfigID))

	SELECT @WhereStatement = @WhereStatement + '-- !~ Incremental Loads Where Clause ' + CHAR(13)		
	
	SELECT @WhereStatement = @WhereStatement + 
	'
			  (
				[StandardAlias1].' + @CreatedDT_FieldName + ' > @LastCreateDT
				AND [StandardAlias1].' + @CreatedDT_FieldName + ' <= CASE WHEN @IsTest = 1 THEN @Today ELSE ''9999/12/31 23:59:59'' END
			  )
			  OR 
			  (
				[StandardAlias1].' + @UpdatedDT_FieldName + ' > @LastUpdateDT
				AND [StandardAlias1].' + @UpdatedDT_FieldName + ' <= CASE WHEN @IsTest = 1 THEN @Today ELSE ''9999/12/31 23:59:59'' END
			  )' + CHAR(13)

	SELECT @WhereStatement = @WhereStatement + '-- End of Incremental Loads Where Clause ~!'

	RETURN @WhereStatement
END




GO
