SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_get_indexableids]
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

	select IndexID,DatabaseName,SchemaName,TableName,IndexName,SessionUniquefier 
	from [MrTweak].[dbo].[DTA_reports_index] as I,[MrTweak].[dbo].[DTA_reports_table] as T,
	[MrTweak].[dbo].[DTA_reports_database] as D 
	where I.TableID = T.TableID and T.DatabaseID = D.DatabaseID and D.SessionID = @SessionID 

end	

GO
