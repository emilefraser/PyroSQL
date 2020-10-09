SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
/*
-- Sample Execution: select [DMOD].[udf_get_SatelliteCreateDT_Last](46704)

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

CREATE FUNCTION [DMOD].[udf_get_Where_IncrementalLoadWithHistoryUpdate_TOBEDELETED]
(
    @Stage_DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @WhereStatement varchar(MAX) = ''

	SELECT @WhereStatement = @WhereStatement + '-- !~ IncrementalWithHistoryUpdate where clause' + CHAR(13)		

	-- !~ IncrementalWithHistoryUpdate where clause		
	SELECT @WhereStatement = @WhereStatement + 
	'WHERE
			  (
				StandardAlias1.[Created_Date] > @LastCreateDT
				AND StandardAlias1.[Created_Date] <= CASE WHEN @IsTest = 1 THEN @Today ELSE ''9999/12/31 23:59:59'' END
			  )
			  OR 
			  (
				StandardAlias1.[Updated_By] > @LastUpdateDT
				AND StandardAlias1.[Updated_By] <= CASE WHEN @IsTest = 1 THEN @Today ELSE ''9999/12/31 23:59:59'' END
			  )' + CHAR(13)

	SELECT @WhereStatement = @WhereStatement + '-- End of IncrementalWithHistoryUpdate where clause ~!'

	RETURN @WhereStatement
END

GO
