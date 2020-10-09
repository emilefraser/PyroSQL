SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_query_detail_helper_xml] 
	@SessionID int 
as 
begin
	select 1            as Tag, 
			NULL          as Parent,
			'' as [StatementDetailReport!1!!element],
			NULL as [Statement!2!StatementID!ELEMENT] ,
			NULL as [Statement!2!StatementString!ELEMENT] ,
			NULL as [Statement!2!Type!ELEMENT],
			NULL as [Statement!2!CurrentCost!ELEMENT],
			NULL as [Statement!2!RecommendedCost!ELEMENT],
			NULL as [Statement!2!EventString!ELEMENT]
	union all

	select 2            as Tag, 
			1          as Parent,
			NULL as [QueryCost!1!!element],
			QueryID as [Statement!2!StatementID!ELEMENT],
			StatementString as [Statement!2!StatementString!ELEMENT] ,
			CASE 
				WHEN StatementType = 0 THEN 'Select'
				WHEN StatementType = 1 THEN 'Update'
				WHEN StatementType = 2 THEN 'Insert'
				WHEN StatementType = 3 THEN 'Delete'
				WHEN StatementType = 4 THEN 'Merge'
			end  as  [Statement!2!Type!ELEMENT!element],
			CAST(CurrentCost as decimal(38,7)) as	 [Statement!2!CurrentCost!ELEMENT],
			CAST(RecommendedCost as decimal(38,7)) as  [Statement!2!RecommendedCost!ELEMENT],
			EventString as [Statement!2!EventString!ELEMENT]
	from [MrTweak].[dbo].[DTA_reports_query]
	where SessionID=@SessionID
	FOR XML EXPLICIT
end

GO
