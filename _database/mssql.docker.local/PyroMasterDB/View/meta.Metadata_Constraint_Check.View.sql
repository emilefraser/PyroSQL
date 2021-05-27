SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Constraint_Check]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [meta].[Metadata_Constraint_Check]
AS
	select con.[name] as constraint_name,
    schema_name(t.schema_id) + ''.'' + t.[name]  as [table],
    col.[name] as column_name,
    con.[definition],
    case when con.is_disabled = 0 
        then ''Active'' 
        else ''Disabled'' 
        end as [status]
from sys.check_constraints con
    left outer join sys.objects t
        on con.parent_object_id = t.object_id
    left outer join sys.all_columns col
        on con.parent_column_id = col.column_id
        and con.parent_object_id = col.object_id
' 
GO
