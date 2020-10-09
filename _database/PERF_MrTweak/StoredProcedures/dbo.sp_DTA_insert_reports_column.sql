SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_reports_column]
	@SessionID	int,
	@TableID int,
	@ColumnName sysname
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
	
	insert into [MrTweak].[dbo].[DTA_reports_column]([TableID], [ColumnName])
		values(	@TableID ,@ColumnName)

end	

GO
