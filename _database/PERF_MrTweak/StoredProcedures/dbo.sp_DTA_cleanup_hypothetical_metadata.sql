SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_cleanup_hypothetical_metadata]
	@DatabaseName sysname
as
begin

	declare @SQL nvarchar(max) 

	select @SQL = N'
	declare @strSQL nvarchar(max) 
	declare @objid int 
	declare @indid int 
	declare dta_indexes cursor for select object_id, index_id from sys.indexes where name LIKE ''%dta%'' order by name 
	open dta_indexes 
	fetch NEXT from dta_indexes into @objid, @indid 
	while (@@fetch_status != -1) 
	begin 
	select @strSQL = (select case when INDEXPROPERTY(i.object_id, i.name, ''IsStatistics'') = 1 then ''drop statistics ['' else ''drop index ['' end + schema_name(s.schema_id) + ''].['' + object_name(i.object_id) + ''].['' + i.name + '']'' 
	from sys.indexes i join sys.objects o on i.object_id = o.object_id join sys.schemas s on o.schema_id = s.schema_id
	where i.object_id = @objid and i.index_id = @indid and 
	(INDEXPROPERTY(i.object_id, i.name, ''IsHypothetical'') = 1 or
	(INDEXPROPERTY(i.object_id, i.name, ''IsStatistics'') = 1 and 
	INDEXPROPERTY(i.object_id, i.name, ''IsAutoStatistics'') = 0))) 
	EXEC(@strSQL) 
	fetch NEXT from dta_indexes into @objid, @indid
	end
	close dta_indexes 
	deallocate dta_indexes
	'

	if CHARINDEX('[', @DatabaseName) = 0
	begin
		select @DatabaseName = '[' + @DatabaseName + ']'
	end
	
	select @SQL = 'exec ' + @DatabaseName + '..sp_executesql N''' + replace(@SQL,'''','''''') + ''''
	exec (@SQL)

	return @@error
end

GO
