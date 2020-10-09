SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_progressinformation]
	@SessionID int,
	@TuningStage int
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

	INSERT into [MrTweak].[dbo].[DTA_progress]
		(SessionID,WorkloadConsumption,EstImprovement,TuningStage,ConsumingWorkLoadMessage,PerformingAnalysisMessage,GeneratingReportsMessage)
	values(@SessionID,0,0,@TuningStage,N'',N'',N'')
	
end	

GO
