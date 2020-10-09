SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_check_permission] 
				@SessionID int
as 
begin
	declare @retcode  int
	declare @dbname nvarchar(128)	
	declare @sql nvarchar(256)
	declare @dbid int
	declare @ServVersion nvarchar(128)
	
	set nocount on
	set @retcode = 1

	-- Check if SA
	if (isnull(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
	begin
		return(0) 
	end
	
	-- if SQL Server 2000 return
	select @ServVersion=CONVERT(nvarchar(128), serverproperty(N'ProductVersion'))
	if (patindex('8.%',@ServVersion) > 0)
	begin
		return (1)
	end
	
	-- declare and open a cursor and get all the databases specified in the input
	declare db_cursor cursor for
	select DatabaseName from DTA_reports_database
	where SessionID = @SessionID and IsDatabaseSelectedToTune  = 1
	-- open
	open db_cursor
	-- fetch first db name
	fetch next from db_cursor
	into @dbname
	-- loop and get all the databases selected to tune
	while @@fetch_status = 0
	begin
		-- build use db string
		select  @dbid = DB_ID(@dbname)
	
		-- set @retcode to OK. Will be set to 1 in case of issues
		set @retcode = 0

		-- In Yukon this masks the error messages
		set @sql = N'begin try
			dbcc autopilot(5,@dbid) WITH NO_INFOMSGS 
		end try
		begin catch
			set @retcode = 1
		end catch'

		execute sp_executesql @sql
			, N'@dbid int output, @retcode int OUTPUT' 
			, @dbid output 
			, @retcode output
	
		-- if caller is not member of dbo
		if (@retcode = 1)
		begin
			-- close and reset cursor,switch context to current
			-- database and return 1
			close db_cursor
			deallocate db_cursor
			return(1)
		end
		fetch from db_cursor into @dbname
	end
	-- close and reset cursor,switch context to current
	-- database and return 1
	close db_cursor
	deallocate db_cursor
	-- if caller is not member of dbo
	if (@retcode = 1)
	begin
		return(1)
	end
	return(0) 
end		

GO
