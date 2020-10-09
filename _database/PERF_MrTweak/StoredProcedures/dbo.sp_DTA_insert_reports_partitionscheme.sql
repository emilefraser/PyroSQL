SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_reports_partitionscheme]
	@SessionID	int,   
	@PartitionFunctionID int,
	@PartitionSchemeName sysname,
	@PartitionSchemeDefinition nvarchar(max)
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
	
	Insert into [MrTweak].[dbo].[DTA_reports_partitionscheme]( [PartitionFunctionID],[PartitionSchemeName],[PartitionSchemeDefinition]) values(@PartitionFunctionID,@PartitionSchemeName,@PartitionSchemeDefinition)
end	

GO
