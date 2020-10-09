SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
	create procedure [dbo].[sp_DTA_wkld_analysis_helper_relational]
						@SessionID		int
						as
						begin	select "Statement Type" = CASE 
						WHEN StatementType = 0 THEN 'Select'
						WHEN StatementType = 1 THEN 'Update'
						WHEN StatementType = 2 THEN 'Insert'
						WHEN StatementType = 3 THEN 'Delete'
						WHEN StatementType = 4 THEN 'Merge'
						end, "Number of Statements" =COUNT(QueryID), "Cost Decreased" =SUM(CASE
															WHEN RecommendedCost<CurrentCost THEN 1 else 0 end), "Cost Increased" =SUM(CASE
						WHEN RecommendedCost>CurrentCost THEN 1 else 0 end), "No Change" =SUM(CASE
						WHEN RecommendedCost=CurrentCost THEN 1 else 0 end) 	from 
						[MrTweak].[dbo].[DTA_reports_query]
						where 
						SessionID=@SessionID group by StatementType  end 

GO
