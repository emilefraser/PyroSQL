SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns a field list from the Data Catalog for an INSERT or		`
-- =============================================
-- Sample Execution:
/*
	DECLARE @LoadConfigID INT = 96 --55
	SELECT [DMOD].[udf_get_FieldList_Create_Table_Stage](@LoadConfigID)
*/
CREATE FUNCTION [DMOD].[udf_get_FieldList_Create_Table_Stage]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Stage_DataEntityID INT = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	DECLARE @FieldList varchar(MAX)

	SET @FieldList = (SELECT DC.udf_FieldListForCreateTable(@Stage_DataEntityID))

	SET	@FieldList =	'--!~ Field list for CREATE TABLE - Stage'
						+ CHAR(10)
						+ @FieldList
						+ CHAR(10)
						+ '-- End of Field List for CREATE TABLE Stage ~!'		
	RETURN @FieldList
END




GO
