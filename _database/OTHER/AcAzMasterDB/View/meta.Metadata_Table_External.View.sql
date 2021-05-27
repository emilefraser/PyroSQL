SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Table_External]'))
EXEC dbo.sp_executesql @statement = N'
CREATE      VIEW [meta].[Metadata_Table_External]
AS
select 
    schema_name(schema_id) as schema_name,
    t.name as table_name,
    s.name as source_name,
    s.location, 
    s.type_desc as source_type,
    f.name as format_name,
    f.format_type,
    f.field_terminator,
    f.string_delimiter,
    f.row_terminator,
    f.encoding,
    f.data_compression
from sys.external_tables t
    inner join sys.external_data_sources s
        on t.data_source_id = s.data_source_id
    inner join sys.external_file_formats f
        on t.file_format_id = f.file_format_id;
' 
GO
