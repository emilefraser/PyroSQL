--
-- Function to product a sql query to count null values in all columns in a given table
-- param @table : the name of the table to query
-- param @key_field : the name of the primary key field or one of the primary key fields
-- 
create function dbo.ScriptCountNulls(@table varchar(120), @key_field varchar(120))
    returns varchar(max) 
as
begin

    declare @template varchar(max),         -- main template
            @field_template varchar(max),   -- template for each field
            @sql varchar(max),              -- to hold final script with all template tags replaced
            @fields varchar(max)            -- to hold all field sql with tags replaced
    
    -- the main template is somewhat simple. All the interesting work is with the fields
    -- %key is a placemarker for the key field
    -- %table is a placemarker for the table name
    -- %fields is a placemarker for the string generated from the field query
    set @template = '
    select count(%key) as [%table_rowcount], %fields
      from %table'
    
    -- each field generates 2 rows. The empty count and the percentage
    -- %field is a placemarker for a single field name
    -- other tags are defined above
    set @field_template = '
            count(%key)-count(%field) as %field_empty,
            case when count(%key) > 0 then cast(100.0*(count(%key)-count(%field))/count(%key) as decimal(6,2)) 
                 else 0 end as %field_empty_pc'
    
    -- use both techniques to build a single string containing columns for every field
    -- http://www.sqlteam.com/article/using-coalesce-to-build-comma-delimited-string
    -- or google for sql comma-separated list coalesce
    -- Note: it is only necessary to replace the %field tag here as other tags will be replaced
    select @fields = coalesce(@fields+', ','') + 
                     replace(@field_template, '%field', name) 
              from sys.columns 
    	     where object_id = object_id(@table) order by column_id
    
    -- Assemble the final template
    -- Replace the fields template first as the value itself contains tags
    set @sql = replace(@template, '%fields', @fields) 
    set @sql = replace(@sql,     '%table', @table)
    set @sql = replace(@sql,     '%key', @key_field)

    return @sql
end

/*
    declare @script varchar(max)
    set @script = dbo.ScriptCountNulls('Customer','Customer_id')
    print @script
    exec (@script)
*/

