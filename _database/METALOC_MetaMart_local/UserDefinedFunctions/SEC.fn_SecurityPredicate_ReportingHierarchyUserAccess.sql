SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [SEC].[fn_SecurityPredicate_ReportingHierarchyUserAccess](@DomainAccount varchar(200), @IsFullAccessUserHierarchy bit)
RETURNS TABLE
AS
RETURN 

SELECT 1 AS fn_SecurityPredicate_ReportingHierarchyUserAccess
WHERE EXISTS (
				SELECT	1
			    WHERE	@DomainAccount = SUSER_NAME()
				

				UNION ALL
			  
				SELECT	1
			    FROM	[DataManager_Local].[ACCESS].[FullAccessUser]
				WHERE	DomainAccountOrGroup = SUSER_NAME()
					--and IsFullAccessUser = 1
					and @IsFullAccessUserHierarchy = 1
					and IsDeveloper = 0

				UNION ALL
			  
				SELECT	1
			    FROM	[DataManager_Local].[ACCESS].[FullAccessUser]
				WHERE	DomainAccountOrGroup = SUSER_NAME()
					and IsFullAccessUser = 0
					and IsDeveloper = 1
			 )

GO
