SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_get_tableids]
	@SessionID	int
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

	select TableID,DatabaseName,SchemaName,TableName 
	from [MrTweak].[dbo].[DTA_reports_table] as T,[MrTweak].[dbo].[DTA_reports_database] as D 
	where T.DatabaseID = D.DatabaseID and D.SessionID = @SessionID


end	

GO
