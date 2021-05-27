SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[RenameDefaultConstraint]'))
EXEC dbo.sp_executesql @statement = N'CREATE vIEW [tool].[RenameDefaultConstraint]
AS
--rename-default-constraint-convention.sql
-- script to generate sp_rename commands for all default constraints
select
   df.name AS current_name
  ,po.name AS ParentObject
  ,po.type_desc AS ParentType 
  ,isnull(pc.name, N'''') AS ColumnName 
  ,''exec sp_rename @objname = N''''['' + ps.name + ''].['' + df.name + '']'''', @newname = ''''DF_'' + po.name + ''_'' + pc.name + '''''''' as rename_cmd
from
  sys.default_constraints df
  left join sys.objects po on (df.parent_object_id = po.object_id)
  left join sys.schemas ps on (po.schema_id = ps.schema_id)
  left join sys.columns pc on (df.parent_object_id = pc.object_id and df.parent_column_id = pc.column_id)' 
GO
