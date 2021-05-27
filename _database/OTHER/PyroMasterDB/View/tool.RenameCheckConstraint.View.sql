SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[RenameCheckConstraint]'))
EXEC dbo.sp_executesql @statement = N'CREATE vIEW [tool].[RenameCheckConstraint]
AS
--rename-check-constraint-convention.sql
-- script to generate sp_rename commands for all check constraints
select
   ck.name as current_name
  ,po.name as ParentObject 
  ,po.type_desc as ParentType 
  ,ISNULL(pc.name, N'''') as ColumnName 
  ,''exec sp_rename @objname = N''''['' + ps.name + ''].['' + ck.name + '']'''', @newname = ''''CK_'' + po.name + ''_'' + pc.name + '''''''' as rename_cmd
from
  sys.check_constraints ck
  left join sys.objects po on (ck.parent_object_id = po.object_id)
  left join sys.schemas ps on (po.schema_id = ps.schema_id)
  left join sys.columns pc on (ck.parent_object_id = pc.object_id and ck.parent_column_id = pc.column_id)
' 
GO
