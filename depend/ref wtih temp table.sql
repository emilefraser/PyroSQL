-- By Steven Rao
-- On Aug 16, 2018
-- Given a single database object (such as stored procedure, function, view, table), list the dependance tree view of all depedent objects
-- Recusively looking inside DMV sys.sql_expression_dependencies

-- Based on
-- https://www.sqlservercentral.com/Forums/Topic1874321-3077-1.aspx


declare @schemaName varchar(128), @objectName varchar(128), @objectID int

--select @schemaName='raw', @objectName='sp_loadsat_D365_SalesReturnLine_MVD'
select @schemaName='dbo', @objectName='sales_header_invoice'

select @objectID=OBJECT_ID(@objectName)

-- debug and verify ObjectID
select @schemaName as [@schemaName], @objectName as [@objectName], @objectID as [@objectID]

if object_id('tempdb..#base_objects') is not null
  drop table #base_objects

create table #base_objects
(schemaname varchar(128)
,objectname varchar(128)
,objectID int
)



insert into #base_objects
select @schemaName, @objectName, @objectID;
--------------------------------------------------------------------------------------
-- extend the expression dependance with a more reliable referenced ID
-- (ignore cross database case)
--------------------------------------------------------------------------------------
with DP as
(
-- referencing_id: parent
-- referenced_id: child
-- need to rely on
-- rely on referencing_id and referenced_entity_name
--select * from sys.sql_expression_dependencies where referencing_id is null or referenced_entity_name is null
--select * from sys.sql_expression_dependencies where referenced_id is null
select
 *
 -- this could give us more depedence data becasue referenced_id could be null
 ,isnull(referenced_id, OBJECT_ID(referenced_entity_name)) as ReferencedID
from sys.sql_expression_dependencies
)
-- this is CTE to recursivly serach for object dependence
,
DepTree
  (
  top_level_name, referenced_id, referenced_schema, referenced_name, referencing_id, referencing_schema, referencing_name, NestLevel, callstack, typedesc
  )
as
(
-- initialization of the depedence tree
select
 schema_name(o.schema_id) + '.' + o.name as top_level_name
 , o.object_id as referenced_id
 , schema_name(o.schema_id) as referenced_schema
 , o.name as referenced_name
 , o.object_id as referencing_id
 , schema_name(o.schema_id) as referencing_schema
 , o.name as referencing_name
 , 0 as NestLevel
 , cast ('|' + schema_name(o.schema_id) + '.' + o.name + '|' as nvarchar(max)) as callstack
 , o.type_desc as typedesc
 from sys.objects o
   inner join #base_objects ro
   on o.object_id=ro.objectID
    --ro.schemaname = schema_name(o.schema_id)
    --and ro.objectname = o.name
    -- using ID for better matching, this can fix issue with 'sp_SRC_MAIN'
    --SCHEMA_ID(ro.schemaname)=o.schema_id
   --and OBJECT_ID(ro.objectname) = o.object_id

-- recursive expansion of the depedence tree
union all

SELECT
 r.top_level_name
 , ref.referenced_id
 , ref.referenced_schema
 , ref.referenced_name
 , ref.referencing_id
 , ref.referencing_schema
 -- Steven Rao
 -- is there a way to show the intermediate parent instead of the top level ??
 , ref.referencing_name
 --, ref.objectname
 , ref.NestLevel
 , callstack + ref.objectname + '|' as callstack
 , cast(ref.typedesc as nvarchar(60)) as typedesc

 FROM  DP d1
    INNER JOIN DepTree r
    ON d1.referencing_id =  r.referenced_id

  outer apply (
     select
      ob2.object_id as referenced_id
      , schema_name(ob2.schema_id) as referenced_schema
      , ob1.name as referenced_name
      , schema_name(ob2.schema_id) + '.' + ob2.name as objectname
      , ob1.object_id as referencing_id
      , schema_name(ob1.schema_id) as referencing_schema
      , ob1.name as referencing_name
      , NestLevel + 2 as NestLevel
      , cast(ob2.type_desc as nvarchar(60)) as typedesc
      from sys.synonyms sy1
        inner join sys.objects ob1
        on ob1.object_id = sy1.object_id
        inner join sys.objects ob2
        on '[' + schema_name(ob2.schema_id) + '].[' + ob2.name + ']' = sy1.base_object_name
         --OBJECT_ID(ob2.name)=OBJECT_ID(sy1.base_object_name)
      where --sy1.object_id = d1.referenced_id
        sy1.object_id = d1.ReferencedID
        

       union all

       select
      --d1.referenced_id
      d1.ReferencedID as referenced_id
      , schema_name(ob1.schema_id) as referenced_schema
      , ob1.name as referenced_name
      , schema_name(ob1.schema_id) + '.' + ob1.name as objectname
      , r.referencing_id
      , r.referencing_schema
      , r.referencing_name
      , NestLevel + 1 as NestLevel
      , cast(ob1.type_desc as nvarchar(60)) as typedesc
     from sys.objects ob1
     where ob1.object_id = d1.ReferencedID

    union all

    select
     --d1.referenced_id
     d1.ReferencedID as referenced_id
     , schema_name(ty1.schema_id) as referenced_schema
     , ty1.name as referenced_name
     , schema_name(ty1.schema_id) + '.' + ty1.name as objectname
     , r.referencing_id
     , r.referencing_schema
     , r.referencing_name
     , NestLevel + 1 as NestLevel
     , cast(d1.referenced_class_desc as nvarchar(60)) as typedesc
     from sys.table_types ty1
     where ty1.user_type_id = ReferencedID
   ) ref
  where --------------------------------------------
  -- need to aviod infinity loop!!
  --------------------------------------------
  callstack not like '%|' +  ref.objectname + '|%'
  -- can we use not in clasue here??
)

select
 NestLevel
  ,referenced_schema as ReferencedSchema
 ,referenced_name as ReferencedObjectName
 -- more user friendly display
 -- remove first and last |, then replace | with "<="
 ,replace(left(right(callstack, len(callstack)-1),len(callstack)-2), '|', ' <= ') as ReferencingStack
 ,typedesc as ReferencingType 
 /*
 -- already shows up in the referencing stack
 --,top_level_name as RootObjectName
 ,referencing_schema
 ,referencing_name 
 ,referencing_id
 ,referenced_id 
 */
 from DepTree dt
 --where 1=1
   --and NestLevel=0
   -- ignore top leve which contains exactly one row for self reference
  -- and NestLevel > 0 
   -------------------------------------------------------------------------------
   -- Case 1
   -- Stored Procedure Dependence only  
  -- and typedesc in ('SQL_STORED_PROCEDURE')
   -------------------------------------------------------------------------------
   -- Case 2
   -- stored procedure and table dependence
   --and typedesc in ('SQL_STORED_PROCEDURE', 'USER_TABLE')
   -------------------------------------------------------------------------------
   -- Case 3
   -- all dependence
   --and typedesc like 'SQL%' or typedesc in ('USER_TABLE')
   -------------------------------------------------------------------------------
 order by 1,2,5,3,4
  option (maxrecursion 5000);