SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 create procedure [dbo].[sp_DTA_query_cost_helper_relational]
			@SessionID		int
			as
			begin 	select "Statement Id" = QueryID, "Statement String" = StatementString, "Percent Improvement" = 	
					CASE
						WHEN CurrentCost = 0 THEN 0.00
						WHEN CurrentCost <> 0 THEN
						CAST((100.0*(CurrentCost - RecommendedCost)/CurrentCost) as decimal (20,2))
					end , "Statement Type" = CASE 
							WHEN StatementType = 0 THEN 'Select'
							WHEN StatementType = 1 THEN 'Update'
							WHEN StatementType = 2 THEN 'Insert'
							WHEN StatementType = 3 THEN 'Delete'
							WHEN StatementType = 4 THEN 'Merge'
							end 	from [MrTweak].[dbo].[DTA_reports_query]
					where SessionID=@SessionID
					order by "Percent Improvement" desc  end 

GO
