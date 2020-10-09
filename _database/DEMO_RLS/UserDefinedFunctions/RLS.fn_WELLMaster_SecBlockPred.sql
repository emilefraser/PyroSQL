SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- 
-- Block Predicate on WELL_MASTER
-- 

-- Create a New Function to only Allow Authorized Well creation users (via Exception table)
-- access to Add new Wells to WELL_MASTER

CREATE FUNCTION [rls].[fn_WELLMaster_SecBlockPred]()
    RETURNS TABLE 
	WITH SCHEMABINDING
AS
    return SELECT 1 as [fn_WELLMaster_SecBlockPred] 
	    WHERE
		(
		    'WELLAUTH' in (select HIERARCHY_VALUE from dbo.SEC_USER_EXCEPTIONS 
			            where USERID = USER_NAME())
		)

GO
