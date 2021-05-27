SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[RenamePrimaryKeyConstraint]'))
EXEC dbo.sp_executesql @statement = N'CREATE vIEW [tool].[RenamePrimaryKeyConstraint]
AS
--rename-primary-keys-convention.sql
-- script to generate sp_rename commands for each existing sys.key_constraint PK entry
select 
   c.name as current_pk_name
  ,po.name as table_name
  ,''exec sp_rename @objname = N''''['' + ps.name + ''].['' + c.name + '']'''', @newname = ''''PK_'' + po.name + '''''''' as rename_cmd
from
  sys.key_constraints c
  left join sys.objects po on (c.parent_object_id = po.object_id)
  left join sys.schemas ps on (po.schema_id = ps.schema_id)
where
  c.[type] = ''PK''' 
GO
