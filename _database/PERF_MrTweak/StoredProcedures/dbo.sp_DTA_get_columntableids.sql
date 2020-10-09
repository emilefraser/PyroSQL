SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_get_columntableids]
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

	select ColumnID,DatabaseName,SchemaName,TableName,ColumnName 
	from [MrTweak].[dbo].[DTA_reports_column] as C,
	[MrTweak].[dbo].[DTA_reports_table] as T,[MrTweak].[dbo].[DTA_reports_database] as D 
	where C.TableID = T.TableID and T.DatabaseID = D.DatabaseID and D.SessionID = @SessionID


end	

GO
