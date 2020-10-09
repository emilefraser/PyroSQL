SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-09-14
-- Description:	Return the detail type records from TYPE.Generic_Detail for the selected Header Type Code
-- =============================================
CREATE FUNCTION [TYPE].[tvf_GenericDetailTypes] 
(	
	@GenericHeaderTypeCode varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	gh.HeaderCode
			, gh.HeaderTypeGroupName
			, gd.DetailID
			, gd.DetailTypeCode
			, gd.DetailTypeDescription
	FROM	TYPE.Generic_Detail gd
		INNER JOIN TYPE.Generic_Header gh
			ON gd.HeaderID = gh.HeaderID
	WHERE	gh.HeaderCode = @GenericHeaderTypeCode
		AND gh.IsActive = 1
		AND gd.IsActive = 1
)

GO
