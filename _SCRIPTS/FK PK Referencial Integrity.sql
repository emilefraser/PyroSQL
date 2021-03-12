SELECT 
	sq.fk_object_id, o1.name AS fk_object_name
	
	, sq.parent_schema_id, s2.name AS parent_schema_name, sq.parent_object_id, o2.name AS parent_object_name
	
	,  sq.referenced_schema_id, s3.name AS referenced_schema_name,  sq.referenced_object_id, o3.name AS refrenced_object_name

FROM 
(	 SELECT DISTINCT
          fk.object_id AS fk_object_id,
	   fk.schema_id AS parent_schema_id , 
	   fk.parent_object_id,
	   t.schema_id AS referenced_schema_id,
	   fk.referenced_object_id 
     FROM sys.foreign_keys fk	 
     JOIN sys.tables t
	 ON fk.referenced_object_id = t.object_id
	JOIN ( 
	
	SELECT DISTINCT
      fk.object_id 		   	AS FK,
      fk.schema_id 		   	AS SchemaId,
      fk.parent_object_id     	AS TableId,
      t.schema_id 		  	AS ReferencedSchema,
      fk.referenced_object_id 	AS ReferencedTable
     FROM sys.foreign_keys AS fk	 
     JOIN sys.tables AS t 
	 ON fk.referenced_object_id = t.object_id
     WHERE fk.type = 'F' ) AS base_case
	 
	 
	 ON fk.parent_object_id = base_case.ReferencedTable
     WHERE fk.type = 'F'
) AS sq

LEFT JOIN sys.objects AS o1 ON o1.object_id = sq.fk_object_id

LEFT JOIN sys.objects AS o2 ON o2.object_id = sq.parent_object_id
LEFT JOIN sys.schemas AS s2 ON s2.schema_id = o2.schema_id

LEFT JOIN sys.objects AS o3 ON o3.object_id = sq.referenced_object_id
LEFT JOIN sys.schemas AS s3 ON s3.schema_id = o3.schema_id