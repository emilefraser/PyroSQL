SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_reports_partitionfunction]
	@SessionID	int,
	@DatabaseID int,
	@PartitionFunctionName sysname,
	@PartitionFunctionDefinition nvarchar(max)
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
	
	Insert into [MrTweak].[dbo].[DTA_reports_partitionfunction]([DatabaseID],[PartitionFunctionName],[PartitionFunctionDefinition]) 
	values(@DatabaseID,@PartitionFunctionName,@PartitionFunctionDefinition)
end	

GO
