SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_wkld_analysis_helper_xml]
						@SessionID		int
as
begin
	select 1            as Tag, 
			NULL          as Parent,
			'' as [WorkloadAnalysisReport!1!!ELEMENT],
			NULL  as [Statements!2!Type!ELEMENT] ,
			NULL as [Statements!2!NumberOfStatements!ELEMENT],
			NULL as [Statements!2!CostDecreased!ELEMENT],
			NULL as [Statements!2!CostIncreased!ELEMENT],
			NULL as [Statements!2!CostSame!ELEMENT]
		union all
	select 2            as Tag, 
			1          as Parent,
			NULL as [WorkloadAnalysis!1!!ELEMENT],
			CASE 
							WHEN StatementType = 0 THEN 'Select'
							WHEN StatementType = 1 THEN 'Update'
							WHEN StatementType = 2 THEN 'Insert'
							WHEN StatementType = 3 THEN 'Delete'
							WHEN StatementType = 4 THEN 'Merge'
			end  as [Statements!2!Type!ELEMENT] ,
			COUNT(QueryID) as [Statements!2!NumberOfStatements!ELEMENT],
			SUM(CASE WHEN RecommendedCost<CurrentCost THEN 1 else 0 end) as [Statements!2!CostDecreased!ELEMENT],
			SUM(CASE WHEN RecommendedCost>CurrentCost THEN 1 else 0 end) as [Statements!2!CostIncreased!ELEMENT],
			SUM(CASE WHEN RecommendedCost=CurrentCost THEN 1 else 0 end) as [Statements!2!CostSame!ELEMENT]
			from 
			[MrTweak].[dbo].[DTA_reports_query]
			where 
			SessionID=@SessionID
			group by StatementType
			FOR XML EXPLICIT
end						

GO
