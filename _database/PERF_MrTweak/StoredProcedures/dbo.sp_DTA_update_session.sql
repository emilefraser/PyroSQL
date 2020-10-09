SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_update_session] 
	@SessionID int, 
	@SessionName sysname = NULL, 
	@InteractiveStatus tinyint = NULL
as 
begin  
	declare	@x_SessionName sysname
	declare @x_InteractiveStatus tinyint
	declare @retval  int
	declare @ErrorString nvarchar(500)


	set nocount on
	select @SessionName = LTRIM(RTRIM(@SessionName))
	
	
	declare	@dup_SessionName sysname

	if @SessionName IS NOT NULL
	begin
		select @dup_SessionName = @SessionName
		from msdb.dbo.DTA_input
		where SessionName = @SessionName
	
		if (@dup_SessionName IS NOT NULL)
			begin
				set @ErrorString = 'The session ' + '"' + LTRIM(RTRIM(@SessionName)) + '"' +' already exists. Please use a different session name.'
				raiserror (31001, -1,-1,@SessionName)
				return(1)
			end				
	end
	
	exec @retval =  sp_DTA_check_permission @SessionID
	if @retval = 1
	begin
		raiserror(31002,-1,-1)
		return(1)
	end
	
	if	((@SessionName IS NOT NULL) OR
		(@InteractiveStatus IS NOT NULL)
		)
	begin
		select	@x_SessionName = SessionName,
				@x_InteractiveStatus = InteractiveStatus
		from msdb.dbo.DTA_input
		where SessionID = @SessionID

		if (@SessionName IS NULL) select @SessionName = @x_SessionName
		if (@InteractiveStatus IS NULL) select @InteractiveStatus = @x_InteractiveStatus

		update msdb.dbo.DTA_input
		set SessionName = @SessionName,
			InteractiveStatus = @InteractiveStatus
		where SessionID = @SessionID
	end		

end

GO
