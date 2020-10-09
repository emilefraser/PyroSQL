SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_query_cost_helper_xml] 
	@SessionID int 
as 
begin
	select 1            as Tag, 
			NULL          as Parent,
			'' as [StatementCostReport!1!!element],
			NULL as [Statement!2!StatementID!ELEMENT],
			NULL as [Statement!2!StatementString!ELEMENT] ,
			NULL as [Statement!2!PercentImprovement!ELEMENT],
			NULL as [Statement!2!Type!ELEMENT]
	union all

	select 2            as Tag, 
			1          as Parent,
			NULL as [StatementCostReport!1!!element],
			QueryID as [Statement!2!StatementID!ELEMENT],
			StatementString as [Statement!2!StatementString!ELEMENT] ,
			CASE
				WHEN CurrentCost = 0 THEN 0.00
				WHEN CurrentCost <> 0 THEN
				CAST((100.0*(CurrentCost - RecommendedCost)/CurrentCost) as decimal (20,2))
			end as [Statement!2!PercentImprovement!ELEMENT],
			CASE 
				WHEN StatementType = 0 THEN 'Select'
				WHEN StatementType = 1 THEN 'Update'
				WHEN StatementType = 2 THEN 'Insert'
				WHEN StatementType = 3 THEN 'Delete'
				WHEN StatementType = 4 THEN 'Merge'
			end  as  [Statement!2!Type!ELEMENT]

	from [MrTweak].[dbo].[DTA_reports_query]
	where SessionID=@SessionID
	order by Tag,[Statement!2!PercentImprovement!ELEMENT] desc
	FOR XML EXPLICIT
end

GO
