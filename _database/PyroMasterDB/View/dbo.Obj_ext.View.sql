SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Obj_ext]'))
EXEC dbo.sp_executesql @statement = N'
	  
	  
	  
--select * from dbo.obj_ext
CREATE   VIEW [dbo].[Obj_ext]AS
WITH q AS (
	SELECT        
	o.obj_id, o.obj_type_id, ot.obj_type, o.obj_name, o.scope, o.parent_id, parent_o.obj_name AS parent, parent_o.parent_id AS grand_parent_id, grand_parent_o.obj_name AS grand_parent, 
	grand_parent_o.parent_id AS great_grand_parent_id, great_grand_parent_o.obj_name AS great_grand_parent, o.delete_dt, o.record_dt, o.record_user, isnull(o.template_id, parent_o.template_id) template_id
	, o.prefix, o.[obj_name_no_prefix], ot.obj_type_level , st.server_type, o.server_type_id, o.identifier
--	, o.$node_id node_id
	FROM dbo.Obj AS o 
	INNER JOIN static.obj_type AS ot ON o.obj_type_id = ot.obj_type_id 
	INNER JOIN static.Server_type AS st ON o.server_type_id = st.server_type_id 
	LEFT OUTER JOIN dbo.Obj AS parent_o ON o.parent_id = parent_o.obj_id 
	LEFT OUTER JOIN dbo.Obj AS grand_parent_o ON parent_o.parent_id = grand_parent_o.obj_id 
	LEFT OUTER JOIN dbo.Obj AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.obj_id
	where o.delete_dt is null 
)
, q2 AS
    (SELECT        obj_id, obj_type , obj_name, 
/*
10	table	40
20	view	40
30	schema	30
40	database	20
50	server	10
60	user	NULL
70	procedure	40
100	cube	30
130	security role	NULL
NULL	NULL	NULL
*/
CASE 
WHEN obj_type_level = 10 THEN [obj_name] 
WHEN obj_type_level = 20 THEN parent 
WHEN obj_type_level = 30 THEN grand_parent 
WHEN obj_type_level = 40 THEN great_grand_parent 
END AS srv
,
CASE 
WHEN obj_type_level = 20 THEN obj_name
WHEN obj_type_level = 30 THEN parent 
WHEN obj_type_level = 40 THEN grand_parent 
ELSE null 
END AS db
,
CASE 
WHEN obj_type_level = 30 THEN obj_name
WHEN obj_type_level = 40 THEN parent 
ELSE null 
END AS [schema]
, CASE 
WHEN obj_type_level = 40 THEN obj_name
ELSE null 
END AS schema_object
, delete_dt, record_dt, record_user, parent_id, grand_parent_id, great_grand_parent_id, scope, q_1.template_id
, prefix, [obj_name_no_prefix], server_type, server_type_id, identifier
--, node_id
FROM q AS q_1)
SELECT        
obj_id
, 
case when obj_type in ( ''user'', ''server'') then [obj_name] else 
ISNULL( quotename( case when srv<>''LOCALHOST''then srv else null end  )+''.'', '''') -- don''t show localhost
+ ISNULL( quotename(db), '''') 
+ ISNULL(''.['' + [schema] + '']'', '''') 
+ ISNULL(''.['' + schema_object + '']'', '''') end AS full_obj_name
, isnull([schema]+ ''.'','''') + schema_object obj_and_schema_name
, scope
, obj_type
, server_type
, obj_name
, srv [srv_name]
, db [db_name]
, [schema] [schema_name]
, schema_object
, template_id
, parent_id
, grand_parent_id
, great_grand_parent_id
, server_type_id
, delete_dt
, record_dt
, record_user
, prefix
, [obj_name_no_prefix]
, p.[default_template_id]
, identifier
--, node_id
FROM q2 AS q2_1
left join dbo.Prefix p on q2_1.prefix = p.prefix_name












' 
GO
