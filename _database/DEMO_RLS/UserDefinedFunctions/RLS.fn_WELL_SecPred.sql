SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [rls].[fn_WELL_SecPred](@wid int)
    RETURNS TABLE 
	WITH SCHEMABINDING
AS
    return SELECT 1 as [fn_WELL_SecPred_Result]  
		WHERE 
		(
          (@wid in 
			   (select WELL_ID from dbo.WELL_MASTER where DIVISION in (select HIERARCHY_VALUE from dbo.SEC_USER_MAP 
			            where USERID = USER_NAME() and HIERARCHY_NODE = 'DIVISION'))
			   OR
			@wid in    
			   (select WELL_ID from dbo.WELL_MASTER where REGION in (select HIERARCHY_VALUE from dbo.SEC_USER_MAP 
			            where USERID = USER_NAME() and HIERARCHY_NODE = 'REGION'))
			OR
			@wid in    
			   (select WELL_ID from dbo.WELL_MASTER where ASSET_GROUP in (select HIERARCHY_VALUE from dbo.SEC_USER_MAP 
			            where USERID = USER_NAME() and HIERARCHY_NODE = 'ASSET_GROUP'))
			OR
			@wid in    
			   (select WELL_ID from dbo.WELL_MASTER where ASSET_TEAM in (select HIERARCHY_VALUE from dbo.SEC_USER_MAP 
			            where USERID = USER_NAME() and HIERARCHY_NODE = 'ASSET_TEAM'))
			OR
			@wid in    
			   (select WELL_ID from dbo.WELL_MASTER where 'ALL' in (select HIERARCHY_VALUE from dbo.SEC_USER_MAP 
			            where USERID = USER_NAME()))
		)
	  )

GO
