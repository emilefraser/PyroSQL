SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_query_costrange_helper_xml]
			@SessionID	int
			as
begin
	declare @maxCost float
	declare @minCost float
	declare @maxCurrentCost float
	declare @minCurrentCost float
	declare @maxRecommendedCost float
	declare @minRecommendedCost float
	set nocount on
	select @minCurrentCost = min(CurrentCost*Weight),@maxCurrentCost = max(CurrentCost*Weight),
			@minRecommendedCost = min(RecommendedCost*Weight),
			@maxRecommendedCost = max(RecommendedCost*Weight)
	from [MrTweak].[dbo].[DTA_reports_query]
	where SessionID = @SessionID
	-- Set the bucket boundaries
	if @maxCurrentCost > @maxRecommendedCost
		set @maxCost =  @maxCurrentCost
	else
		set @maxCost =  @maxRecommendedCost

	if @minCurrentCost < @minRecommendedCost
		set @minCost =  @minCurrentCost
	else
		set @minCost =  @minRecommendedCost

	create table #stringmap(OutputString nvarchar(30),num int)
	insert into #stringmap values(N'0% - 10%',0)
	insert into #stringmap values(N'11% - 20%',1)
	insert into #stringmap values(N'21% - 30%',2)
	insert into #stringmap values(N'31% - 40%',3)
	insert into #stringmap values(N'41% - 50%',4)
	insert into #stringmap values(N'51% - 60%',5)
	insert into #stringmap values(N'61% - 70%',6)
	insert into #stringmap values(N'71% - 80%',7)
	insert into #stringmap values(N'81% - 90%',8)
	insert into #stringmap values(N'91% - 100%',9)



	select num,count(*) as cnt
	into #c
	from
	(	select case 
		when (@maxCost=@minCost) then 9 
		when (CurrentCost*Weight-@minCost)/(@maxCost-@minCost) = 1 then 9
		else convert(int,floor(10*(CurrentCost*Weight-@minCost)/(@maxCost-@minCost)))
		end as num
		from
		[MrTweak].[dbo].[DTA_reports_query]
		where CurrentCost*Weight >= @minCost and 
		CurrentCost*Weight <= @maxCost
		and SessionID = @SessionID
	) t
	group by num

	select num,count(*) as cnt
	into #r
	from
	(	select case 
		when (@maxCost=@minCost) then 9 
		when (RecommendedCost*Weight-@minCost)/(@maxCost-@minCost) = 1 then 9
		else convert(int,floor(10*(RecommendedCost*Weight-@minCost)/(@maxCost-@minCost)))
		end as num
		from
		[MrTweak].[dbo].[DTA_reports_query]
		where RecommendedCost*Weight >= @minCost and 
		RecommendedCost*Weight <= @maxCost
		and SessionID = @SessionID
	) t
	group by num

	select 1            as Tag, 
			NULL          as Parent,
			'' as [StatementCostRangeReport!1!!ELEMENT],
			NULL as [CostRange!2!Percent] ,
			NULL as [CostRange!2!NumStatementsCurrent!ELEMENT],
			NULL as [CostRange!2!NumStatementsRecommended!ELEMENT]
	union all
	select 2            as Tag, 
			1          as Parent,
			NULL as [StatementCostRangeReport!1!!ELEMENT],
			OutputString as [CostRange!2!ELEMENT] ,
			ISNULL(c.cnt,0) as [CostRange!2!NumStatementsCurrent!ELEMENT],
			ISNULL(r.cnt,0) as [CostRange!2!NumStatementsRecommended!ELEMENT]
	from
	(
	select #stringmap.num, #r.cnt
	from #stringmap LEFT OUTER JOIN #r
	ON #stringmap.num = #r.num
	) r,
	(
	select #stringmap.num, #c.cnt
	from #stringmap LEFT OUTER JOIN #c
	ON #stringmap.num = #c.num
	) c,
	#stringmap
	where #stringmap.num = r.num and
	#stringmap.num = c.num

	FOR XML EXPLICIT

	drop table #r
	drop table #c
	drop table #stringmap
end

GO
