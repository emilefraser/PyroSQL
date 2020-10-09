SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Lookup the 1st data entity in the chain and return the Source System Abbreviation for the top level data entity
-- =============================================

-- Sample Execution
/*

	select [DC].[udf_get_FieldName_From_FieldID](350184)

*/

CREATE FUNCTION [DC].[udf_get_FieldName_From_FieldID]
(
    @FieldID int
)
RETURNS varchar(200)
AS
BEGIN
    --======================================================================================================================
	--Variable declerations
    DECLARE @FieldName varchar(200)

	SELECT	@FieldName = f.FieldName FROM [DC].[Field] AS f WHERE f.FieldID = @FieldID
	
	RETURN @FieldName

END



GO
