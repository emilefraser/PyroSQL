SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 create procedure [dbo].[sp_DTA_query_detail_helper_relational]
			@SessionID		int
			as
			begin select "Statement Id" =QueryID, "Statement String" =StatementString, "Statement Type" = CASE 
					WHEN StatementType = 0 THEN 'Select'
					WHEN StatementType = 1 THEN 'Update'
					WHEN StatementType = 2 THEN 'Insert'
					WHEN StatementType = 3 THEN 'Delete'
					WHEN StatementType = 4 THEN 'Merge'
					end,"Current Statement Cost" =CAST(CurrentCost as decimal(38,7)), "Recommended Statement Cost" =CAST(RecommendedCost as decimal(38,7)), "Event String" =EventString	from [MrTweak].[dbo].[DTA_reports_query]
						where SessionID=@SessionID  order by QueryID ASC end 

GO
