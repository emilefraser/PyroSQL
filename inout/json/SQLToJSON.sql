set nocount on
declare @TableViewName	nvarchar(128),
        @Columns        nvarchar(max),
        @Columns_       nvarchar(max),
        @ColumnName     nvarchar(max),
        @SQLColumns     nvarchar(max),
        @SQLQuery       nvarchar(max),
        @SQLString      nvarchar(max),
        @LastRecord     int,
        @StartPos       int,
        @Length         int;
 
declare @TableColumn table(TableColumn nvarchar(max));
declare	@TableJSON table(ID int identity(1,1), JSON nvarchar(max));
 
-- Input variable for Table or View
set @TableViewName = 'NameOfViewOrTableGoesHere';
 
-- Input variable for columns, comma seperated...
set @Columns = 'CommaSeparatedListOfAttributesGoesHere';
 
set @Columns_ = @Columns;
 
while len(@Columns) > 0
begin
	if right(rtrim(@Columns), 1) <> ','
	begin
		set @Columns = @Columns  + ','
    end
    set @StartPos = charindex(',', @Columns)
    if (@StartPos) < 0
    begin
		set @StartPos = 0
        set @Length = (len(@Columns) - @StartPos - 1)
        if (@Length) < 0
        begin
			set @Length = 0
        end
    end
    if (@StartPos) > 0
    begin          
		set @ColumnName = ltrim(substring(@Columns, 1, @StartPos - 1))
        
		-- Build string Column logic (core)
        set @ColumnName = '''"' + @ColumnName + '":''' + ' + case 
							when isdate(isnull(' + @ColumnName + ', null)) = 1 then + ''"'' + coalesce(convert(nvarchar(30),' + @ColumnName + ', 121), ''null'') + ''"'' 
							when isnumeric(isnull(' + @ColumnName + ', 0)) = 1 then coalesce(cast(' + @ColumnName + ' as nvarchar(max)), ''null'') 
							when '+  @ColumnName + ' = ''true'' then ''true'' when ' + @ColumnName + ' = ''false'' then ''false'' 
							else + ''"'' + coalesce(cast(' + @ColumnName + ' as nvarchar(max)), ''null'') + ''"'' end  + '','''
        set @Columns = substring(@Columns, @StartPos + 1, len(@Columns) - @StartPos)
    end
    else
    begin
		set @ColumnName = @Columns
        set @Columns = ''
    end
    insert @TableColumn (TableColumn) values(@ColumnName)
end;
 
-- Take care of NULL columns
select @SQLColumns = coalesce(@SQLColumns + ' + ','') + TableColumn from @TableColumn;
 
--Remove the last five trailing characters (+ ',')
set @SQLColumns = left(@SQLColumns, len(@SQLColumns) - 5);
 
-- Prepare CTE statement
set @SQLQuery = 'select' + ' ' + @Columns_ + ' ' + 'from ' +  @TableViewName;
set @SQLString = 'with SQLtoJSON_CTE (' + @Columns_ + ')' + ' ' + 
					'as (' + @SQLQuery + ')' + 'select ''{'' +' + @SQLColumns + '+ ''},''' + ' ' + 'from SQLtoJSON_CTE';
 
-- Insert returned SQLtoJSON_CTE records
insert into @TableJSON exec sp_executesql @SQLString;
 
-- Get the ID of the last record
select @LastRecord = max(ID) from @TableJSON;
 
-- Remove the trailing comma (,) at the end of the last record
update	@TableJSON
set		JSON = left(JSON, len(JSON) - 1)
where	ID = @LastRecord;
 
-- Return Valide JSON
select valid.JSON as 'ValidJSON' from (select '[' as 'JSON' union all select JSON from @TableJSON union all select ']' as 'JSON') valid;
set nocount off