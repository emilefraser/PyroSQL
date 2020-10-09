SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_reports_queryindex]
	@SessionID	int,
	@QueryID	int,
	@IndexID	int,
	@IsRecommendedConfiguration	bit
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
	insert into [MrTweak].[dbo].[DTA_reports_queryindex]([SessionID],[QueryID],[IndexID], [IsRecommendedConfiguration])
	values(@SessionID,@QueryID,@IndexID,@IsRecommendedConfiguration)
	
end	

GO
