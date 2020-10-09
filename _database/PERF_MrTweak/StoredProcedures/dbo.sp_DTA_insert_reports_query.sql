SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_reports_query]
	@SessionID			int,
	@QueryID			int,
	@StatementType		smallint,
	@StatementString	nvarchar(max),
	@CurrentCost		float,
	@RecommendedCost	float,
	@Weight				float,
	@EventString		nvarchar(max),
	@EventWeight		float
as
begin
	declare @retval  int							
	set nocount on

	exec @retval =  sp_DTA_check_permission @SessionID

	if @retval = 1
	begin
		raiserror(31002,-1,-1)
		return(1)
	end	

	insert into [MrTweak].[dbo].[DTA_reports_query]([SessionID],[QueryID], [StatementType], [StatementString], [CurrentCost], [RecommendedCost], [Weight], [EventString], [EventWeight])
	values(@SessionID,@QueryID,@StatementType,@StatementString,@CurrentCost,@RecommendedCost,@Weight,@EventString,@EventWeight)
	

end	

GO
