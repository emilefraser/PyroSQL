SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-09-14
-- Description:	Return the detail type records from TYPE.Generic_Detail for the selected Header Type Code
-- =============================================
CREATE FUNCTION [DC].[tvf_get_DatabasesWithPurpose]
(	
	@DatabasePuproseCode varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT	d.DatabaseID, d.DatabaseName, d.IsActive
			, dp.DatabasePurposeID, dp.DatabasePurposeCode, dp.DatabasePurposeName, dp.DatabasePurposeDescription
	FROM	DC.[Database] d
		LEFT JOIN DC.DatabasePurpose dp
			ON d.DatabasePurposeID = dp.DatabasePurposeID
	WHERE	dp.DatabasePurposeCode = @DatabasePuproseCode
)

GO
