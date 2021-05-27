SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[RenameForeignKeyConstraint]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE vIEW [tool].[RenameForeignKeyConstraint]
AS
--rename-foreign-keys-convention.sql
-- script to generate sp_rename commands for all foreign keys
select
   co.name as current_fk_name
  ,po.name as parent_table
  ,pc.name as parent_column
  ,ro.name as ref_table
  ,rc.name as ref_column
  ,''exec sp_rename @objname = ''''['' + cs.name + ''].['' + co.name + '']'''', @newname = ''''FK_'' + po.name + ''_'' + pc.name + '''''''' as rename_cmd
from
  sys.foreign_key_columns fk
  left join sys.objects co on (fk.constraint_object_id = co.object_id)
  left join sys.schemas cs on (co.schema_id = cs.schema_id)

  left join sys.objects po on (fk.parent_object_id = po.object_id)
  left join sys.columns pc on (fk.parent_object_id = pc.object_id and fk.parent_column_id = pc.column_id)

  left join sys.objects ro on (fk.referenced_object_id = ro.object_id)
  left join sys.columns rc on (fk.referenced_object_id = rc.object_id and fk.referenced_column_id = rc.column_id)' 
GO
