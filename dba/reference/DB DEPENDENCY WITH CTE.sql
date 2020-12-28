with
dependencies as
/*this recursive CTE will list all the tables in the database,
and then list all the views that depended on the table, no matter how deep the dependency go (as long as it via views).
*/
 
(
    select dep.referenced_entity_name, OBJECT_NAME(dep.referencing_id) AS referencing_entity_name,
    OBJECT_SCHEMA_NAME(dep.referenced_id) + '.' + OBJECT_NAME(dep.referenced_id) as source,
        object_schema_name(referencing_id) + '.' + object_name(referencing_id) as dependent,
        referencing_id as dependent_object_id,
        1 as depth,
        cast(OBJECT_SCHEMA_NAME(dep.referenced_id) + '.' + OBJECT_NAME(dep.referenced_id) + ' -> ' + object_schema_name(referencing_id) + '.' + object_name(referencing_id) as varchar(400)) as path,
        so.type_desc AS source_type,
        do.type_desc AS dependent_type
    from sys.sql_expression_dependencies as dep
    inner join sys.objects as so
        on so.object_id = dep.referenced_id
    inner join sys.objects as do
        on do.object_id = dep.referencing_id
    where dep.referenced_id <> dep.referencing_id
    and so.type = 'U'
    AND do.type = 'V'
 
    union all
 
    select dep2.referenced_entity_name, OBJECT_NAME(dep.referencing_id) AS referencing_entity_name,
    dep2.source,
        object_schema_name(referencing_id) + '.' + object_name(referencing_id) as dependent,
        dep.referencing_id as dependent_object_id,
        dep2.depth + 1 as depth,
        cast(dep2.path + ' -> ' + object_schema_name(referencing_id) + '.' + object_name(referencing_id) as varchar(400)) as path,
        dep2.source_type,
        dep2.dependent_type
    from sys.sql_expression_dependencies as dep
    inner join dependencies as dep2
        ON dep.referenced_entity_name = dep2.referencing_entity_name
        and dep2.source <> object_schema_name(referencing_id) + '.' + object_name(referencing_id)
)
 
select d.source ,
       d.dependent ,
       d.dependent_object_id ,
       d.depth ,
       d.path ,
       d.source_type,
       d.dependent_type
from dependencies as d