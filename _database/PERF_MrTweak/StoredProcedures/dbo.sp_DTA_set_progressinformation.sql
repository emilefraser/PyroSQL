SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_set_progressinformation]
	@SessionID int,
	@WorkloadConsumption int,
	@TuningStage int,
	@EstImprovement int,
	@ConsumingWorkLoadMessage nvarchar(256) = N'',
	@PerformingAnalysisMessage nvarchar(256)= N'',
	@GeneratingReportsMessage nvarchar(256)= N''


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
	update [MrTweak].[dbo].[DTA_progress]
	set WorkloadConsumption = @WorkloadConsumption,
	EstImprovement = @EstImprovement,
	ProgressEventTime = GetDate(),
	ConsumingWorkLoadMessage =	@ConsumingWorkLoadMessage ,
	PerformingAnalysisMessage =	@PerformingAnalysisMessage,
	GeneratingReportsMessage =	@GeneratingReportsMessage
	where SessionID=@SessionID
	and TuningStage = @TuningStage
end	

GO
