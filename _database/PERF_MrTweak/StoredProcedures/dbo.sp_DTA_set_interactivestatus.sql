SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_set_interactivestatus]
	@InterActiveStatus int,
	@SessionID int 

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

	update [MrTweak].[dbo].[DTA_input] set InteractiveStatus = @InterActiveStatus where SessionID = @SessionID

end	

GO
