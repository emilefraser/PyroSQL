SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_set_tuningresults_part]
	@SessionID int,	
	@Content nvarchar(3500),
	@PartNumber int
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
	
	Insert into [MrTweak].[dbo].[DTA_tuningresults_part]([SessionID], [PartNumber],[Content]) values(@SessionID,@PartNumber,@Content)
end	

GO
