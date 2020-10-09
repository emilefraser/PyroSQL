SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
 Author:      Emile Fraser
 Create Date: 6 June 2019
 Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix

--!~ Field List with alias - Stage
					StandardAlias.[EMP_EMPNO],
					StandardAlias.[HK_DPT_CODE],
					StandardAlias.[LINKHK_DEPARTMENT_EMPLOYEE]
-- End of Field List with alias - Stage

*/

-- Sample Execution Statement
--	SELECT [DMOD].[udf_get_FieldList_WithAlias_Stage](55)
--  SELECT [DMOD].[udf_get_FieldList_WithAlias_Stage](96)

CREATE FUNCTION [DMOD].[udf_get_FieldList_WithAlias_Stage](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @Stage_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_TargetDataEntityID](@LoadConfigID))

	DECLARE @FieldList VARCHAR(MAX) = '';

	SELECT @FieldList = @FieldList + '--!~ Field List with alias - Stage' + CHAR(13)

	SELECT 
		@FieldList =  @FieldList + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + '[' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + [vrdfd].[FieldName] + '],' + CHAR(13)
	FROM 
		[DC].[vw_rpt_DatabaseFieldDetail] AS [vrdfd]
	WHERE
		[vrdfd].[DataEntityID] = @Stage_DataEntityID
	AND 
		[vrdfd].[FieldName] NOT IN
		(
			'BKHash'
		,	'LoadDT'
		,	'RecSrcDataEntityID'
		,	'HashDiff'
		) -- FUTURE: Make this a configurable list that reads from a standarised structure
	ORDER BY 
		[vrdfd].[FieldSortOrder]
	
	IF @FieldList != ''
	BEGIN
		SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 2)
	END;

	--Add line feeds
	--SET		@FieldList = REPLACE(@FieldList, ',', ',' + char(10))
	SELECT @FieldList = @FieldList + CHAR(13) + '-- End of Field List with alias - Stage ~!' + CHAR(13)

	RETURN @FieldList;

END;

GO
