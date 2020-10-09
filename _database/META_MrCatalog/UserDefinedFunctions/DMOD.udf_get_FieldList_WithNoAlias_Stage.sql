SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
 Author:      Emile Fraser
 Create Date: 6 June 2019
 Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix

--!~ Field List with alias - Stage
					[EMP_EMPNO],
					[HK_DPT_CODE],
					[LINKHK_DEPARTMENT_EMPLOYEE]
-- End of Field List with alias - Stage ~!

*/

-- Sample Execution Statement
--	Select [DMOD].[udf_get_FieldList_WithNoAlias_Stage](55)
-- Select [DMOD].[udf_get_FieldList_WithNoAlias_Stage](96)

-- SELECT [DMOD].[udf_get_FieldList_WithNoAlias_Stage](58183)

CREATE FUNCTION [DMOD].[udf_get_FieldList_WithNoAlias_Stage](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @SourceDatabasePurpose VARCHAR(20) = (SELECT DC.udf_get_DatabasePurposeCode((SELECT Source_DatabaseID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)))
	DECLARE @TargetDatabasePurpose VARCHAR(20)  = (SELECT DC.udf_get_DatabasePurposeCode((SELECT Target_DatabaseID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)))
	DECLARE @Stage_DataEntityID INT

	IF (@TargetDatabasePurpose = 'StageArea')
	BEGIN
		SET @Stage_DataEntityID = (SELECT [DMOD].[udf_get_LoadConfig_TargetDataEntityID](@LoadConfigID))
	END
	ELSE IF (@SourceDatabasePurpose = 'StageArea')
	BEGIN
		SET @Stage_DataEntityID = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))
	END

	ELSE
	BEGIN
		RETURN 'No Stage FieldList, Not Stage Entity'
	END


	DECLARE @FieldList VARCHAR(MAX) = '';

	SELECT @FieldList = @FieldList + '--!~ Field List with no alias - Stage' + CHAR(13)

	SELECT 
		@FieldList =  @FieldList + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + '[' + [vrdfd].[FieldName] + '],' + CHAR(13)
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
	SELECT @FieldList = @FieldList + CHAR(13) + '-- End of Field List with no alias - Stage ~!' + CHAR(13)

	--PRINT @FieldList
	RETURN @FieldList;

END;

GO
