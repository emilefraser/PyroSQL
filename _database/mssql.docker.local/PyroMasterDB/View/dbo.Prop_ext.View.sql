SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Prop_ext]'))
EXEC dbo.sp_executesql @statement = N'
	  
	  
/* select * from [dbo].[Prop_ext]*/
CREATE   VIEW [dbo].[Prop_ext]
AS
SELECT        
--o.obj_id, o.obj_type, o.obj_name, o.srv, o.db, o.[schema], o.table_or_view
o.obj_id, o.obj_type, o.full_obj_name
 , p.property_id , p.property_name property, pv.value, p.default_value, p.property_scope
 , pv.record_dt 
FROM            dbo.Obj_ext AS o 
INNER JOIN static.Property AS p ON o.obj_type = ''table'' AND p.apply_table = 1 OR o.obj_type = ''view'' AND p.apply_view = 1 OR o.obj_type = ''schema'' AND p.apply_schema = 1 OR o.obj_type = ''database'' AND 
                         p.apply_db = 1 OR o.obj_type = ''server'' AND p.apply_srv = 1 
						 OR o.obj_type = ''user'' AND p.apply_user = 1 
LEFT OUTER JOIN
                         dbo.Property_Value AS pv ON pv.property_id = p.property_id AND pv.obj_id = o.obj_id












' 
GO
