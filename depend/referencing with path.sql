SELECT  DB_NAME() AS dbname, 
 o.type_desc AS referenced_object_type, 
 d1.referenced_entity_name, 
 d1.referenced_id, 
        STUFF( (SELECT ', ' + OBJECT_NAME(d2.referencing_id)
   FROM sys.sql_expression_dependencies d2
         WHERE d2.referenced_id = d1.referenced_id
                ORDER BY OBJECT_NAME(d2.referencing_id)
                FOR XML PATH('')), 1, 1, '') AS dependent_objects_list
FROM sys.sql_expression_dependencies  d1 JOIN sys.objects o 
  ON  d1.referenced_id = o.[object_id]
GROUP BY o.type_desc, d1.referenced_id, d1.referenced_entity_name
ORDER BY o.type_desc, d1.referenced_entity_name
      

	  ;with ObjectHierarchy ( Base_Object_Id , Base_Cchema_Id , Base_Object_Name , Base_Object_Type, object_id , Schema_Id , Name , Type_Desc , Level , Obj_Path) 
as 
    ( select  so.object_id as Base_Object_Id 
        , so.schema_id as Base_Cchema_Id 
        , so.name as Base_Object_Name 
        , so.type_desc as Base_Object_Type
        , so.object_id as object_id 
        , so.schema_id as Schema_Id 
        , so.name 
        , so.type_desc 
        , 0 as Level 
        , convert ( nvarchar ( 1000 ) , N'/' + so.name ) as Obj_Path 
    from sys.objects so 
        left join sys.sql_expression_dependencies ed on ed.referenced_id = so.object_id 
        left join sys.objects rso on rso.object_id = ed.referencing_id 
    where rso.type is null 
        and so.type in ( 'P', 'V', 'IF', 'FN', 'TF' , 'U') 

    union all 
    select   cp.Base_Object_Id as Base_Object_Id 
        , cp.Base_Cchema_Id 
        , cp.Base_Object_Name 
        , cp.Base_Object_Type
        , so.object_id as object_id 
        , so.schema_id as ID_Schema 
        , so.name 
        , so.type_desc 
        , Level + 1 as Level 
        , convert ( nvarchar ( 1000 ) , cp.Obj_Path + N'/' + so.name ) as Obj_Path 
    from sys.objects so 
        inner join sys.sql_expression_dependencies ed on ed.referenced_id = so.object_id 
        inner join sys.objects rso on rso.object_id = ed.referencing_id 
        inner join ObjectHierarchy as cp on rso.object_id = cp.object_id and rso.object_id <> so.object_id 
    where so.type in ( 'P', 'V', 'IF', 'FN', 'TF', 'U') 
        and ( rso.type is null or rso.type in ( 'P', 'V', 'IF', 'FN', 'TF', 'U' ) ) 
        and cp.Obj_Path not like '%/' + so.name + '/%' )   -- prevent cycles n hierarcy
select   Base_Object_Name 
    , Base_Object_Type
    , REPLICATE ( '   ' , Level ) + Name as Indented_Name 
    , SCHEMA_NAME ( Schema_Id ) + '.' + Name as object_id 
    , Type_Desc as Object_Type 
    , Level 
    , Obj_Path 
from ObjectHierarchy as p 
order by Obj_Path
