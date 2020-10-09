SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_add_session] 
   @SessionName sysname, 
   @TuningOptions nvarchar(max),
   @SessionID int OUTPUT,
   @GlobalSessionID uniqueidentifier = NULL
as 
	declare @UserName as nvarchar(256) 
	declare	@x_SessionName sysname
	declare @ErrorString nvarchar(500)
	declare @XmlDocumentHandle int
	declare @retval int
	declare @dbcount int
	
	set nocount on
	begin transaction
		-- Check for duplicate session name
		select @x_SessionName = @SessionName
		from msdb.dbo.DTA_input
		where SessionName = @SessionName

		if (@x_SessionName IS NOT NULL)
			begin
				rollback transaction
				set @ErrorString = 'The session ' + '"' + LTRIM(RTRIM(@SessionName)) + '"' +' already exists. Please use a different session name.'
				raiserror (31001, -1,-1,@SessionName)
				return(1)
			end		
		
		-- Create new session
				
		if (@GlobalSessionID IS NOT NULL)
			begin
				insert into msdb.dbo.DTA_input (SessionName,TuningOptions, GlobalSessionID) 
				values (@SessionName,@TuningOptions,@GlobalSessionID) 
			end
		else
			begin
				insert into msdb.dbo.DTA_input (SessionName,TuningOptions) 
				values (@SessionName,@TuningOptions) 
			end

		select @SessionID = @@identity	

		
		if @@error <> 0
			begin
				rollback transaction
				return @@error
			end				


		if @@error <> 0
			begin
				rollback transaction
				return @@error
			end				

				-- Create an internal representation of the XML document.
				EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @TuningOptions,
				'<DTAXML  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:x="http://schemas.microsoft.com/sqlserver/2004/07/dta"/>'
				
				if @@error <> 0
				begin
					rollback transaction
					return @@error
				end		
				-- Execute a SELECT statement using OPENXML rowset provider.

				insert into DTA_reports_database
				SELECT    @SessionID,msdb.dbo.fn_DTA_unquote_dbname([x:Name]),1
				FROM      OPENXML (@XmlDocumentHandle, 
									'/x:DTAXML/x:DTAInput/x:Server//x:Database',2)
						WITH ([x:Name]  nvarchar(128) ) 
				
				if @@error <> 0
				begin
					rollback transaction
					return @@error
				end		
			
				EXEC sp_xml_removedocument @XmlDocumentHandle

				if @@error <> 0
				begin
					rollback transaction
					return @@error
				end		
				
				

		
			-- Check if allowed to add session
			exec @retval =  sp_DTA_check_permission @SessionID

			if @retval = 1
			begin
				raiserror(31003,-1,-1)
				rollback transaction
				return (1)
			end	

			select @dbcount = count(*) from DTA_reports_database
			where SessionID = @SessionID			
			if @dbcount = 0 
			begin
				rollback transaction
				return (1)
			end

		-- Insert progress record
		insert into [MrTweak].[dbo].[DTA_progress]
		(SessionID,WorkloadConsumption,EstImprovement,TuningStage,ConsumingWorkLoadMessage,PerformingAnalysisMessage,GeneratingReportsMessage)
		values(@SessionID,0,0,0,N'',N'',N'')

		if @@error <> 0
		begin
			rollback transaction
			return @@error
		end		

		
	-- Commit if input/progress records are updated
	commit transaction
	return 0

GO
