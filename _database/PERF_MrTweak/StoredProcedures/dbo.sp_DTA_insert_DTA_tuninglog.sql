SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_insert_DTA_tuninglog]
	@SessionID int,
	@RowID int,
	@CategoryID char(4),
	@Event nvarchar(max),
	@Statement nvarchar(max),
	@Frequency int,
	@Reason nvarchar(max)
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
	insert into [MrTweak].[dbo].[DTA_tuninglog]([SessionID], [RowID], [CategoryID], [Event], [Statement], [Frequency], [Reason])
	values(@SessionID, @RowID, @CategoryID, @Event, @Statement, @Frequency, @Reason)
end	

GO
