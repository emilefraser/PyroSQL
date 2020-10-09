SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON









-- 
-- SEC_ORG_USER_BASE_HID Polices 
-- 


CREATE FUNCTION rls.[fn_SEC_ORG_USER_BASE_HID_SecPred_Result](@OrganizationNode hierarchyid)
	RETURNS TABLE
	WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS accessResult
	FROM dbo.SEC_ORG_USER_BASE_HID
	WHERE [USERID] = USER_NAME()
		AND @OrganizationNode.IsDescendantOf([OrgNode]) = 1

GO
